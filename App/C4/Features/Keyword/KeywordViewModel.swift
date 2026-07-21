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
    var draftExperienceDescription: String = ""

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
        // Keyword 모델 안에 episodes 배열이 있다고 가정
        return keyword.episodes
    }

    // AI 분석을 통해 에피소드를 생성하는 비동기 함수 (임시 뼈대)
    @MainActor
    func generateEpisodes() async {
        try? await Task.sleep(for: .seconds(2))
        print("분석 완료 로직")
    }

    func episodesForKeyword(_ keyword: Keyword) -> [Episode] {
        return keyword.episodes
    }
}
