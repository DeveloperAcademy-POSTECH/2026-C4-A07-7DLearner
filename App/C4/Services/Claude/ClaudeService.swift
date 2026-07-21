//
//  ClaudeService.swift
//  C4
//
//  Created by 이경민 on 7/19/26.
//

import Foundation

    // MARK: - Claude API 클라이언트 (핵심 설정)
final class ClaudeService {
    private let apiKey: String
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-sonnet-5"
    
    init() {
        self.apiKey = Secrets.claudeAPIKey
    }
}

    // MARK: - 텍스트 요청 / 응답 처리
extension ClaudeService {
    
        // MARK: 범용 텍스트 요청 함수
    func sendText(_ prompt: String, maxTokens: Int = 1024) async throws -> String {
        let requestBody = ClaudeRequest(
            model: model,
            maxTokens: maxTokens,
            messages: [ClaudeMessage(role: "user", content: [.text(prompt)])]
        )
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ClaudeError.apiError("Status \(httpResponse.statusCode): \(errorMessage)")
        }
        
        let decoded = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        guard let text = decoded.content.first(where: { $0.type == "text" })?.text else {
            throw ClaudeError.invalidResponse
        }
        return text
    }
}
