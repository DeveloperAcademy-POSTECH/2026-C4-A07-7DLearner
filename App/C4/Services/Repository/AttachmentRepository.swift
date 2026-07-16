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
    func create(fileName: String, storedFileName: String, fileType: String, fileSize: Int, experience: Experience) -> Attachment {
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
    
    // MARK: 삭제 - 실제 파일 사본도 같이 지움
    func delete(_ attachment: Attachment) {
        try? FileStorageService.delete(storedFileName: attachment.storedFileName)
        context.delete(attachment)
    }
    
}
