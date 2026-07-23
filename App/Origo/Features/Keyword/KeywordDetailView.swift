//
//  KeywordDetailView.swift
//  C4
//
//  Created by 박시은 on 7/20/26.
//

import SwiftUI
import SwiftData

struct KeywordDetailView: View {
    
    let keyword: Keyword
    let episodes: [Episode]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                
                Text("상세보기")
                    .font(Font.custom("SF Pro", size: 17).weight(.bold))
                    .foregroundColor(.black)
                
                twoColumnOverviewSection
                
                Divider()
                
                episodesSection
            }
            .padding(30)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

// MARK: - Subviews
private extension KeywordDetailView {
    
    // 2열 구조 개요 섹션 (경험명/기간 | 첨부자료)
    var twoColumnOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let firstEpisode = episodes.first {
                let experience = firstEpisode.experience
                
                HStack(alignment: .top, spacing: 20) {
                    // 왼쪽: 경험 명 & 기간
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("경험 명").font(.title3.weight(.medium))
                            fieldBox(experience.title)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("기간").font(.title3.weight(.medium))
                            HStack(spacing: 8) {
                                fieldBox(experience.periodStart.formatted(.dateTime.year().month().day()))
                                Text("—").foregroundStyle(.secondary)
                                fieldBox(experience.periodEnd.formatted(.dateTime.year().month().day()))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 오른쪽: 첨부자료
                    VStack(alignment: .leading, spacing: 6) {
                        Text("첨부자료").font(.title3.weight(.medium))
                        
                        if experience.attachments.isEmpty {
                            fieldBox("첨부된 자료가 없습니다.")
                                .foregroundColor(.secondary)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(experience.attachments) { attachment in
                                    HStack(spacing: 8) {
                                        Text(attachment.fileName)
                                            .font(Font.custom("SF Pro", size: 13).weight(.medium))
                                            .foregroundColor(.black)
                                            .lineLimit(1)
                                        Spacer()
                                        Text(attachment.fileType.uppercased())
                                            .font(Font.custom("SF Pro", size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8.5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                Text("연결된 경험 정보가 없습니다.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // 읽기 전용 필드 박스 스타일
    func fieldBox(_ text: String) -> some View {
        Text(text)
            .lineLimit(2)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
    
    // 하단 에피소드 섹션 (태그 + 에피소드 내용들)
    var episodesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "tag")
                    .font(.system(size: 10))
                    .foregroundStyle(.blue)
                    .padding(4)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue.opacity(0.25)))
                
                Text(keyword.name)
                    .font(Font.custom("SF Pro", size: 14).weight(.semibold))
                
                Text("\(episodes.count)")
                    .font(.system(size: 10))
                    .frame(width: 18, height: 18)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.1)))
            }
            
            ForEach(episodes, id: \.id) { episode in
                episodeBullets(episode)
                if episode.id != episodes.last?.id {
                    Divider().padding(.vertical, 8)
                }
            }
        }
    }
    
    // 개별 에피소드 불릿 포맷
    func episodeBullets(_ episode: Episode) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(episode.experience.title): \(episode.title)")
                .font(.body.weight(.bold))
                .foregroundColor(.black)
            
            bulletRow(label: "문제 상황", content: episode.problemContext)
            bulletRow(label: "고민 포인트", content: episode.concernPoint)
            bulletRow(label: "나의 액션", content: episode.myAction)
            bulletRow(label: "성과 및 배움", content: episode.outcome)
        }
        .padding(.top, 4)
    }
    
    func bulletRow(label: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text("•")
            Text("\(label):").fontWeight(.semibold)
            Text(content)
        }
        .font(.callout)
        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
    }
}
