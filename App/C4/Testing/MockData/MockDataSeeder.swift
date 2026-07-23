//
//  MockDataSeeder.swift
//  C4
//
//  Created by YOOJUN PARK on 7/21/26.
//

// MARK: Task { await MockDataSeeder.seedAll(modelContext: modelContext) }
// MARK: .task { await MockDataSeeder.seedAll(modelContext: modelContext) }

import SwiftData
import Foundation

enum MockDataSeeder {
    
    @MainActor
    static func seedAll(modelContext: ModelContext) async {
        
        let keywordRepository = KeywordRepository(context: modelContext)
        let experienceRepository = ExperienceRepository(context: modelContext)
        let episodeRepository = EpisodeRepository(context: modelContext)
        let characterRepository = CharacterRepository(context: modelContext)
        
        deleteAllExistingData(
            modelContext: modelContext,
            keywordRepository: keywordRepository,
            experienceRepository: experienceRepository,
            characterRepository: characterRepository
        )
        
        for scenario in MockScenarioSet.experiences {
            
            // 시나리오에 맞는 경험 데이터 생성
            guard let experience = createExperience(
                scenario: scenario,
                modelContext: modelContext,
                keywordRepository: keywordRepository,
                experienceRepository: experienceRepository
            ) else { continue }
            
            // FoundationModel로 에피소드 생성
            await generateEpisodes(
                for: experience,
                modelContext: modelContext,
                keywordRepository: keywordRepository,
                episodeRepository: episodeRepository
            )
        }
        
        // 시나리오에 맞는 캐릭터 데이터 생성
        for characterScenario in MockScenarioSet.characters {
            createCharacter(
                scenario: characterScenario,
                modelContext: modelContext,
                keywordRepository: keywordRepository,
                characterRepository: characterRepository
            )
        }
    }
    
    @MainActor
    static func deleteAll(modelContext: ModelContext) async {
        let keywordRepository = KeywordRepository(context: modelContext)
        let experienceRepository = ExperienceRepository(context: modelContext)
        let characterRepository = CharacterRepository(context: modelContext)
        
        deleteAllExistingData(
            modelContext: modelContext,
            keywordRepository: keywordRepository,
            experienceRepository: experienceRepository,
            characterRepository: characterRepository
        )
    }
    
}

// MARK: - 기존 데이터 삭제
private extension MockDataSeeder {
    
    static func deleteAllExistingData(
        modelContext: ModelContext,
        keywordRepository: KeywordRepository,
        experienceRepository: ExperienceRepository,
        characterRepository: CharacterRepository
    ) {
        if let characters = try? characterRepository.fetchAll() {
            for character in characters {
                characterRepository.delete(character)
            }
        }
        
        if let experiences = try? experienceRepository.fetchAll() {
            for experience in experiences {
                experienceRepository.delete(experience)
            }
        }
        
        if let keywords = try? keywordRepository.fetchAll() {
            for keyword in keywords {
                keywordRepository.delete(keyword)
            }
        }
        
        try? modelContext.save()
    }
    
}

// MARK: - 경험 및 에피소드 생성 로직
private extension MockDataSeeder {
    
    static func createExperience(
        scenario: MockExperienceScenario,
        modelContext: ModelContext,
        keywordRepository: KeywordRepository,
        experienceRepository: ExperienceRepository
    ) -> Experience? {
        let keywordNames = scenario.keywordInput
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard !keywordNames.isEmpty else { return nil }
        guard let keywords = try? keywordNames.map({ try keywordRepository.findOrCreate(name: $0) }) else {
            return nil
        }
        
        let experience = experienceRepository.create(
            title: scenario.title,
            periodStart: .now,
            periodEnd: .now,
            experienceStatement: scenario.statement
        )
        experience.keywords = keywords
        
        try? modelContext.save()
        return experience
    }
    
    static func generateEpisodes(
        for experience: Experience,
        modelContext: ModelContext,
        keywordRepository: KeywordRepository,
        episodeRepository: EpisodeRepository
    ) async {
        let input = EpisodeGenerationInput(
            keywordNames: experience.keywords.map(\.name),
            experienceStatement: experience.experienceStatement,
            attachmentTexts: []
        )
        
        guard let outputs = try? await FoundationModelService().generateEpisodes(input: input) else {
            return
        }
        
        for output in outputs {
            guard let keyword = try? keywordRepository.findOrCreate(name: output.keywordName) else {
                continue
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
                attachment: nil
            )
        }
        
        try? modelContext.save()
    }
    
}

// MARK: - 캐릭터 생성 로직
private extension MockDataSeeder {
    
    static func createCharacter(
        scenario: MockCharacterScenario,
        modelContext: ModelContext,
        keywordRepository: KeywordRepository,
        characterRepository: CharacterRepository
    ) {
        guard let keywords = try? scenario.keywordNames.map({ try keywordRepository.findOrCreate(name: $0) }),
              !keywords.isEmpty else { return }
        
        _ = characterRepository.create(
            title: scenario.title,
            characterStatement: scenario.statement,
            keywords: keywords
        )
        
        try? modelContext.save()
    }
    
}
