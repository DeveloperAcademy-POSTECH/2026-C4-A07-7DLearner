//
//  TextExtractionTestView.swift
//  C4
//
//  TextExtractionService 동작 검증용 인앱 테스트 하니스.
//  샘플 파일을 임시 디렉터리에 생성한 뒤 추출 결과를 확인한다.
//

import SwiftUI
import AppKit
import CoreText

struct TextExtractionTestView: View {

    @State private var results: [TestResult] = []
    @State private var isRunning = false

    @State private var pickedFileName: String?
    @State private var pickedExtractedText: String?
    @State private var pickedError: String?

    var body: some View {
        Form {
            Section("실제 파일로 추출만 확인 (Claude API 호출 없음)") {
                Button("파일 선택해서 추출...") {
                    pickRealFileAndExtract()
                }

                if let pickedFileName {
                    Text(pickedFileName)
                        .font(.callout.weight(.medium))
                }
                if let pickedExtractedText {
                    ScrollView {
                        Text(pickedExtractedText)
                            .font(.caption)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 200)
                }
                if let pickedError {
                    Text(pickedError)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                }
            }

            Section("TextExtractionService 테스트") {
                Button(isRunning ? "실행 중..." : "테스트 실행") {
                    Task { await runAll() }
                }
                .disabled(isRunning)

                if !results.isEmpty {
                    let passed = results.filter(\.passed).count
                    Text("\(passed)/\(results.count) 통과")
                        .font(.caption)
                        .foregroundStyle(passed == results.count ? .green : .red)
                }

                ForEach(results) { result in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(result.passed ? .green : .red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.name).font(.callout.weight(.medium))
                            Text(result.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 480, minHeight: 500)
    }

    // MARK: - 실제 파일 선택 → TextExtractionService만 직접 호출 (Claude/EpisodeGenerationManager 미사용)
    private func pickRealFileAndExtract() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true

        guard panel.runModal() == .OK, let url = panel.url else { return }

        pickedFileName = url.lastPathComponent
        pickedExtractedText = nil
        pickedError = nil

        let gotAccess = url.startAccessingSecurityScopedResource()
        defer {
            if gotAccess { url.stopAccessingSecurityScopedResource() }
        }

        do {
            let text = try TextExtractionService.extractText(from: url, fileType: url.pathExtension.lowercased())
            pickedExtractedText = text
        } catch {
            pickedError = "추출 실패: \(error)"
        }
    }
}

// MARK: - 테스트 결과 모델
private struct TestResult: Identifiable {
    let id = UUID()
    let name: String
    let passed: Bool
    let detail: String
}

// MARK: - 테스트 실행
private extension TextExtractionTestView {

    func runAll() async {
        isRunning = true
        results = []
        defer { isRunning = false }

        // OCR/PDF 렌더링이 무거우므로 백그라운드에서 실행
        let collected = await Task.detached(priority: .userInitiated) {
         await TextExtractionTestRunner.run()
        }.value

        results = collected
    }
}

// MARK: - 실제 검증 로직 (뷰와 분리)
private enum TextExtractionTestRunner {

    static func run() -> [TestResult] {
        var results: [TestResult] = []

        // 1. txt
        results.append(check("txt 추출", ext: "txt", make: { url in
            try "hello txt 샘플".write(to: url, atomically: true, encoding: .utf8)
        }, expect: { $0.contains("hello txt") }))

        // 2. md
        results.append(check("md 추출", ext: "md", make: { url in
            try "# markdown 제목\n본문".write(to: url, atomically: true, encoding: .utf8)
        }, expect: { $0.contains("markdown") }))

        // 3. csv
        results.append(check("csv 추출", ext: "csv", make: { url in
            try "a,b,c\n1,2,3".write(to: url, atomically: true, encoding: .utf8)
        }, expect: { $0.contains("a,b,c") }))

        // 4. rtf
        results.append(check("rtf 추출", ext: "rtf", make: { url in
            let attr = NSAttributedString(string: "rtf text 샘플")
            let data = try attr.data(
                from: NSRange(location: 0, length: attr.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            )
            try data.write(to: url)
        }, expect: { $0.contains("rtf text") }))

        // 5. pdf (텍스트 레이어)
        results.append(check("pdf 텍스트 레이어 추출", ext: "pdf", make: { url in
            try makeTextPDF("pdf text layer", to: url)
        }, expect: { $0.lowercased().contains("pdf text") }))

        // 6. 이미지 OCR
        results.append(check("이미지 OCR 추출", ext: "png", make: { url in
            try makeTextImage("SWIFT", to: url)
        }, expect: { $0.uppercased().contains("SWIFT") }))

        // 6-1. 스캔 PDF (텍스트 레이어 없음) → OCR 폴백
        results.append(check("스캔 PDF OCR 폴백", ext: "pdf", make: { url in
            try makeScannedPDF("SCANNED", to: url)
        }, expect: { $0.uppercased().contains("SCANNED") }))

        // 7. 미지원 확장자 → unsupportedFileType throw
        results.append(checkThrows("미지원 확장자 throw", ext: "xyz", make: { url in
            try "data".write(to: url, atomically: true, encoding: .utf8)
        }, expect: { error in
            if case TextExtractionError.unsupportedFileType = error { return true }
            return false
        }))

        // 8. 손상된 pdf → corruptedFile throw
        results.append(checkThrows("손상 pdf throw", ext: "pdf", make: { url in
            try Data("not a real pdf".utf8).write(to: url)
        }, expect: { error in
            if case TextExtractionError.corruptedFile = error { return true }
            return false
        }))

        // 9. EUC-KR(레거시 한글 인코딩) txt 추출 - UTF-8 폴백 검증
        results.append(check("EUC-KR txt 추출", ext: "txt", make: { url in
            let eucKR = String.Encoding(
                rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))
            )
            let data = "안녕하세요 EUC-KR 테스트".data(using: eucKR)!
            try data.write(to: url)
        }, expect: { $0.contains("안녕하세요") }))

        // 10. 손상된 docx → corruptedFile throw
        results.append(checkThrows("손상 docx throw", ext: "docx", make: { url in
            try "not a real docx".write(to: url, atomically: true, encoding: .utf8)
        }, expect: { error in
            if case TextExtractionError.corruptedFile = error { return true }
            return false
        }))

        // 11. 존재하지 않는 파일 → corruptedFile throw (txt 경로가 날것의 NSError를 흘리지 않는지 검증)
        results.append(checkThrows("존재하지 않는 txt 파일 throw", ext: "txt", make: { _ in
            // 일부러 파일을 만들지 않는다
        }, expect: { error in
            if case TextExtractionError.corruptedFile = error { return true }
            return false
        }))

        // 12. 혼합 페이지 PDF(짧은 텍스트 레이어 + 이미지 본문) - 이미지 본문이 안 사라지는지 검증
        results.append(check("혼합 페이지 PDF (텍스트+이미지) 추출", ext: "pdf", make: { url in
            try makeMixedPagePDF(shortText: "p.1", bodyText: "IMPORTANT BODY", to: url)
        }, expect: { $0.contains("p.1") && $0.uppercased().contains("IMPORTANT") }))

        return results
    }

    // MARK: 성공 케이스 검증
    private static func check(
        _ name: String,
        ext: String,
        make: (URL) throws -> Void,
        expect: (String) -> Bool
    ) -> TestResult {
        let url = tempURL(ext: ext)
        defer { try? FileManager.default.removeItem(at: url) }
        do {
            try make(url)
            let text = try TextExtractionService.extractText(from: url, fileType: ext)
            let ok = expect(text)
            let preview = text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(80)
            return TestResult(name: name, passed: ok, detail: ok ? "추출: \"\(preview)\"" : "기대 불일치 · 추출: \"\(preview)\"")
        } catch {
            return TestResult(name: name, passed: false, detail: "예상치 못한 에러: \(error)")
        }
    }

    // MARK: throw 케이스 검증
    private static func checkThrows(
        _ name: String,
        ext: String,
        make: (URL) throws -> Void,
        expect: (Error) -> Bool
    ) -> TestResult {
        let url = tempURL(ext: ext)
        defer { try? FileManager.default.removeItem(at: url) }
        do {
            try make(url)
            let text = try TextExtractionService.extractText(from: url, fileType: ext)
            return TestResult(name: name, passed: false, detail: "throw 기대했으나 반환됨: \"\(text.prefix(40))\"")
        } catch {
            let ok = expect(error)
            return TestResult(name: name, passed: ok, detail: ok ? "기대한 에러 발생: \(error)" : "다른 에러: \(error)")
        }
    }

    // MARK: - 파일 생성 헬퍼

    private static func tempURL(ext: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("extract-test-\(UUID().uuidString)")
            .appendingPathExtension(ext)
    }

    // 텍스트 레이어가 있는 PDF 생성
    private static func makeTextPDF(_ text: String, to url: URL) throws {
        var mediaBox = CGRect(x: 0, y: 0, width: 300, height: 200)
        guard let ctx = CGContext(url as CFURL, mediaBox: &mediaBox, nil) else {
            throw TextExtractionError.corruptedFile
        }
        ctx.beginPDFPage(nil)
        let attr = NSAttributedString(string: text, attributes: [.font: NSFont.systemFont(ofSize: 18)])
        let line = CTLineCreateWithAttributedString(attr)
        ctx.textPosition = CGPoint(x: 20, y: 100)
        CTLineDraw(line, ctx)
        ctx.endPDFPage()
        ctx.closePDF()
    }

    // 텍스트 레이어가 없는 "스캔" PDF 생성 (텍스트를 이미지로 그림 → OCR 폴백 대상)
    private static func makeScannedPDF(_ text: String, to url: URL) throws {
        let size = NSSize(width: 400, height: 200)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        (text as NSString).draw(
            at: NSPoint(x: 20, y: 80),
            withAttributes: [
                .font: NSFont.boldSystemFont(ofSize: 48),
                .foregroundColor: NSColor.black
            ]
        )
        image.unlockFocus()

        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let cgImage = rep.cgImage else {
            throw TextExtractionError.corruptedFile
        }

        var box = CGRect(x: 0, y: 0, width: 400, height: 200)
        guard let ctx = CGContext(url as CFURL, mediaBox: &box, nil) else {
            throw TextExtractionError.corruptedFile
        }
        ctx.beginPDFPage(nil)
        ctx.draw(cgImage, in: box)   // 텍스트가 아닌 이미지로 그려서 text layer가 없음
        ctx.endPDFPage()
        ctx.closePDF()
    }

    // 짧은 텍스트 레이어(예: 페이지 번호) + 이미지 본문이 섞인 "혼합 페이지" PDF 생성
    // (스캐너가 페이지 번호는 텍스트로, 본문은 이미지로 찍는 실제 상황 재현)
    private static func makeMixedPagePDF(shortText: String, bodyText: String, to url: URL) throws {
        let bodySize = NSSize(width: 400, height: 250)
        let bodyImage = NSImage(size: bodySize)
        bodyImage.lockFocus()
        NSColor.white.setFill()
        NSRect(origin: .zero, size: bodySize).fill()
        (bodyText as NSString).draw(
            at: NSPoint(x: 10, y: 100),
            withAttributes: [
                .font: NSFont.boldSystemFont(ofSize: 32),
                .foregroundColor: NSColor.black
            ]
        )
        bodyImage.unlockFocus()

        guard let tiff = bodyImage.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let cgImage = rep.cgImage else {
            throw TextExtractionError.corruptedFile
        }

        var box = CGRect(x: 0, y: 0, width: 400, height: 300)
        guard let ctx = CGContext(url as CFURL, mediaBox: &box, nil) else {
            throw TextExtractionError.corruptedFile
        }
        ctx.beginPDFPage(nil)
        // 본문: 이미지로 그림 (텍스트 레이어 없음)
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: 400, height: 250))
        // 헤더: 스캐너가 찍어주는 실제 텍스트 한 줄 (예: 페이지 번호)
        let attr = NSAttributedString(string: shortText, attributes: [.font: NSFont.systemFont(ofSize: 10)])
        let line = CTLineCreateWithAttributedString(attr)
        ctx.textPosition = CGPoint(x: 350, y: 285)
        CTLineDraw(line, ctx)
        ctx.endPDFPage()
        ctx.closePDF()
    }

    // 텍스트가 그려진 PNG 이미지 생성 (OCR 대상)
    private static func makeTextImage(_ text: String, to url: URL) throws {
        let size = NSSize(width: 400, height: 120)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        (text as NSString).draw(
            at: NSPoint(x: 20, y: 30),
            withAttributes: [
                .font: NSFont.boldSystemFont(ofSize: 56),
                .foregroundColor: NSColor.black
            ]
        )
        image.unlockFocus()

        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else {
            throw TextExtractionError.corruptedFile
        }
        try png.write(to: url)
    }
}

#Preview {
    TextExtractionTestView()
}
