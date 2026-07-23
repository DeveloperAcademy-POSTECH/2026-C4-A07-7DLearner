//
//  EpisodeGenerationDTO.swift
//  C4
//
//  Created by YOOJUN PARK on 7/17/26.
//

// Data Transfer Object
// LanguageModel에 필요한 값만 Experience, Attachment Model에서 선별 (LanguageModel <-> App 사이 data object)

import Foundation

// MARK: - LanguageModel 입력 (Experience, Attachment 모델을 직접 넘기지 X 필요한 값만 뽑아서)
struct EpisodeGenerationInput: Codable {
    let keywordNames: [String]
    let experienceStatement: String
    let attachmentTexts: [AttachmentText]
}

struct AttachmentText: Codable {
    let attachmentID: UUID // Episode와 Attachment 연결 위해
    let text: String
}

// MARK: - LanguageModel 출력
struct EpisodeGenerationOutput: Codable {
    let keywordName: String
    let title: String
    let problemContext: String
    let concernPoint: String
    let myAction: String
    let outcome: String
    let sourceExcerpt: String // Attachment의 근거 텍스트 발췌
    let sourceAttachmentID: UUID? // Episode의 근거가 되는 Attachment
}

