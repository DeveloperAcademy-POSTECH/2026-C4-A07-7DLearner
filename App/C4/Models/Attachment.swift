//
//  Attachment.swift
//  C4
//
//  Created by YOOJUN PARK on 7/15/26.
//

import SwiftData
import Foundation

@Model
final class Attachment {
    
    // MARK: 식별자
    var id: UUID
    
    // MARK: 시스템 생성값
    var fileName: String // 사용자에게 표시할 파일명 (파일명 중복 가능)
    var storedFileName: String // 샌드박스 안에 저장될 파일 사본의 실제 파일명 (파일명 중복 방지)
    var fileType: String
    var fileSize: Int
    var extractedText: String? // file의 전체 content를 String으로 변환
    
    // MARK: 관계
    @Relationship(inverse: \Experience.attachments) var experience: Experience
    var episodes: [Episode] = []
    
    // MARK: 생성자
    init(fileName: String, storedFileName: String, fileType: String, fileSize: Int, experience: Experience) {
        self.id = UUID()
        self.fileName = fileName
        self.storedFileName = storedFileName
        self.fileType = fileType
        self.fileSize = fileSize
        self.experience = experience
    }
    
}

// MARK: - 파일 상태
extension Attachment {
    
    // 텍스트 추출이 끝났는지 확인
    var isTextExtracted: Bool {
        self.extractedText != nil
    }
    
    // 출력용 포맷 (KB, MB 단위 등)
    var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(self.fileSize), countStyle: .file)
    }
    
    // 샌드박스 안 파일 사본의 전체 경로
    var storedFileURL: URL {
        FileStorageService.url(for: self.storedFileName)
    }
    
}
