//
//  ClaudeModels.swift
//  C4
//
//  Created by 이경민 on 7/19/26.
//

import Foundation

    // MARK: - Claude API 요청 모델
struct ClaudeRequest: Encodable {
    let model: String
    let maxTokens: Int
    let messages: [ClaudeMessage]
    
    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case messages
    }
}

struct ClaudeMessage: Encodable {
    let role: String
    let content: [ClaudeContentBlock]
}

    // MARK: - 메시지 콘텐츠 블록 (텍스트/문서 등, 현재는 텍스트만 지원)
enum ClaudeContentBlock: Encodable {
    case text(String)
    
    enum CodingKeys: String, CodingKey { case type, text }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .text(let text):
                try container.encode("text", forKey: .type)
                try container.encode(text, forKey: .text)
        }
    }
}

    // MARK: - Claude API 응답 모델
struct ClaudeResponse: Decodable {
    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }
    let content: [ContentBlock]
}
    // MARK: - 에러 타입
enum ClaudeError: Error, LocalizedError {
    case invalidResponse
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "잘못된 응답입니다."
        case .apiError(let message):
            return message
        }
    }
}
