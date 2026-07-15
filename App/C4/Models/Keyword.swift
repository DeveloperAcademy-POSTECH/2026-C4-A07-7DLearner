//
//  Keyword.swift
//  C4
//
//  Created by YOOJUN PARK on 7/13/26.
//

import SwiftData
import Foundation

@Model
final class Keyword {
    
    // MARK: 식별자
    var id: UUID
    
    // MARK: 사용자 입력 값
    @Attribute(.unique) var name: String
    
    // MARK: 관계
    var experiences: [Experience] = []
    var characters: [Character] = []
    @Relationship(deleteRule: .cascade) var episodes: [Episode] = []
    
    // MARK: 생성자
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
    
}

// MARK: - 입력값 정규화
extension Keyword {
    
    // "회복 탄력성" / "회복탄력성" → "회복탄력성"
    // "UX" / "ux" → "ux"
    static func normalize(_ rawName: String) -> String {
        rawName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .lowercased()
    }
    
}
