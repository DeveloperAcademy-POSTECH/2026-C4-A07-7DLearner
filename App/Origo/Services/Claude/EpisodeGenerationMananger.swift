//
//  EpisodeGenerationManager.swift
//  C4
//
//  Created by 이경민 on 7/20/26.
//

import SwiftData
import Observation
import Foundation

    // MARK: - Experience로부터 Episode를 생성하는 매니저 (Claude API 연동)
    // 다른 화면/뷰모델에서 이 클래스를 주입받아 사용하면 됩니다.
@Observable
final class EpisodeGenerationManager {
    
        // MARK: - 의존성
    private let context: ModelContext
    private let keywordRepository: KeywordRepository
    private let attachmentRepository: AttachmentRepository
    private let episodeRepository: EpisodeRepository
    private let episodeGenerating: EpisodeGenerating
    
        // MARK: - UI 바인딩 상태 (로딩/에러)
    var isGenerating: Bool = false
    var errorMessage: String?
    
        // MARK: - 초기화
    init(modelContext: ModelContext, episodeGenerating: EpisodeGenerating = ClaudeService()) {
        self.context = modelContext
        self.keywordRepository = KeywordRepository(context: modelContext)
        self.attachmentRepository = AttachmentRepository(context: modelContext)
        self.episodeRepository = EpisodeRepository(context: modelContext)
        self.episodeGenerating = episodeGenerating
    }
    
        // MARK: - 파일 첨부 (텍스트 추출까지 포함)
    func addAttachment(from url: URL, to experience: Experience) {
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
            errorMessage = "파일 첨부 실패: \(error.localizedDescription)"
        }
    }
    
        // MARK: - Episode 생성 (Claude API 호출)
    func generateEpisodes(for experience: Experience) async {
        isGenerating = true
        defer { isGenerating = false }
        
        do {
                // MARK: 1. 입력값 구성
            let keywordNames = experience.keywords.map { $0.name }
            
            guard !keywordNames.isEmpty else {
                errorMessage = "키워드가 없는 경험입니다. 키워드를 먼저 추가해주세요."
                return
            }
            
            let attachmentTexts = experience.attachments.compactMap { attachment -> AttachmentText? in
                guard let text = attachment.extractedText else { return nil }
                return AttachmentText(attachmentID: attachment.id, text: text)
            }
            
            let input = EpisodeGenerationInput(
                keywordNames: keywordNames,
                experienceStatement: experience.experienceStatement,
                attachmentTexts: attachmentTexts
            )
            
                // MARK: 2. Claude API 호출
            let outputs = try await episodeGenerating.generateEpisodes(input: input)
            
                // MARK: 3. 결과를 SwiftData Episode로 저장
            for output in outputs {
                let keyword = try keywordRepository.findOrCreate(name: output.keywordName)
                
                let attachment: Attachment? = output.sourceAttachmentID.flatMap { attachmentID in
                    experience.attachments.first { $0.id == attachmentID }
                }
                
                _ = episodeRepository.create(
                    title: output.title,
                    problemContext: output.problemContext,
                    concernPoint: output.concernPoint,
                    myAction: output.myAction,
                    outcome: output.outcome,
                    sourceExcerpt: output.sourceExcerpt,
                    experience: experience,
                    keyword: keyword,
                    attachment: attachment
                )
            }
            
            try context.save()
            
        } catch {
            errorMessage = "에피소드 생성 실패: \(error.localizedDescription)"
        }
    }
}

// MARK: ExperienceViewModel에서 주입받기
/*
 @Observable
 final class ExperienceViewModel {
     private let episodeGenerationManager: EpisodeGenerationManager
     // ... 
     
     init(modelContext: ModelContext) {
         self.episodeGenerationManager = EpisodeGenerationManager(modelContext: modelContext)
         // ...
     }
 }
 */

// MARK: 호출
/*
 // 파일 첨부
 episodeGenerationManager.addAttachment(from: url, to: experience)

 // 에피소드 생성 (비동기)
 await episodeGenerationManager.generateEpisodes(for: experience)

 // 상태 바인딩
 episodeGenerationManager.isGenerating   // Bool
 episodeGenerationManager.errorMessage   // String?
 */
