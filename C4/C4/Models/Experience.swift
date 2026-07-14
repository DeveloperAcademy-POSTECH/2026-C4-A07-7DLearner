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
    
    // MARK: 사용자 입력값
    var id: UUID
    var title: String
    var periodStart: Date
    var periodEnd: Date
    var mergedContext: String? // 첨부파일의 모든 내용을 합친 하나의 문자열
    var experienceStatement: String // 사용자 자유 진술
    
    // MARK: AI 생성값
    var myRole: String?
    var teamSize: String?
    var experienceDescription: String?
    var problemContext: String?
    var concernPoint: String?
    var breakthrough: String?
    var myAction: String?
    var outcome: String?
    @Relationship(inverse: \Keyword.experiences)
    var keywords: [Keyword]? = []
    
    // MARK: 메타데이터
    var isFavorite: Bool
    var createdAt: Date
    
    init(title: String, periodStart: Date, periodEnd: Date, experienceStatement: String) {
        self.id = UUID()
        self.title = title
        self.periodStart = periodStart
        self.periodEnd = periodEnd
        self.experienceStatement = experienceStatement
        self.isFavorite = false
        self.createdAt = .now
    }
    
}
