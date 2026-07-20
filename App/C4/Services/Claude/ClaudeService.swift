//
//  ClaudeService.swift
//  C4
//
//  Created by 이경민 on 7/19/26.
//

import Foundation

final class ClaudeService {
    private let apiKey: String
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-sonnet-4-6"

    init() {
        self.apiKey = Secrets.claudeAPIKey
    }
    
    func testConnection() async throws -> String {
        let requestBody = ClaudeRequest(
            model: model,
            maxTokens: 100,
            messages: [ClaudeMessage(role: "user", content: [.text("안녕? 한 문장으로 인사해줘.")])]
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
        return decoded.content.first?.text ?? "빈 응답"
    }

}
