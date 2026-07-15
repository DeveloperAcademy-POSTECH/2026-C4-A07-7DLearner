//
//  Character.swift
//  C4
//
//  Created by YOOJUN PARK on 7/13/26.
//

import SwiftData
import Foundation

@Model
final class Character {
    
    // MARK: 식별자
    var id: UUID
    
    // MARK: 사용자 입력값
    var title: String
    var characterStatement: String // 캐릭터 생성 시 입력 받는 '캐릭터 설명'
    
    // MARK: 관계
    @Relationship(inverse: \Keyword.characters) var keywords: [Keyword] = []
    
    // MARK: 생성자
    init(title: String, characterStatement: String) {
        self.id = UUID()
        self.title = title
        self.characterStatement = characterStatement
    }
    
}

// MARK: - 유효성 검사
extension Character {
    
    // 저장 가능한지 (제목 + 키워드)
    var isReadyToSave: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !self.keywords.isEmpty
    }
    
}
