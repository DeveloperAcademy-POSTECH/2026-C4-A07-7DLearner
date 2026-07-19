//
//  ClaudeModels.swift
//  C4
//
//  Created by 이경민 on 7/19/26.
//

import Foundation

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

struct ClaudeResponse: Decodable {
    struct ContentBlock: Decodable { let text: String? }
    let content: [ContentBlock]
}

enum ClaudeError: Error {
    case invalidResponse
    case apiError(String)
}
