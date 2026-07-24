//
//  TextExtractionService.swift
//  C4
//
//  Created by YOOJUN PARK on 7/16/26.
//

import Foundation
import PDFKit
import AppKit
import Vision

enum TextExtractionService {

    // MARK: 파일 Type 별로 분기해서 텍스트 추출
    static func extractText(from url: URL, fileType: String) throws -> String {
        switch fileType.lowercased() {

        case "txt", "md", "csv":
            return try readPlainText(url)

        case "pdf":
            return try extractFromPDF(url)

        case "docx":
            return try extractFromAttributedString(url, type: .officeOpenXML)

        case "doc":
            return try extractFromAttributedString(url, type: .docFormat)

        case "rtf":
            return try extractFromAttributedString(url, type: .rtf)

        case "png", "jpg", "jpeg", "heic", "heif", "tiff", "bmp", "gif":
            return try extractFromImage(url)

        default:
            throw TextExtractionError.unsupportedFileType(fileType)

        }
    }

}

// MARK: - 파일 확장자 별 extract 함수
extension TextExtractionService {

    // MARK: 일반 텍스트 추출
    private static func readPlainText(_ url: URL) throws -> String {
        guard let data = try? Data(contentsOf: url) else {
            throw TextExtractionError.corruptedFile
        }
        if let utf8Text = String(data: data, encoding: .utf8) {
            return utf8Text
        }
        let eucKR = String.Encoding(
            rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))
        )
        if let eucKRText = String(data: data, encoding: eucKR) {
            return eucKRText
        }
        throw TextExtractionError.corruptedFile
    }

    // MARK: PDF 추출 - 텍스트 레이어 우선, 없거나 아주 짧으면(스캔 PDF, 혼합 페이지) 페이지별 OCR 보완
    private static func extractFromPDF(_ url: URL) throws -> String {
        guard let document = PDFDocument(url: url) else {
            throw TextExtractionError.corruptedFile
        }

        // 텍스트 레이어가 있어도 이 길이 이하면(예: 스캐너가 찍는 페이지 번호 한 줄) 본문 자체는
        // 이미지일 가능성이 있다고 보고 OCR도 함께 돌려 보완한다. 실제로 이렇게 렌더링해서 OCR을
        // 돌리면 페이지에 그려진 짧은 텍스트와 이미지 본문이 함께 인식된다.
        let shortTextLayerThreshold = 10

        // 페이지 별로 순회하며 전체 text 추출
        var fullText = ""
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }

            let pageText = page.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if pageText.count > shortTextLayerThreshold {
                // 충분한 텍스트 레이어가 있는 페이지 → 빠른 경로
                fullText += pageText + "\n"
            } else if let cgImage = renderPDFPageImage(page) {
                // 텍스트 레이어가 없거나(스캔) 아주 짧은(혼합) 페이지 → OCR 보완
                let ocrText = recognizeText(from: cgImage)
                if !ocrText.isEmpty {
                    fullText += ocrText + "\n"
                } else if !pageText.isEmpty {
                    fullText += pageText + "\n"
                }
            } else if !pageText.isEmpty {
                fullText += pageText + "\n"
            }
        }
        return fullText
    }

    // MARK: 이미지 추출 - Vision OCR
    private static func extractFromImage(_ url: URL) throws -> String {
        guard let image = NSImage(contentsOf: url),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw TextExtractionError.corruptedFile
        }
        return recognizeText(from: cgImage)
    }

    // MARK: 문서 추출 - NSAttributedString이 지원하는 포맷 (docx, doc, rtf 등)
    private static func extractFromAttributedString(_ url: URL, type: NSAttributedString.DocumentType) throws -> String {
        guard let data = try? Data(contentsOf: url) else {
            throw TextExtractionError.corruptedFile
        }
        guard let attributed = try? NSAttributedString(
            data: data,
            options: [.documentType: type],
            documentAttributes: nil
        ) else {
            throw TextExtractionError.corruptedFile
        }
        return attributed.string
    }

    // MARK: - OCR 공통 로직

    // CGImage에서 텍스트 인식 (한/영 우선). 실패/무텍스트 시 빈 문자열.
    private static func recognizeText(from cgImage: CGImage) -> String {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return ""
        }

        return (request.results ?? [])
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
    }

    // PDF 페이지를 비트맵 CGImage로 렌더링 (OCR 정확도를 위해 2배 스케일)
    private static func renderPDFPageImage(_ page: PDFPage, scale: CGFloat = 2.0) -> CGImage? {
        let box = PDFDisplayBox.mediaBox
        let bounds = page.bounds(for: box)
        let width = Int(bounds.width * scale)
        let height = Int(bounds.height * scale)

        guard width > 0, height > 0,
              let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ) else {
            return nil
        }

        // 흰 배경으로 채운 뒤 페이지 그리기
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
        page.draw(with: box, to: context)

        return context.makeImage()
    }

}

enum TextExtractionError: Error {
    case unsupportedFileType(String)
    case corruptedFile
}
