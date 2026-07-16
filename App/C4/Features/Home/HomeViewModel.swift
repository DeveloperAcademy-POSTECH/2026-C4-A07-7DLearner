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
    
    init(modelContext: ModelContext) {
        self.context = modelContext
        self.keywordRepository = KeywordRepository(context: modelContext)
        self.experienceRepository = ExperienceRepository(context: modelContext)
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
