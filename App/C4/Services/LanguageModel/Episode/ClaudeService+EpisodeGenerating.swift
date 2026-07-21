//
//  ClaudeService+EpisodeGenerating.swift
//  C4
//
//  Created by 이경민 on 7/19/26.
//

import Foundation

    // MARK: - EpisodeGenerating 프로토콜 채택 (Claude가 에피소드 생성 담당)
extension ClaudeService: EpisodeGenerating {
    
        // MARK: 에피소드 생성 진입점
    func generateEpisodes(input: EpisodeGenerationInput) async throws -> [EpisodeGenerationOutput] {
        let prompt = EpisodePrompt.build(from: input)
        let responseText = try await sendText(prompt, maxTokens: 4096)
        return try Self.parseEpisodes(from: responseText)
    }
    
        // MARK: - Claude 응답 파싱
    private static func parseEpisodes(from text: String) throws -> [EpisodeGenerationOutput] {
            // Claude가 ```json ... ``` 코드블록으로 감싸서 응답하는 경우가 있어 제거
        let cleaned = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleaned.data(using: .utf8) else {
            throw ClaudeError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([EpisodeGenerationOutput].self, from: data)
        } catch {
            throw ClaudeError.apiError("JSON 파싱 실패: \(error.localizedDescription)\n원본: \(cleaned.prefix(500))")
        }
    }
}
