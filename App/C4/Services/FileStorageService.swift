//
//  FileStorageService.swift
//  C4
//
//  Created by YOOJUN PARK on 7/16/26.
//

import Foundation

enum FileStorageService {
    
    // MARK: 샌드박스에 저장된 파일(storedFileName)의 실제 경로 계산 (문자열 계산)
    // ApplicationSupport/Attachments/FileName.pdf...
    static func url(for storedFileName: String) -> URL {
        let directory = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Attachments", isDirectory: true) // Attachments 폴더를 경로에 추가
        return directory.appendingPathComponent(storedFileName) // 파일 이름을 경로에 추가
    }
    
    // MARK: 샌드박스 Application Support 폴더 하위에 Attachments 폴더가 존재하는지 검사
    // 'ApplicationSupport/Attachments/' 존재 여부
    private static func ensureDirectoryExists() throws {
        let directory = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Attachments", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: 외부 저장소 파일 접근 및 사본을 샌드박스로 복사
    static func importAndStore(from originalURL: URL) throws -> String {
        
        // 파일 원본 위치(외부)의 실제 주소(originalURL)에 대한 접근 권한 획득 (SecurityScoped)
        guard originalURL.startAccessingSecurityScopedResource() else {
            throw FileStorageError.accessDenied
        }
        
        // 함수 종료 시, 접근 권한 반환
        defer { originalURL.stopAccessingSecurityScopedResource() }
        
        // 원본 파일을 Data 타입으로 받아옴
        let data = try Data(contentsOf: originalURL)
        
        // 받아온 data를 샌드박스에 저장
        try ensureDirectoryExists()
        let storedFileName = UUID().uuidString + "." + originalURL.pathExtension // (UUID.확장자) 형태의 파일명
        let destination = url(for: storedFileName) // 저장할 파일 사본의 샌드박스 내 전체 경로
        try data.write(to: destination)
        
        return storedFileName
        
    }
    
    // MARK: 샌드박스에 저장된 파일 삭제
    static func delete(storedFileName: String) throws {
        let destination = url(for: storedFileName) // 파일 경로 계산
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
    }
    
}

enum FileStorageError: Error {
    case accessDenied
}
