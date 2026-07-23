//
//  OfficeViewModel.swift
//  C4
//
//  Created by YOOJUN PARK on 7/22/26.
//

import SwiftData
import Observation
import Foundation

@Observable
final class OfficeViewModel {
    
    // MARK: 상태
    var selectedOffice: Office? // 상단에 표시될 활성 오피스
    var selectedCharacter: Character? // 활성 오피스에서 선택된 캐릭터
    var currentInspectorScreen: InspectorScreen? // nil이면 빈 화면
    
    // MARK: 새 오피스 생성 필드
    var draftTitle = ""
    var draftCharacterIDs: Set<UUID> = []
    
    // MARK: 의존성
    private let context: ModelContext
    private let officeRepository: OfficeRepository
    
    // MARK: 생성자
    init(modelContext: ModelContext) {
        self.context = modelContext
        self.officeRepository = OfficeRepository(context: modelContext)
    }
    
}

// MARK: - 선택 로직
extension OfficeViewModel {
    
    // 목록에서 오피스를 선택하면 상단 활성으로
    func activate(_ office: Office) {
        self.selectedCharacter = nil
        self.currentInspectorScreen = nil
        self.selectedOffice = office
    }
    
    // 활성 오피스 내부 Avatar 선택하면 인스펙터에 상세 표시 (nil일 때: 빈 화면)
    func selectCharacter(_ character: Character?) {
        self.selectedCharacter = character
        self.currentInspectorScreen = (character == nil) ? nil : .detail
    }
    
    // toolbar: 새 오피스 생성 버튼
    func startCreating() {
        self.selectedCharacter = nil
        self.draftTitle = ""
        self.draftCharacterIDs = []
        self.currentInspectorScreen = .create
    }
    
    // toolbar: 취소 버튼
    func cancelCreating() {
        self.currentInspectorScreen = nil
    }
    
}

// MARK: - 새 오피스 생성
extension OfficeViewModel {
    
    var isDraftReadyToSave: Bool {
        !self.draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !self.draftCharacterIDs.isEmpty
    }
    
    // 저장 및 새 오피스를 활성으로
    func createOffice(from allCharacters: [Character]) {
        guard self.isDraftReadyToSave else { return }
        
        let selected = allCharacters.filter { self.draftCharacterIDs.contains($0.id) }
        let office = officeRepository.create(title: self.draftTitle, characters: selected)
        try? self.context.save()
        
        self.activate(office)
    }
    
}
