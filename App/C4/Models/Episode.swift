//
//  Episode.swift
//  C4
//
//  Created by YOOJUN PARK on 7/15/26.
//

import SwiftData
import Foundation

@Model
final class Episode {
    
    // MARK: 식별자
    var id: UUID
    
    // MARK: 시스템(LLM) 생성값
    var title: String
    var problemContext: String
    var concernPoint: String
    var myAction: String
    var outcome: String
    var sourceExcerpt: String // Attachment의 발췌 String
    
    // MARK: 관계
    @Relationship(inverse: \Experience.episodes) var experience: Experience
    @Relationship(inverse: \Keyword.episodes) var keyword: Keyword
    @Relationship(inverse: \Attachment.episodes) var attachment: Attachment? // 원본 Attachment
    
    // MARK: 생성자
    init(title: String, problemContext: String, concernPoint: String, myAction: String, outcome: String, sourceExcerpt: String, experience: Experience, keyword: Keyword, attachment: Attachment? = nil) {
        self.id = UUID()
        self.title = title
        self.problemContext = problemContext
        self.concernPoint = concernPoint
        self.myAction = myAction
        self.outcome = outcome
        self.sourceExcerpt = sourceExcerpt
        self.experience = experience
        self.keyword = keyword
        self.attachment = attachment
    }
    
}

// MARK: - 유효성 검사
extension Episode {
    
    // 원본 attachment로 추적 가능한지
    var hasAttachment: Bool {
        self.attachment != nil
    }
    
    // 시스템(LLM)이 다섯 필드 모두 채웠는지
    var isComplete: Bool {
        !self.title.isEmpty
        && !self.problemContext.isEmpty
        && !self.concernPoint.isEmpty
        && !self.myAction.isEmpty
        && !self.outcome.isEmpty
    }
    
}
