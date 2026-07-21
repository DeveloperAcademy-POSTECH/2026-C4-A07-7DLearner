//
//  KeywordLoadingDevPreview.swift
//  C4
//

import SwiftUI
import SwiftData

// MARK: - RootView "경험" 탭 개발용 배선
// 폼→분석버튼→KeywordLoadingView 연결(실제 플로우)은 범위 밖이라, 그때까지 이 화면으로 눈으로 확인한다.
// 실제 Claude API 키 없이 확인할 수 있도록 FakeEpisodeGenerating을 사용한다.
struct KeywordLoadingDevPreview: View {
    @Environment(\.modelContext) private var modelContext
    @State private var experience: Experience?

    var body: some View {
        if let experience {
            KeywordLoadingView(
                experience: experience,
                manager: EpisodeGenerationManager(
                    modelContext: modelContext,
                    episodeGenerating: FakeEpisodeGenerating(outcome: .success(after: 5))
                ),
                onComplete: {}
            )
        } else {
            Color.clear.onAppear {
                let sample = ExperienceRepository(context: modelContext).create(
                    title: "샘플 경험",
                    periodStart: .now,
                    periodEnd: .now,
                    experienceStatement: "로딩 화면 확인용 샘플 경험 진술입니다."
                )
                if let keyword = try? KeywordRepository(context: modelContext).findOrCreate(name: "샘플키워드") {
                    sample.keywords = [keyword]
                }
                experience = sample
            }
        }
    }
}
