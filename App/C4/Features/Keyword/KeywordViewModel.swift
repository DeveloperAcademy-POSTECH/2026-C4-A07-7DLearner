//
//  KeywordViewModel.swift
//  C4
//
//  Created by 박시은 on 7/20/26.
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class KeywordViewModel {
    
    // MARK: - Dependencies
    private let context: ModelContext
    
    // MARK: State
    var keywords: [Keyword] = []
    var selectedKeyword: Keyword?
    
    // MARK: Inspector State
    var currentInspectorScreen: InspectorScreen?
    var isInspectorPresented: Bool {
        currentInspectorScreen != nil
    }
    
    // MARK: Draft State
    var draftExperienceTitle: String = ""
    var draftStartDate: String = ""
    var draftEndDate: String = ""
    var draftStatement: String = ""
    var draftKeywords: [String] = []
    var draftAttachedFiles: [Attachment] = []
    
    // 분석 버튼 활성화를 위한 필수값 검증 프로퍼티
    var isDraftReadyToAnalyze: Bool {
        !draftExperienceTitle.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draftStartDate.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draftEndDate.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draftStatement.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draftKeywords.isEmpty
    }
    // MARK: Initializer
    init(modelContext: ModelContext) {
        self.context = modelContext
        fetchKeywords()
    }
    
    // MARK: - Functions
    // 저장된 전체 키워드 조회
    func fetchKeywords() {
        do {
            let descriptor = FetchDescriptor<Keyword>()
            keywords = try context.fetch(descriptor)
        } catch {
            print("Keyword 조회 실패: \(error)")
        }
    }
    // 특정 키워드와 연결된 에피소드 반환
    func episodesForKeyword(keyword: Keyword) -> [Episode] {
        return keyword.episodes
    }
    
    @MainActor
    func generateEpisodes() async {
        try? await Task.sleep(for: .seconds(2))
        print("분석 완료 로직")
    }
    
    // 생성창 초기화 함수
    func startKeywordCreation() {
        draftExperienceTitle = ""
        draftStartDate = ""
        draftEndDate = ""
        draftStatement = ""
        draftKeywords = []
        draftAttachedFiles = []
        
        selectedKeyword = nil
        currentInspectorScreen = .create
    }
}
