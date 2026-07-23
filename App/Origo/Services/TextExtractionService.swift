//
//  TextExtractionService.swift
//  C4
//
//  Created by YOOJUN PARK on 7/16/26.
//

import Foundation
import PDFKit

enum TextExtractionService {
    
    // MARK: 파일 Type 별로 분기해서 텍스트 추출
    static func extractText(from url: URL, fileType: String) throws -> String {
        switch fileType.lowercased() {
            
        case "txt", "md", "csv":
            return try String(contentsOf: url, encoding: .utf8)
            
        case "pdf":
            return try extractFromPDF(url)
            
        default:
            throw TextExtractionError.unsupportedFileType(fileType)
            
        }
    }
    
}

// MARK: - 파일 확장자 별 extract 함수
extension TextExtractionService {
    
    // MARK: PDF 추출 - 텍스트 레이어가 있는 PDF만 지원
    private static func extractFromPDF(_ url: URL) throws -> String {
        guard let document = PDFDocument(url: url) else {
            throw TextExtractionError.corruptedFile
        }
        
        // 페이지 별로 순회하며 전체 text 추출
        var fullText = ""
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }
            if let pageText = page.string {
                fullText += pageText + "\n"
            }
        }
        return fullText
    }
    
}

enum TextExtractionError: Error {
    case unsupportedFileType(String)
    case corruptedFile
}
