//
//  KeywordEpisodeCard.swift
//  C4
//
//  Created by jiwon hong on 7/20/26.
//

import SwiftUI
import SwiftData

struct KeywordEpisodeCard: View {
    
    let keyword: Keyword
    let episodes: [Episode]
    let episodeLimit: Int?
    let showsSummary: Bool
    
    private var displayedEpisodes: [Episode] {
        if let episodeLimit {
            return Array(episodes.prefix(episodeLimit))
        } else {
            return episodes
        }
    }
    
    @ViewBuilder
    private func bulletRow(label: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text("\(label): \(content)")
        }
        .font(
            Font.custom("SF Pro", size: 10)
                .weight(.medium)
        )
        .foregroundColor(
            Color(red: 0.45, green: 0.45, blue: 0.45)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "tag")
                    .font(.system(size: 10))
                    .foregroundStyle(.blue)
                    .padding(3)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.25))
                    )
                
                Text(keyword.name)
                    .font(
                        Font.custom("SF Pro", size: 12)
                            .weight(.semibold)
                    )
                
                Text("\(episodes.count)")
                    .font(.system(size: 10))
                    .frame(width: 15, height: 15)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.125))
                    )
            }
            
            ForEach(displayedEpisodes, id: \.id) { episode in
                VStack(alignment: .leading, spacing: 10) {

                    Text("\(episode.experience.title): \(episode.title)")
                        .font(
                        Font.custom("SF Pro", size: 10)
                        .weight(.semibold)
                        )
                        .foregroundColor(.black)
                        .lineLimit(showsSummary ? 2 : nil)

                    if showsSummary {
                        Text(episode.outcome)
                            .font(
                                Font.custom("SF Pro", size: 10)
                                    .weight(.medium)
                            )
                            .lineLimit(2)
                            .foregroundColor(
                                Color(red: 0.45, green: 0.45, blue: 0.45)
                            )
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            bulletRow(label: "문제 상황", content: episode.problemContext)
                            bulletRow(label: "고민 포인트", content: episode.concernPoint)
                            bulletRow(label: "나의 액션", content: episode.myAction)
                            bulletRow(label: "성과 및 배움", content: episode.outcome)
                        }
                    }
                }
            }        }
    }
}

// MARK: - Preview
//#Preview {
//    let keyword = Keyword(name: "협업")
//
//    let experience = Experience(
//        title: "C4 프로젝트",
//        periodStart: .now,
//        periodEnd: .now,
//        experienceStatement: "사용자 중심 서비스를 기획했다."
//    )
//
//    let attachment = Attachment(
//        fileName: "sample.pdf",
//        storedFileName: "sample.pdf",
//        fileType: "pdf",
//        fileSize: 1024,
//        experience: experience
//    )
//
//    let episode = Episode(
//        title: "역할 분담",
//        problemContext: "팀원 간 역할이 겹쳤다. ",
//        concernPoint: "일정이 지연될 수 있었다. ",
//        myAction: "업무를 재분배했다. ",
//        outcome: "프로젝트를 일정 내 완료했다.",
//        sourceExcerpt: "",
//        experience: experience,
//        keyword: keyword,
//        attachment: attachment
//    )
//
//    KeywordEpisodeCard(
//        keyword: keyword,
//        episodes: [episode]
//    )
//    .padding()
//}
