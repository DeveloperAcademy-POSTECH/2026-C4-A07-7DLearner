//
//  EpisodeGenerating.swift
//  C4
//
//  Created by YOOJUN PARK on 7/17/26.
//

import Foundation

// MARK: LanguageModel 프로토콜
// FoundationModelService, ClaudeService...

protocol EpisodeGenerating {
    func generateEpisodes(input: EpisodeGenerationInput) async throws -> [EpisodeGenerationOutput]
}
