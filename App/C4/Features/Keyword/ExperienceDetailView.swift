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
                // MARK: - 헤더 (경험명, 키워드, 기간)
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center) {
                        Text(experience.title)
                            .font(Font.custom("SF Pro", size: 16).weight(.bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // 기간 (오른쪽 정렬)
                        Text("\(experience.periodStart, style: .date) - \(experience.periodEnd, style: .date)")
                            .font(Font.custom("SF Pro", size: 12))
                            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                    }
                    
                    // 경험에 연결된 키워드 태그들 (가로 정렬)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(experience.keywords) { keyword in
                                KeywordTag(text: keyword.name, style: .selected)
                            }
                        }
                    }
                }
                
                Divider()
                
                // MARK: - 첨부자료
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "첨부자료")
                    
                    if experience.attachments.isEmpty {
                        Text("첨부된 자료가 없습니다.")
                            .font(Font.custom("SF Pro", size: 12))
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
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
                
                Divider()
                
                // MARK: - 키워드별 에피소드 (가로 스크롤 카드 영역)
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(
                        title: "키워드별 에피소드",
                        descriptions: "선택한 키워드를 기반으로 AI가 분석한 경험이에요."
                    )
                    
                    if activeKeywords.isEmpty {
                        Text("아직 작성된 에피소드가 없습니다.")
                            .font(Font.custom("SF Pro", size: 12))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(activeKeywords) { keyword in
                                    let filteredEpisodes = experience.episodes.filter { $0.keyword.id == keyword.id }
                                    
                                    KeywordEpisodeCard(
                                        keyword: keyword,
                                        episodes: filteredEpisodes
                                    )
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
                
                // MARK: - 선택된 에피소드 상세 내용 하단 표출 영역
                if let selected = selectedKeyword, activeKeywords.contains(where: { $0.id == selected.id }) {
                    Divider()
                        .padding(.vertical, 10)
                    
                    let filteredEpisodes = experience.episodes.filter { $0.keyword.id == selected.id }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // 선택된 키워드 태그 표시
                        HStack(spacing: 6) {
                            Image(systemName: "tag")
                                .font(.system(size: 10))
                                .foregroundStyle(.blue)
                                .padding(4)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue.opacity(0.25)))
                            
                            Text(selected.name)
                                .font(Font.custom("SF Pro", size: 14).weight(.semibold))
                            
                            Text("\(filteredEpisodes.count)")
                                .font(.system(size: 10))
                                .frame(width: 18, height: 18)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.1)))
                        }
                        
                        // 에피소드 세부 내용 리스트
                        ForEach(filteredEpisodes) { episode in
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(episode.experience.title): \(episode.title)")
                                    .font(Font.custom("SF Pro", size: 13).weight(.bold))
                                    .foregroundColor(.black)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    DetailTextRow(title: "문제상황", content: episode.problemContext)
                                    DetailTextRow(title: "고민포인트", content: episode.concernPoint)
                                    DetailTextRow(title: "나의 액션", content: episode.myAction)
                                    DetailTextRow(title: "성과 및 배움", content: episode.outcome)
                                }
                                .font(Font.custom("SF Pro", size: 13))
                                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                                .lineSpacing(4)
                            }
                            .padding(.top, 4)
                        }
                    }
                }
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
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
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
    }
}

// MARK: - Preview
#Preview {
    let container = try! ModelContainer(
        for: Experience.self, Keyword.self, Episode.self, Attachment.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    
    // 1. 가상 키워드 생성
    let keyword1 = Keyword(name: "협업")
    let keyword2 = Keyword(name: "문제해결력")
    let keyword3 = Keyword(name: "자기주도성")
    
    // 2. 가상 경험 생성
    let experience = Experience(
        title: "애플 디벨로퍼 아카데미 C3",
        periodStart: Date(),
        periodEnd: Date(),
        experienceStatement: "디자이너 부재 위기 속에서 임시 PM을 맡아 스탠드업 미팅을 도입했다."
    )
    experience.keywords = [keyword1, keyword2, keyword3]
    
    // 3. 가상 첨부파일 생성
    let attachment1 = Attachment(
        fileName: "계산기 앱.Xcode",
        storedFileName: "calc.swift",
        fileType: "Xcode Project",
        fileSize: 185000,
        experience: experience
    )
    let attachment2 = Attachment(
        fileName: "팀원 회고.PDF",
        storedFileName: "review.pdf",
        fileType: "PDF 문서",
        fileSize: 604000,
        experience: experience
    )
    
    // 4. 가상 에피소드 생성
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
