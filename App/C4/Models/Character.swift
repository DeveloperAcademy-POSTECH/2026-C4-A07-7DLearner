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
    init(title: String, characterStatement: String, keywords: [Keyword]) {
        self.id = UUID()
        self.title = title
        self.characterStatement = characterStatement
        self.keywords = keywords
    }
    
}

// MARK: - 유효성 검사
extension Character {
    
    // 저장 가능한지 (제목 + 키워드)
    var isReadyToSave: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !self.keywords.isEmpty // 생성자가 빈 배열을 받아오는 것에 대한 방지
    }
    
}

// MARK: - 파생 데이터 조회
extension Character {
    
    // 이 캐릭터가 가진 키워드들에 포함된 모든 에피소드 조회
    var episodes: [Episode] {
        self.keywords.flatMap { $0.episodes }
    }
    
}
