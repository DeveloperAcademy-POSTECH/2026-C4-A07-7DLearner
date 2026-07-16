//
//  CharacterRepository.swift
//  C4
//
//  Created by YOOJUN PARK on 7/16/26.
//

import SwiftData
import Foundation

struct CharacterRepository {
    
    let context: ModelContext
    
    // MARK: 조회
    func fetchAll() throws -> [Character] {
        try context.fetch(FetchDescriptor<Character>())
    }
    
    // MARK: 생성
    func create(title: String, characterStatement: String, keywords: [Keyword]) -> Character {
        let character = Character(title: title, characterStatement: characterStatement, keywords: keywords)
        context.insert(character)
        return character
    }
    
    // MARK: 삭제 - (Character → Keyword)는 nullify라, 해당 캐릭터를 지워도 Keyword 자체는 유지됨
    func delete(_ character: Character) {
        context.delete(character)
    }
    
}
