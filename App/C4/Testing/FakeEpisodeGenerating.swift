//
//  FakeEpisodeGenerating.swift
//  C4
//

import Foundation

// MARK: - 수동 검증용 EpisodeGenerating 스텁
// 실제 Claude API를 호출하지 않고, 지정한 지연 시간 뒤에 성공/실패를 재현한다.
// KeywordLoadingView의 #Preview 및 RootView 개발용 배선에서 사용.
struct FakeEpisodeGenerating: EpisodeGenerating {

    enum Outcome {
        case success(after: TimeInterval)
        case failure(after: TimeInterval, message: String)
    }

    let outcome: Outcome

    func generateEpisodes(input: EpisodeGenerationInput) async throws -> [EpisodeGenerationOutput] {
        switch outcome {
        case .success(let delay):
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            return []
        case .failure(let delay, let message):
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            throw ClaudeError.apiError(message)
        }
    }
}
