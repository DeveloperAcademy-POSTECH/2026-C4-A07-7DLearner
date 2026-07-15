//
//  Experience.swift
//  C4
//
//  Created by YOOJUN PARK on 7/13/26.
//

import SwiftData
import Foundation

@Model
final class Experience {
    
    // MARK: 식별자
    var id: UUID
    
    // MARK: 사용자 입력값
    var title: String
    var periodStart: Date
    var periodEnd: Date
    var experienceStatement: String // 키워드 생성 시 입력 받는 '경험진술'
    
    // MARK: 관계
    @Relationship(inverse: \Keyword.experiences) var keywords: [Keyword] = []
    @Relationship(deleteRule: .cascade) var attachments: [Attachment] = []
    @Relationship(deleteRule: .cascade) var episodes: [Episode] = []
    
    // MARK: 생성자
    init(title: String, periodStart: Date, periodEnd: Date, experienceStatement: String) {
        self.id = UUID()
        self.title = title
        self.periodStart = periodStart
        self.periodEnd = periodEnd
        self.experienceStatement = experienceStatement
    }
    
}

// MARK: - 유효성 검사
extension Experience {
    
    // 기간 올바른지
    var hasValidPeriod: Bool {
        self.periodStart <= self.periodEnd
    }
    
    // 저장 가능한지 (제목 + 기간 + 키워드)
    var isReadyToSave: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && self.hasValidPeriod
        && !self.keywords.isEmpty
        
    }
}
