//
//  FoundationModelService.swift
//  C4
//
//  Created by YOOJUN PARK on 7/18/26.
//

import Foundation
import FoundationModels

struct FoundationModelService: EpisodeGenerating {
    
    func generateEpisodes(input: EpisodeGenerationInput) async throws -> [EpisodeGenerationOutput] {
        let session = LanguageModelSession(
            instructions: "당신의 역할은 사용자의 경험 기록에서, 지정된 키워드에 해당하는 에피소드를 찾아 정리하는 것입니다."
        )
        
        let prompt = EpisodePrompt.build(from: input)
        
        let response = try await session.respond(to: prompt)
        let responseText = response.content
        
        return try Self.parse(responseText)
    }
    
}

// MARK: - response parsing
private extension FoundationModelService {
    static func parse(_ responseText: String) throws -> [EpisodeGenerationOutput] {
        
        // FoundationModel이 응답을 마크다운 코드블록(```json [] ```)으로 감싸서 보내므로 제거 필요
        let cleaned = responseText
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleaned.data(using: .utf8) else {
            throw FoundationModelError.invalidResponseEncoding
        }
        
        do {
            return try JSONDecoder().decode([EpisodeGenerationOutput].self, from: data)
        } catch {
            throw FoundationModelError.decodingFailed(rawResponse: responseText, underlying: error)
        }
        
    }
}

enum FoundationModelError: Error {
    case invalidResponseEncoding
    case decodingFailed(rawResponse: String, underlying: Error)
}
