//
//  AttachmentRepository.swift
//  C4
//
//  Created by YOOJUN PARK on 7/16/26.
//

import SwiftData
import Foundation

struct AttachmentRepository {
    
    let context: ModelContext
    
    // MARK: 생성
    func create(fileName: String, storedFileName: String, fileType: String, fileSize: Int, experience: Experience? = nil) -> Attachment {
        let attachment = Attachment(
            fileName: fileName,
            storedFileName: storedFileName,
            fileType: fileType,
            fileSize: fileSize,
            experience: experience
        )
        context.insert(attachment)
        return attachment
    }
    
    // Experience와 연결되지 않은 Attachment를 연결
    func attach(_ attachment: Attachment, to experience: Experience) {
        attachment.experience = experience
    }
    
    // Experience와 연결되지 않은 Attachment를 삭제
    func deleteUnlinkedAttachments(_ attachments: [Attachment]) {
        for attachment in attachments where attachment.experience == nil {
            delete(attachment)
        }
    }
    
    // MARK: 삭제 - 실제 파일 사본도 같이 지움
    func delete(_ attachment: Attachment) {
        try? FileStorageService.delete(storedFileName: attachment.storedFileName)
        context.delete(attachment)
    }
    
}
