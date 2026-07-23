//
//  ClaudeTestViewModel.swift
//  C4
//
//  Created by 이경민 on 7/20/26.
//


import SwiftData
import Observation
import Foundation

@Observable
final class ClaudeTestViewModel {
    
        // MARK: - 의존성
    private let context: ModelContext
    
    private let keywordRepository: KeywordRepository
    private let experienceRepository: ExperienceRepository
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
        self.experienceRepository = ExperienceRepository(context: modelContext)
        self.attachmentRepository = AttachmentRepository(context: modelContext)
        self.episodeRepository = EpisodeRepository(context: modelContext)
        self.episodeGenerating = episodeGenerating
    }
    
        // MARK: - Experience 생성/삭제
    
    func createExperience(title: String, periodStart: Date, periodEnd: Date, experienceStatement: String, keywordNames: [String]) {
        do {
            let keywords = try keywordNames.map { try keywordRepository.findOrCreate(name: $0) }
            let experience = experienceRepository.create(
                title: title,
                periodStart: periodStart,
                periodEnd: periodEnd,
                experienceStatement: experienceStatement
            )
            experience.keywords = keywords
            try context.save()
        } catch {
            errorMessage = "경험 생성 실패: \(error.localizedDescription)"
        }
    }
    
    func deleteExperience(_ experience: Experience) {
        experienceRepository.delete(experience)
        try? context.save()
    }
}

    // MARK: - 파일 첨부
extension ClaudeTestViewModel {
    
        // MARK: 파일 첨부 + 텍스트 추출 저장
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
}

    // MARK: - Episode 생성 (Claude API 호출)
extension ClaudeTestViewModel {
    
        // MARK: Claude에게 에피소드 생성 요청 → 결과를 SwiftData에 저장
    func generateEpisodes(for experience: Experience) async {
        isGenerating = true
        defer { isGenerating = false }
        
        do {
                // MARK: 1. 입력값 구성 (키워드 + 경험진술 + 첨부파일 텍스트)
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

