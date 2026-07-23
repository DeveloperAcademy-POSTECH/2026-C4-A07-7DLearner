//
//  IntegrationTestViewModel.swift
//  C4
//
//  Created by YOOJUN PARK on 7/19/26.
//

// 흐름: 경험 생성 → 에피소드 생성 → 캐릭터 생성 → 편집/삭제

import SwiftData
import Observation
import Foundation

@Observable
final class IntegrationTestViewModel {
    
    // MARK: 상태
    private(set) var isGenerating = false
    private(set) var statusMessage = ""
    
    // MARK: 의존성
    private let context: ModelContext
    private let keywordRepository: KeywordRepository
    private let experienceRepository: ExperienceRepository
    private let attachmentRepository: AttachmentRepository
    private let episodeRepository: EpisodeRepository
    private let characterRepository: CharacterRepository
    
    // MARK: 생성자
    init(modelContext: ModelContext) {
        self.context = modelContext
        self.keywordRepository = KeywordRepository(context: modelContext)
        self.experienceRepository = ExperienceRepository(context: modelContext)
        self.attachmentRepository = AttachmentRepository(context: modelContext)
        self.episodeRepository = EpisodeRepository(context: modelContext)
        self.characterRepository = CharacterRepository(context: modelContext)
    }
    
}

// MARK: - 1. 경험 생성
extension IntegrationTestViewModel {
    
    func createExperience(title: String, statement: String, keywordInput: String) {
        let keywordNames = keywordInput
            .split(separator: ",")
            .map { String($0) }
            .filter { !$0.isEmpty }
        
        guard !title.isEmpty, !keywordNames.isEmpty else {
            statusMessage = "제목과 키워드는 필수 입력"
            return
        }
        
        do {
            let keywords = try keywordNames.map { try keywordRepository.findOrCreate(name: $0) }
            
            let experience = experienceRepository.create(
                title: title,
                periodStart: .now,
                periodEnd: .now,
                experienceStatement: statement
            )
            experience.keywords = keywords
            
            try context.save()
            statusMessage = "경험 생성 완료"
        } catch {
            statusMessage = "경험 생성 실패: \(error)"
        }
    }
    
    // 실제 파일 선택 → 사본 저장 → Attachment 생성 → 텍스트 추출
    func addAttachment(from url: URL, to experience: Experience) {
        do {
            let storedFileName = try FileStorageService.importAndStore(from: url)
            
            let attachment = attachmentRepository.create(
                fileName: url.lastPathComponent,
                storedFileName: storedFileName,
                fileType: url.pathExtension,
                fileSize: (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0,
                experience: experience
            )
            attachment.extractedText = try TextExtractionService.extractText(
                from: attachment.storedFileURL,
                fileType: attachment.fileType
            )
            
            try context.save()
            statusMessage = "첨부 완료: \(attachment.fileName)"
        } catch {
            statusMessage = "첨부 실패: \(error)"
        }
    }
    
    // 편집: 단순 값 변경은 Repository 없이 직접 프로퍼티 대입
    func updateExperience(_ experience: Experience, title: String, statement: String) {
        experience.title = title
        experience.experienceStatement = statement
        try? context.save()
        statusMessage = "경험 수정 완료"
    }
    
}

// MARK: - 2. 에피소드 생성 (Experience → DTO → LanguageModel → Episode 저장)
extension IntegrationTestViewModel {
    
    @MainActor
    func generateEpisodes(for experience: Experience) async {
        isGenerating = true
        defer { isGenerating = false }
        
        do {
            // Experience → DTO
            let input = EpisodeGenerationInput(
                keywordNames: experience.keywords.map(\.name),
                experienceStatement: experience.experienceStatement,
                attachmentTexts: experience.attachments.compactMap { attachment in
                    guard let text = attachment.extractedText else { return nil }
                    return AttachmentText(attachmentID: attachment.id, text: text)
                }
            )
            
            // LanguageModel 호출 (EpisodeGenerating 프로토콜을 따르는 어느 구현체로도 교체 가능)
            let outputs = try await FoundationModelService().generateEpisodes(input: input)
            
            // DTO → Episode
            for output in outputs {
                let keyword = try keywordRepository.findOrCreate(name: output.keywordName)
                let attachment = experience.attachments.first { $0.id == output.sourceAttachmentID }
                
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
            statusMessage = "에피소드 \(outputs.count)개 생성됨"
        } catch {
            statusMessage = "에피소드 생성 실패: \(error)"
        }
    }
    
}

// MARK: - 3. 캐릭터 생성
extension IntegrationTestViewModel {
    
    func createCharacter(title: String, statement: String, keywords: [Keyword]) {
        guard !title.isEmpty, !keywords.isEmpty else {
            statusMessage = "캐릭터 이름과 키워드는 필수 입력"
            return
        }
        
        _ = characterRepository.create(
            title: title,
            characterStatement: statement,
            keywords: keywords
        )
        
        try? context.save()
        statusMessage = "캐릭터 생성 완료"
    }
    
}

// MARK: - 4. 삭제
extension IntegrationTestViewModel {
    
    // Experience: Attachment, Episode까지 cascade 삭제
    func delete(_ experience: Experience) {
        experienceRepository.delete(experience)
        try? context.save()
        statusMessage = "경험 삭제됨"
    }
    
    // Character: Keyword, Episode는 유지 (nullify)
    func delete(_ character: Character) {
        characterRepository.delete(character)
        try? context.save()
        statusMessage = "캐릭터 삭제됨"
    }
    
}
