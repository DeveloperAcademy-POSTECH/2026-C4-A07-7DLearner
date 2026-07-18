//
//  ExperienceDetailView.swift
//  C4
//
//  Created by 박시은 on 7/18/26.
//

import SwiftUI

struct ExperienceDetailView: View {
    let experience: Experience
    
    @State private var selectedKeyword: Keyword?
    
    // 에피소드가 1개 이상인 활성화된 키워드만 걸러내기
    var activeKeywords: [Keyword] {
        experience.keywords.filter { keyword in
            experience.episodes.contains(where: { $0.keyword.id == keyword.id })
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // MARK: - 헤더 (경험명, 키워드, 기간)
                VStack(alignment: .leading, spacing: 12) {
                    Text(experience.title)
                        .font(.body)
                        .bold()
                    
                    HStack {
                        // 경험에 연결된 키워드
                        ForEach(experience.keywords) { keyword in
                            Text(keyword.name)
                                .font(.callout)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(Color.blue)
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        // 기간
                        Text("\(experience.periodStart, style: .date)-\(experience.periodEnd, style: .date)")
                            .font(.callout)
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                Divider()
                
                // MARK: - 첨부자료
                VStack(alignment: .leading, spacing: 12) {
                    Text("첨부자료")
                        .font(.body)
                    
                    if experience.attachments.isEmpty {
                        Text("첨부된 자료가 없습니다.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(experience.attachments) { attachment in
                                    AttachmentCardView(attachment: attachment)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // MARK: - 키워드별 에피소드
                VStack(alignment: .leading, spacing: 12) {
                    Text("키워드별 에피소드")
                        .font(.body)
                    
                    if activeKeywords.isEmpty {
                        Text("아직 작성된 에피소드가 없습니다.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("선택한 키워드를 기반으로 AI가 분석한 경험이에요.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(activeKeywords) { keyword in
                                    Button(action: {
                                        withAnimation {
                                            selectedKeyword = keyword
                                        }
                                    }) {
                                        KeywordEpisodeBlock(
                                            keyword: keyword,
                                            experience: experience,
                                            isSelected: selectedKeyword == keyword
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                
                if selectedKeyword != nil && !activeKeywords.isEmpty {
                    Divider()
                        .padding(.vertical, 8)
                }
                // MARK: - 에피소드 상세보기
                if let selected = selectedKeyword, activeKeywords.contains(where: { $0.id == selected.id }) {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            Image(systemName: "tag.fill")
                            Text(selected.name)
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        
                        let filteredEpisodes = experience.episodes.filter { $0.keyword.id == selected.id }
                        
                        ForEach(filteredEpisodes) { episode in
                            EpisodeDetailRow(episode: episode)
                        }
                    }
                }
                
            }
            .padding(32)
        }
        .onAppear {
            if selectedKeyword == nil {
                selectedKeyword = activeKeywords.first
            }
        }
    }
}

// MARK: - 디자인 컴포넌트들
struct AttachmentCardView: View {
    let attachment: Attachment
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(attachment.fileName)
                .font(.headline)
                .lineLimit(1)
            Text("\(attachment.fileType) • \(attachment.formattedFileSize)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(width: 200, height: 64, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct KeywordEpisodeBlock: View {
    let keyword: Keyword
    let experience: Experience
    let isSelected: Bool
    
    var filteredEpisodes: [Episode] {
        experience.episodes.filter { $0.keyword.id == keyword.id }
    }
    
    var episodeCount: Int {
        filteredEpisodes.count
    }
    
    var firstEpisodeTitle: String {
        filteredEpisodes.first?.title ?? "작성된 에피소드가 없습니다."
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(isSelected ? .blue : .gray)
                Text(keyword.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .blue : .primary)
                
                Text("\(episodeCount)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            Text("\(experience.title): \(firstEpisodeTitle)")
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
        .padding(16)
        .frame(width: 280, height: 120, alignment: .topLeading)
        .background(isSelected ? Color.blue.opacity(0.05) : Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct EpisodeDetailRow: View {
    let episode: Episode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(episode.experience.title): \(episode.title)")
                .font(.headline)
                .padding(.bottom, 4)
            
            DetailTextRow(title: "문제 상황", content: episode.problemContext)
            DetailTextRow(title: "고민 포인트", content: episode.concernPoint)
            DetailTextRow(title: "나의 액션", content: episode.myAction)
            DetailTextRow(title: "성과 및 배움", content: episode.outcome)
        }
    }
}

struct DetailTextRow: View {
    let title: String
    let content: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Text("•")
            Text("\(title):").bold()
            Text(content)
        }
        .font(.body)
        .foregroundColor(.primary)
    }
}
