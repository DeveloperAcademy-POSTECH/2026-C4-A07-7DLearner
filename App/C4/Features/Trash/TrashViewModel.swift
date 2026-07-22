//
//  TrashViewModel.swift
//  C4
//
//  Created by YOOJUN PARK on 7/22/26.
//

import SwiftData
import Observation
import Foundation

// MARK: - 휴지통 탭
enum TrashTab: String, CaseIterable {
    case keyword = "키워드"
    case character = "캐릭터"
    case experience = "경험"
}

// MARK: - 리스트에서 선택된 항목 - Tab에 따라 데이터모델이 다르기에
enum TrashSelection: Hashable {
    case keyword(Keyword)
    case character(Character)
    case experience(Experience)
}

@Observable
final class TrashViewModel {
    
    // MARK: 상태
    var selectedTab: TrashTab = .keyword
    var selection: TrashSelection?
    var currentInspectorScreen: InspectorScreen?
    var isShowingDeleteConfirmation = false
    
    // MARK: 의존성
    private let context: ModelContext
    private let keywordRepository: KeywordRepository
    private let characterRepository: CharacterRepository
    private let experienceRepository: ExperienceRepository
    
    // MARK: 생성자
    init(modelContext: ModelContext) {
        self.context = modelContext
        self.keywordRepository = KeywordRepository(context: modelContext)
        self.characterRepository = CharacterRepository(context: modelContext)
        self.experienceRepository = ExperienceRepository(context: modelContext)
    }
    
}

// MARK: - 선택 / 인스펙터
extension TrashViewModel {
    
    var isInspectorPresented: Bool {
        self.currentInspectorScreen != nil
    }
    
    // 리스트에서 항목을 선택하면 인스펙터에 상세 표시
    func select(_ item: TrashSelection) {
        self.selection = item
        self.currentInspectorScreen = .detail
    }
    
    // 탭 전환 시 이전 탭의 선택 해제
    func changeTab(to tab: TrashTab) {
        self.selectedTab = tab
        self.selection = nil
        self.currentInspectorScreen = nil
    }
    
}

// MARK: - 영구삭제
extension TrashViewModel {
    
    // 툴바의 휴지통 버튼 → 확인 팝업
    func requestDelete() {
        guard self.selection != nil else { return }
        self.isShowingDeleteConfirmation = true
    }
    
    // 팝업 확정 → Repository 통해 삭제
    func deleteSelected() {
        guard let selection = self.selection else { return }
        
        switch selection {
        case .keyword(let keyword):
            self.keywordRepository.delete(keyword)
        case .character(let character):
            self.characterRepository.delete(character)
        case .experience(let experience):
            self.experienceRepository.delete(experience)
        }
        
        try? self.context.save()
        self.selection = nil
        self.currentInspectorScreen = nil
    }
    
}
