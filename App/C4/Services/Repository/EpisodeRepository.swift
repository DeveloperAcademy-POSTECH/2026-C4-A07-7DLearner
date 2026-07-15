//
//  EpisodeRepository.swift
//  C4
//
//  Created by YOOJUN PARK on 7/16/26.
//

import SwiftData
import Foundation

struct EpisodeRepository {
    
    let context: ModelContext
    
    // MARK: 조회 - 키워드 기준 (키워드 상세화면)
    func fetch(keyword: Keyword) throws -> [Episode] {
        let targetId = keyword.id
        let descriptor = FetchDescriptor<Episode>(
            predicate: #Predicate { $0.keyword.id == targetId }
        )
        return try context.fetch(descriptor)
    }
    
    // MARK: 조회 - 경험 기준 (경험 상세화면)
    func fetch(experience: Experience) throws -> [Episode] {
        let targetId = experience.id
        let descriptor = FetchDescriptor<Episode>(
            predicate: #Predicate { $0.experience.id == targetId }
        )
        return try context.fetch(descriptor)
    }
    
    // MARK: 조회 - 여러 키워드 기준 (캐릭터 상세화면)
    func fetch(keywords: [Keyword]) throws -> [Episode] {
        let targetIds = keywords.map { $0.id }
        let descriptor = FetchDescriptor<Episode>(
            predicate: #Predicate { targetIds.contains($0.keyword.id) }
        )
        return try context.fetch(descriptor)
    }
    
    // MARK: 생성
    func create(
        title: String,
        problemContext: String,
        concernPoint: String,
        myAction: String,
        outcome: String,
        sourceExcerpt: String,
        experience: Experience,
        keyword: Keyword,
        attachment: Attachment? = nil
    ) -> Episode {
        let episode = Episode(
            title: title,
            problemContext: problemContext,
            concernPoint: concernPoint,
            myAction: myAction,
            outcome: outcome,
            sourceExcerpt: sourceExcerpt,
            experience: experience,
            keyword: keyword,
            attachment: attachment
        )
        context.insert(episode)
        return episode
    }
    
    // MARK: 삭제
    func delete(_ episode: Episode) {
        context.delete(episode)
    }
    
}
