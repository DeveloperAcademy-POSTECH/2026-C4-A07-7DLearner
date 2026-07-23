//
//  ExperienceDetailView.swift
//  C4
//
//  Created by 박시은 on 7/18/26.
//

import SwiftUI
import SwiftData

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
            VStack(alignment: .leading, spacing: 28) {
                headerSection
                Divider()
                attachmentSection
                Divider()
                episodeCardsSection
                selectedEpisodeDetailSection
            }
            .padding(30)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .onAppear {
            if selectedKeyword == nil {
                selectedKeyword = activeKeywords.first
            }
        }
    }
}

// MARK: - Subviews for Compiler Optimization
private extension ExperienceDetailView {
    
    // 1. 헤더 (경험명, 키워드, 기간)
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(experience.title)
                .font(Font.custom("SF Pro", size: 16).weight(.bold))
                .foregroundColor(.black)
            
            HStack(alignment: .center) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(experience.keywords) { keyword in
                            KeywordTag(text: keyword.name, style: .selected)
                        }
                    }
                }
                
                Spacer()
                
                Text("\(experience.periodStart, style: .date) - \(experience.periodEnd, style: .date)")
                    .font(Font.custom("SF Pro", size: 12))
                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
            }
        }
    }
    
    // 2. 첨부자료 섹션
    var attachmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "첨부자료")
            
            if experience.attachments.isEmpty {
                Text("첨부된 자료가 없습니다.")
                    .font(Font.custom("SF Pro", size: 12))
                    .foregroundColor(.gray)
                    .padding(.vertical, 4)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(experience.attachments) { attachment in
                            AttachmentCardView(attachment: attachment)
                        }
                    }
                }
            }
        }
    }
    
    // 3. 키워드별 에피소드 카드 섹션
    var episodeCardsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(
                title: "키워드별 에피소드",
                descriptions: "선택한 키워드를 기반으로 AI가 분석한 경험이에요."
            )
            
            if activeKeywords.isEmpty {
                Text("아직 작성된 에피소드가 없습니다.")
                    .font(Font.custom("SF Pro", size: 12))
                    .foregroundColor(.gray)
                    .padding(.vertical, 4)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(activeKeywords) { keyword in
                            let filteredEpisodes = experience.episodes.filter { $0.keyword.id == keyword.id }
                            
                            KeywordEpisodeCard(
                                keyword: keyword,
                                episodes: filteredEpisodes,
                                episodeLimit: 2,
                                showsSummary: true
                            )
                            .padding(20)
                            .frame(width: 230, alignment: .topLeading)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedKeyword?.id == keyword.id ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 0.2)
                                    .stroke(Color(red: 0.53, green: 0.53, blue: 0.53), lineWidth: 0.4)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedKeyword = keyword
                                }
                            }
                            .scaleEffect(selectedKeyword?.id == keyword.id ? 1.02 : 1.0)
                            .animation(.spring(response: 0.3), value: selectedKeyword)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    // 4. 선택된 에피소드 상세 내용 하단 표출 섹션
    @ViewBuilder
    var selectedEpisodeDetailSection: some View {
        if let selected = selectedKeyword,
           activeKeywords.contains(where: { $0.id == selected.id }) {
            
            let filteredEpisodes = experience.episodes.filter {
                $0.keyword.id == selected.id
            }

            VStack(alignment: .leading, spacing: 0) {
                Divider()
                    .padding(.vertical, 30)

                KeywordEpisodeCard(
                    keyword: selected,
                    episodes: filteredEpisodes,
                    episodeLimit: nil,
                    showsSummary: false
                )
            }
        }
    }
    
}

// MARK: - 보조 디자인 컴포넌트들
struct AttachmentCardView: View {
    let attachment: Attachment
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.fileName)
                    .font(Font.custom("SF Pro", size: 13).weight(.medium))
                    .foregroundColor(.black)
                    .lineLimit(1)
                Text("\(attachment.fileType.uppercased()) • \(attachment.formattedFileSize)")
                    .font(Font.custom("SF Pro", size: 11))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(width: 220, alignment: .leading)
        .background(Color.gray.opacity(0.03))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.5), lineWidth: 0.4)
        )
    }
}

// MARK: - Preview
#Preview {
    let container = try! ModelContainer(
        for: Experience.self, Keyword.self, Episode.self, Attachment.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    
    let keyword1 = Keyword(name: "협업")
    let keyword2 = Keyword(name: "문제해결력")
    let keyword3 = Keyword(name: "자기주도성")
    
    let experience = Experience(
        title: "애플 디벨로퍼 아카데미 C3",
        periodStart: Date(),
        periodEnd: Date(),
        experienceStatement: "디자이너 부재 위기 속에서 임시 PM을 맡아 스탠드업 미팅을 도입했다."
    )
    experience.keywords = [keyword1, keyword2, keyword3]
    
    let attachment1 = Attachment(
        fileName: "계산기 앱.Xcode",
        storedFileName: "calc.swift",
        fileType: "Xcode Project",
        fileSize: 185000,
        experience: experience
    )
    
    let episode = Episode(
        title: "디자이너 부재 위기를 넘긴 유연한 역할 분담과 소통",
        problemContext: "출시 3주 전, 메인 디자이너의 하차로 UI 설계가 전면 중단되어 팀 전체가 패닉에 빠졌다.",
        concernPoint: "개발팀과 남은 인원들 사이에서 '누가 이 업무를 맡을 것인가'에 대한 혼선이 생겼다.",
        myAction: "임시 PM 역할을 자처하여 매일 15분 스탠드업 미팅을 도입했다.",
        outcome: "갈등 없이 프로젝트 정상 궤도 복귀 및 기한 내 앱 스토어 제출 완료.",
        sourceExcerpt: "",
        experience: experience,
        keyword: keyword1,
        attachment: attachment1
    )
    
    context.insert(experience)
    
    return ExperienceDetailView(experience: experience)
        .modelContainer(container)
        .frame(width: 850, height: 800)
}
