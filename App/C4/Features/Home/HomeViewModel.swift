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
    // MARK: - SwiftData
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}

// MARK: - Experience 생성
extension HomeViewModel {
    
    func canSaveExperience(title: String, experienceStatement: String) -> Bool {
        !title.isEmpty && !experienceStatement.isEmpty
    }
    
    func createExperience(
        title: String,
        periodStart: Date,
        periodEnd: Date,
        experienceStatement: String
    ) {
        let experience = Experience(
            title: title,
            periodStart: periodStart,
            periodEnd: periodEnd,
            experienceStatement: experienceStatement
        )
        
        modelContext.insert(experience)
    }
}

// MARK: - Experience 수정/삭제
extension HomeViewModel {
    func toggleFavorite(_ experience: Experience) {
        //
    }
    
    func deleteExperience(_ experience: Experience) {
        modelContext.delete(experience)
    }
}
