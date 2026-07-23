//
//  KeywordRepository.swift
//  C4
//
//  Created by YOOJUN PARK on 7/16/26.
//

import SwiftData
import Foundation

struct KeywordRepository {
    
    let context: ModelContext
    
    // MARK: 조회
    func fetchAll() throws -> [Keyword] {
        try context.fetch(FetchDescriptor<Keyword>())
    }
    
    // MARK: 생성 (중복 키워드 생성은 방지)
    func findOrCreate(name: String) throws -> Keyword {
        
        // 입력값 정규화
        let normalized = Keyword.normalize(name)
        
        // 저장소에서 키워드 탐색
        let descriptor = FetchDescriptor<Keyword>(
            predicate: #Predicate { $0.name == normalized }
        )
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        
        // 저장소에 키워드 없다면 새로 생성
        let new = Keyword(name: normalized)
        context.insert(new)
        return new
        
    }
    
    // MARK: 삭제 - (Keyword → Episode)가 cascade라, 이 키워드에 딸린 Episode도 전부 같이 삭제됨
    func delete(_ keyword: Keyword) {
        context.delete(keyword)
    }
    
}
