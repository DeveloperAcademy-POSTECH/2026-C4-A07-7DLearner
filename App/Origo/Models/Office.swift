//
//  Office.swift
//  C4
//
//  Created by YOOJUN PARK on 7/22/26.
//

import SwiftData
import Foundation

@Model
final class Office {
    
    // MARK: 식별자
    var id: UUID
    
    // MARK: 사용자 입력값
    var title: String
    
    // MARK: 관계
    @Relationship(inverse: \Character.offices) var characters: [Character] = []
    
    // MARK: 생성자
    init(title: String, characters: [Character]) {
        self.id = UUID()
        self.title = title
        self.characters = characters
    }
    
}

// MARK: - 유효성 검사
extension Office {
    
    // 저장 가능한지 (제목 + 캐릭터 1개 이상)
    var isReadyToSave: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !self.characters.isEmpty
    }
    
}
