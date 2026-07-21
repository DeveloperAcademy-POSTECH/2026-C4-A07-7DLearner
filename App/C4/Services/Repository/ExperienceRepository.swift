//
//  ExperienceRepository.swift
//  C4
//
//  Created by YOOJUN PARK on 7/16/26.
//

import SwiftData
import Foundation

struct ExperienceRepository {
    
    let context: ModelContext
    
    // MARK: 조회
    func fetchAll() throws -> [Experience] {
        try context.fetch(FetchDescriptor<Experience>())
    }
    
    // MARK: 생성
    func create(title: String, periodStart: Date, periodEnd: Date, experienceStatement: String) -> Experience {
        let experience = Experience(
            title: title,
            periodStart: periodStart,
            periodEnd: periodEnd,
            experienceStatement: experienceStatement
        )
        context.insert(experience)
        return experience
    }
    
}

// MARK: - Attachment 관련 작업
// AttachmentRepository을 호출하여 작업 수행
extension ExperienceRepository {
    
    func createAttachment(fileName: String, storedFileName: String, fileType: String, fileSize: Int, experience: Experience? = nil) -> Attachment {
        AttachmentRepository(context: context)
            .create(fileName: fileName, storedFileName: storedFileName, fileType: fileType, fileSize: fileSize, experience: experience)
    }
    
    // Experience 삭제 시, 종속된 Attachment들의 실제 파일 사본부터 먼저 삭제
    func delete(_ experience: Experience) {
        let attachmentRepository = AttachmentRepository(context: context)
        for attachment in experience.attachments {
            attachmentRepository.delete(attachment)
        }
        context.delete(experience)
    }
    
}
