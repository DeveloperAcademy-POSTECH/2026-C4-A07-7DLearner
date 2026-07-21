//
//  CharacterViewModel.swift
//  C4
//
//  Created by jiwon hong on 7/20/26.
//

import Foundation
import SwiftData
import Observation

// MARK: Character ViewModel
@Observable
final class CharacterViewModel {
    
    // MARK: Dependencies
    private let context: ModelContext
    
    private let characterRepository: CharacterRepository
    private let keywordRepository: KeywordRepository
    private let episodeRepository: EpisodeRepository
    
    // MARK: State
    // MARK: - Draft State
    var draftTitle: String = ""
    var draftCharacterStatement: String = ""
    var draftKeywords: [Keyword] = []
    var draftEpisodes: [Episode] = []
    
    // MARK: - Character State
    var selectedCharacter: Character?
    var allKeywords: [Keyword] = []
    
    // MARK: - Inspector State
    var currentInspectorScreen: InspectorScreen?
    
    // MARK: - UI State
    var searchText = ""
    var isEditingDraft: Bool = false
    
    // MARK: Computed Properties
    var filteredKeywords: [Keyword] {
        allKeywords
            .filter { keyword in
                !draftKeywords.contains(where: { $0.id == keyword.id})
            }
            .filter { keyword in
                searchText.isEmpty || keyword.name.localizedStandardContains(searchText)
            }
    }
    
    var isInspectorPresented: Bool {
        currentInspectorScreen != nil
    }
    
    var isDraftReadyToSave: Bool {
        !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !draftKeywords.isEmpty
    }
    
    // MARK: Initializer
    init(modelContext: ModelContext) {
        self.context = modelContext
        self.characterRepository = CharacterRepository(context: modelContext)
        self.keywordRepository = KeywordRepository(context: modelContext)
        self.episodeRepository = EpisodeRepository(context: modelContext)
    }
    
    // MARK: Functions
    
    // MARK: - CharacterView
    // 새로운 Character 생성 시작
    func startCharacterCreation() {
        draftTitle = ""
        draftCharacterStatement = ""
        draftKeywords = []
        draftEpisodes = []
        selectedCharacter = nil
        currentInspectorScreen = .create
        isEditingDraft = false
        fetchAllKeywords()
    }
        
    // Detail 화면에 표시할 Character 선택
    func selectCharacter(_ character: Character) {
        selectedCharacter = character
        currentInspectorScreen = .detail
    }
    
    // MARK: - CharacterCreateView
    // 저장된 전체 Keyword 조회
    func fetchAllKeywords() {
        do {
            allKeywords = try keywordRepository.fetchAll()
        } catch {
            print("Keyword 조회 실패: \(error)")
        }
    }
    
    // Draft에 Keyword 추가
    func addDraftKeyword(_ keyword: Keyword) {
        if !draftKeywords.contains(where: { $0.id == keyword.id }) {
            draftKeywords.append(keyword)
        }
    }
    
    // Draft에서 Keyword 제거
    // 해당 Keyword와 연결된 Episode도 함께 제거
    func removeDraftKeyword(_ keyword: Keyword) {
        draftKeywords.removeAll { $0.id == keyword.id }
        draftEpisodes.removeAll { $0.keyword.id == keyword.id }
    }
    
    // 선택한 Keyword를 기반으로 Draft 생성
    func generateDraft() {
        if isDraftReadyToSave {
            currentInspectorScreen = .loading
            do {
                draftEpisodes = try episodeRepository.fetch(keywords: draftKeywords)
            }
            catch {
                print("Episode 조회 실패: \(error)")
            }
        }
    }
    
    // MARK: - CharacterLoadingView
    // Draft 화면으로 이동
    func showDraft() {
        currentInspectorScreen = .draft
    }
    
    // MARK: - CharacterDraftView
    // Draft 편집 모드 활성화
    func enableDraftEditing() {
        isEditingDraft = true
    }
    
    // Character 저장 및 생성
    func createCharacter() {
        if isDraftReadyToSave {
            _ = characterRepository.create(title: draftTitle, characterStatement: draftCharacterStatement, keywords: draftKeywords)
            do {
                try context.save()
                currentInspectorScreen = nil
                isEditingDraft = false
            }
            catch {
                print("캐릭터 생성 실패")
            }
        }
    }
    
    // MARK: - Helper Methods
    // 선택한 Keyword에 해당하는 Episode 반환
    func episodesForKeyword(keyword: Keyword) -> [Episode] {
        draftEpisodes.filter { episode in
            episode.keyword.id == keyword.id
        }
    }
    
}
