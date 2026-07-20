//
//  HomeViewModel.swift
//  C4
//
//  Created by YOOJUN PARK on 7/13/26.
//

import SwiftData
import Observation
import Foundation

@Observable
final class HomeViewModel {
    
    private let context: ModelContext
    
    private let keywordRepository: KeywordRepository
    private let experienceRepository: ExperienceRepository
    private let attachmentRepository: AttachmentRepository
    
    init(modelContext: ModelContext) {
        self.context = modelContext
        self.keywordRepository = KeywordRepository(context: modelContext)
        self.experienceRepository = ExperienceRepository(context: modelContext)
        self.attachmentRepository = AttachmentRepository(context: modelContext)
    }
    
    func createExperience(title: String, periodStart: Date, periodEnd: Date, experienceStatement: String, keywordNames: [String]) {
        let keywords = keywordNames.map { try! keywordRepository.findOrCreate(name: $0) }
        let experience = experienceRepository.create(
            title: title,
            periodStart: periodStart,
            periodEnd: periodEnd,
            experienceStatement: experienceStatement
        )
        experience.keywords = keywords
        try? experienceRepository.context.save()
    }
    
    func deleteExperience(_ experience: Experience) {
        experienceRepository.delete(experience)
        try? experienceRepository.context.save()
    }
    
}

// MARK: - 파일 첨부 (파일 추가 테스트)
extension HomeViewModel {
    
    // Experience가 없으면 하나 만들어서 반환
    private func demoExperience() -> Experience {
        if let existing = try? experienceRepository.fetchAll().first {
            return existing
        }
        let created = experienceRepository.create(
            title: "테스트 경험",
            periodStart: .now,
            periodEnd: .now,
            experienceStatement: "파일 첨부 테스트"
        )
        try? context.save()
        return created
    }
    
    // 샌드박스에 사본 저장 -> Attachment 생성 -> 텍스트 추출 -> 저장
    func addAttachment(from url: URL) {
        
        let experience = demoExperience()
        
        do {
            let storedFileName = try FileStorageService.importAndStore(from: url)
            
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
            
            let attachment = attachmentRepository.create(
                fileName: url.lastPathComponent,
                storedFileName: storedFileName,
                fileType: url.pathExtension,
                fileSize: fileSize,
                experience: experience
            )
            
            let extractedText = try TextExtractionService.extractText(
                from: attachment.storedFileURL,
                fileType: attachment.fileType
            )
            attachment.extractedText = extractedText
            
            try context.save()
            
        } catch {
            print("파일 첨부 실패: \(error)")
        }
    }
    
}
