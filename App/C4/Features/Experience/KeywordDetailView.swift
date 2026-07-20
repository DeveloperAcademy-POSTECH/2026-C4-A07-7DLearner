//
//  KeywordDetailView.swift
//  C4
//
//  Created by 박시은 on 7/19/26.
//

import SwiftUI
import SwiftData

struct KeywordDetailView: View {
    let keyword: Keyword
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
                // MARK: - 헤더 (키워드 명, 에피소드 갯수)
                VStack(alignment: .leading, spacing: 8) {
                    Text(keyword.name)
                        .font(.body)
                        .bold()
                    
                    Text("에피소드 \(keyword.episodes.count)개")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                }
                
                Divider()
                
                // MARK: - 에피소드 리스트
                if keyword.episodes.isEmpty {
                    Text("이 키워드와 관련된 에피소드가 아직 없습니다.")
                        .foregroundStyle(Color.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 40) {
                        ForEach(keyword.episodes) { episode in
                            KeywordEpisodeDetailBlock(episode: episode)
                        }
                    }
                }
            }
            .padding(32)
        }
        .navigationTitle(keyword.name)
    }
}

// MARK: - 키워드 디테일 뷰 전용 에피소드 블록
struct KeywordEpisodeDetailBlock: View {
    let episode: Episode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 경험명: 소제목 포맷
            Text("\(episode.experience.title): \(episode.title)")
                .font(.headline)
            
            // 에피소드 상세 내용
            VStack(alignment: .leading, spacing: 8) {
                DetailTextRow(title: "문제 상황", content: episode.problemContext)
                DetailTextRow(title: "고민 포인트", content: episode.concernPoint)
                DetailTextRow(title: "나의 액션", content: episode.myAction)
                DetailTextRow(title: "성과 및 배움", content: episode.outcome)
            }
            
            // 첨부자료
            if !episode.experience.attachments.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("첨부 자료")
                        .font(.body)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(episode.experience.attachments) { attachment in
                                AttachmentCardView(attachment: attachment)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}
