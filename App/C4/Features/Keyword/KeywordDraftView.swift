// //
// //  KeywordDraftView.swift
// //  C4
// //
// //  Created by 박시은 on 7/21/26.
// //
//
// import SwiftUI
// import SwiftData
//
// struct KeywordDraftView: View {
//     
//     @Bindable var viewModel: KeywordViewModel
//     
//     // 어떤 카드가 선택되었는지 기억하는 상태값
//     @State private var selectedEpisodeKeyword: Keyword?
//     
//     var body: some View {
//         ScrollView {
//             VStack(alignment: .leading, spacing: 24) {
//                 // MARK: - 상단 타이틀
//                 titleSection
//                 
//                 // MARK: - 좌우 2분할 레이아웃 (경험명/기간 박스 / 첨부자료 박스)
//                 HStack(alignment: .top, spacing: 24) {
//                     // [왼쪽 영역] 경험 명 & 기간 박스
//                     VStack(alignment: .leading, spacing: 20) {
//                         // 경험 명
//                         VStack(alignment: .leading, spacing: 10) {
//                             SectionHeader(title: "경험 명")
//                             
//                             HStack {
//                                 Text(viewModel.draftExperienceTitle.isEmpty ? "입력된 경험 명이 없습니다." : viewModel.draftExperienceTitle)
//                                     .font(Font.custom("SF Pro", size: 13))
//                                     .foregroundColor(.black)
//                                 Spacer()
//                             }
//                             .padding(.horizontal, 12)
//                             .padding(.vertical, 8)
//                             .background(Color.gray.opacity(0.03))
//                             .cornerRadius(8)
//                             .overlay(
//                                 RoundedRectangle(cornerRadius: 8)
//                                     .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
//                             )
//                         }
//                         
//                         // 기간 (시작일, 종료일 각각 독립된 네모 박스)
//                         VStack(alignment: .leading, spacing: 10) {
//                             SectionHeader(title: "기간")
//                             
//                             HStack(spacing: 8) {
//                                 // 시작 날짜 박스
//                                 HStack {
//                                     Text(Self.dateString(viewModel.draftStartDate))
//                                         .font(Font.custom("SF Pro", size: 13))
//                                         .foregroundColor(.black)
//                                     Spacer()
//                                 }
//                                 .padding(.horizontal, 12)
//                                 .padding(.vertical, 8)
//                                 .background(Color.gray.opacity(0.03))
//                                 .cornerRadius(8)
//                                 .overlay(
//                                     RoundedRectangle(cornerRadius: 8)
//                                         .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
//                                 )
//
//                                 Text("—")
//                                     .foregroundColor(.gray)
//
//                                 // 종료 날짜 박스
//                                 HStack {
//                                     Text(Self.dateString(viewModel.draftEndDate))
//                                         .font(Font.custom("SF Pro", size: 13))
//                                         .foregroundColor(.black)
//                                     Spacer()
//                                 }
//                                 .padding(.horizontal, 12)
//                                 .padding(.vertical, 8)
//                                 .background(Color.gray.opacity(0.03))
//                                 .cornerRadius(8)
//                                 .overlay(
//                                     RoundedRectangle(cornerRadius: 8)
//                                         .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
//                                 )
//                             }
//                         }
//                     }
//                     .frame(maxWidth: .infinity, alignment: .leading)
//                     
//                     // [오른쪽 영역] 첨부자료 박스
//                     VStack(alignment: .leading, spacing: 10) {
//                         SectionHeader(title: "첨부자료")
//                         
//                         if viewModel.draftAttachedFiles.isEmpty {
//                             Text("첨부된 자료가 없습니다.")
//                                 .font(Font.custom("SF Pro", size: 12))
//                                 .foregroundColor(.gray)
//                                 .padding(.vertical, 8)
//                         } else {
//                             VStack(spacing: 8) {
//                                 ForEach(viewModel.draftAttachedFiles) { file in
//                                     HStack(spacing: 8) {
//                                         Image(systemName: "doc.text")
//                                             .foregroundColor(.black)
//                                             .font(.system(size: 12))
//                                         Text(file.fileName)
//                                             .font(Font.custom("SF Pro", size: 13))
//                                             .foregroundColor(.black)
//                                         Spacer()
//                                     }
//                                     .padding(.horizontal, 12)
//                                     .padding(.vertical, 8)
//                                     .background(Color.gray.opacity(0.03))
//                                     .cornerRadius(8)
//                                     .overlay(
//                                         RoundedRectangle(cornerRadius: 8)
//                                             .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
//                                     )
//                                 }
//                             }
//                         }
//                     }
//                     .frame(maxWidth: .infinity, alignment: .leading)
//                 }
//                 
//                 Divider()
//                 
//                 // MARK: - 키워드별 에피소드 카드 (가로 스크롤)
//                 VStack(alignment: .leading, spacing: 10) {
//                     SectionHeader(
//                         title: "키워드별 에피소드",
//                         descriptions: "선택한 키워드를 기반으로 AI가 분석한 경험이에요."
//                     )
//                     
//                     ScrollView(.horizontal, showsIndicators: false) {
//                         HStack(spacing: 12) {
//                             ForEach(viewModel.generatedKeywords, id: \.id) { keyword in
//                                 let filteredEpisodes = viewModel.generatedEpisodes.filter { $0.keyword.id == keyword.id }
//                                 
//                                 KeywordEpisodeCard(
//                                     keyword: keyword,
//                                     episodes: filteredEpisodes
//                                 )
//                                 .onTapGesture {
//                                     withAnimation(.spring(response: 0.3)) {
//                                         selectedEpisodeKeyword = keyword
//                                     }
//                                 }
//                                 .scaleEffect(selectedEpisodeKeyword?.id == keyword.id ? 1.02 : 1.0)
//                                 .animation(.spring(response: 0.3), value: selectedEpisodeKeyword)
//                             }
//                         }
//                         .padding(.vertical, 4)
//                     }
//                 }
//                 
//                 // MARK: - 선택된 에피소드 상세 내용 하단 표출 영역
//                 if let selectedKeyword = selectedEpisodeKeyword {
//                     Divider()
//                         .padding(.vertical, 10)
//                     
//                     let filteredEpisodes = viewModel.generatedEpisodes.filter { $0.keyword.id == selectedKeyword.id }
//                     
//                     VStack(alignment: .leading, spacing: 16) {
//                         HStack(spacing: 6) {
//                             Image(systemName: "tag")
//                                 .font(.system(size: 10))
//                                 .foregroundStyle(.blue)
//                                 .padding(4)
//                                 .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue.opacity(0.25)))
//                             
//                             Text(selectedKeyword.name)
//                                 .font(Font.custom("SF Pro", size: 14).weight(.semibold))
//                             
//                             Text("\(filteredEpisodes.count)")
//                                 .font(.system(size: 10))
//                                 .frame(width: 18, height: 18)
//                                 .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.1)))
//                         }
//                         
//                         // 실제 AI가 생성한 Episode 데이터 바인딩
//                         ForEach(filteredEpisodes) { episode in
//                             VStack(alignment: .leading, spacing: 12) {
//                                 Text("\(episode.experience.title): \(episode.title)")
//                                     .font(Font.custom("SF Pro", size: 16).weight(.bold))
//                                     .foregroundColor(.black)
//                                 
//                                 VStack(alignment: .leading, spacing: 6) {
//                                     Text("- 문제상황: \(episode.problemContext)")
//                                     Text("- 고민 포인트: \(episode.concernPoint)")
//                                     Text("- 나의 액션: \(episode.myAction)")
//                                     Text("- 성과 및 배움: \(episode.outcome)")
//                                 }
//                                 .font(Font.custom("SF Pro", size: 13))
//                                 .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
//                                 .lineSpacing(4)
//                             }
//                             .padding(.top, 4)
//                         }
//                     }
//                     .padding(.top, 8)
//                 }
//             }
//             .padding(30)
//             .frame(maxWidth: .infinity, alignment: .topLeading)
//         }
//         .onAppear {
//             if selectedEpisodeKeyword == nil {
//                 selectedEpisodeKeyword = viewModel.generatedKeywords.first
//             }
//         }
//     }
//     
//     private var titleSection: some View {
//         VStack(alignment: .leading, spacing: 6) {
//             Text("상세보기")
//                 .font(Font.custom("SF Pro", size: 22).weight(.bold))
//                 .foregroundColor(.black)
//
//             Divider()
//         }
//     }
//
//     // 날짜를 "YYYY.MM.DD" 문자열로 표시
//     private static func dateString(_ date: Date) -> String {
//         let formatter = DateFormatter()
//         formatter.dateFormat = "yyyy.MM.dd"
//         formatter.locale = Locale(identifier: "en_US_POSIX")
//         return formatter.string(from: date)
//     }
// }
//
//
// // MARK: - Preview
// #Preview {
//     let container = try! ModelContainer(
//         for: Keyword.self,
//         Episode.self,
//         configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//     )
//     
//     let previewViewModel = KeywordViewModel(modelContext: container.mainContext)
//     previewViewModel.draftExperienceTitle = "애플 디벨로퍼 아카데미 C3"
//     previewViewModel.draftStartDate = .now
//     previewViewModel.draftEndDate = .now
//     previewViewModel.draftKeywords = ["협업", "문제해결력", "자기주도성"]
//     previewViewModel.draftStatement = "디자이너 부재 위기 속에서 임시 PM을 맡아 스탠드업 미팅을 도입하고 R&R을 재분배하여 성공적으로 프로젝트를 완수했다."
//
//     previewViewModel.draftAttachedFiles = [
//         DraftAttachment(url: URL(fileURLWithPath: "/tmp/1.pdf"), fileName: "C4 마일스톤-1", fileType: "pdf", fileSize: 100),
//         DraftAttachment(url: URL(fileURLWithPath: "/tmp/2.pdf"), fileName: "C4 childrunner", fileType: "pdf", fileSize: 100)
//     ]
//     
//     return KeywordDraftView(viewModel: previewViewModel)
//         .modelContainer(container)
//         .frame(width: 850, height: 800)
// }

//
//  KeywordDraftView.swift
//  C4
//
//  Created by 박시은 on 7/21/26.
//

import SwiftUI
import SwiftData

struct KeywordDraftView: View {
    
    @Bindable var viewModel: KeywordViewModel
    
    // 어떤 카드가 선택되었는지 기억하는 상태값
    @State private var selectedEpisodeKeyword: Keyword?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - 상단 타이틀
                titleSection
                
                // MARK: - 좌우 2분할 레이아웃 (경험명/기간 박스 / 첨부자료 박스)
                HStack(alignment: .top, spacing: 24) {
                    // [왼쪽 영역] 경험 명 & 기간 박스
                    VStack(alignment: .leading, spacing: 20) {
                        // 경험 명
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "경험 명")
                            
                            HStack {
                                Text(viewModel.draftExperienceTitle.isEmpty ? "입력된 경험 명이 없습니다." : viewModel.draftExperienceTitle)
                                    .font(Font.custom("SF Pro", size: 13))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.03))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                            )
                        }
                        
                        // 기간 (시작일, 종료일 각각 독립된 네모 박스)
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "기간")
                            
                            HStack(spacing: 8) {
                                // 시작 날짜 박스
                                HStack {
                                    Text(Self.dateString(viewModel.draftStartDate))
                                        .font(Font.custom("SF Pro", size: 13))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.03))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                )

                                Text("—")
                                    .foregroundColor(.gray)

                                // 종료 날짜 박스
                                HStack {
                                    Text(Self.dateString(viewModel.draftEndDate))
                                        .font(Font.custom("SF Pro", size: 13))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.03))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // [오른쪽 영역] 첨부자료 박스
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "첨부자료")
                        
                        if viewModel.draftAttachedFiles.isEmpty {
                            Text("첨부된 자료가 없습니다.")
                                .font(Font.custom("SF Pro", size: 12))
                                .foregroundColor(.gray)
                                .padding(.vertical, 8)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(viewModel.draftAttachedFiles) { file in
                                    HStack(spacing: 8) {
                                        Text(file.fileName)
                                            .font(Font.custom("SF Pro", size: 13))
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.03))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                    )
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Divider()
                
                // MARK: - 키워드별 에피소드 카드 (가로 스크롤)
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(
                        title: "키워드별 에피소드",
                        descriptions: "선택한 키워드를 기반으로 AI가 분석한 경험이에요."
                    )
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.generatedKeywords, id: \.id) { keyword in
                                keywordCard(for: keyword)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // MARK: - 선택된 에피소드 상세 내용 하단 표출 영역
                if let selectedKeyword = selectedEpisodeKeyword {
                    Divider()
                        .padding(.vertical, 10)

                    detailSection(for: selectedKeyword)
                }
            }
            .padding(30)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .onAppear {
            if selectedEpisodeKeyword == nil {
                selectedEpisodeKeyword = viewModel.generatedKeywords.first
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("상세보기")
                .font(Font.custom("SF Pro", size: 22).weight(.bold))
                .foregroundColor(.black)

            Divider()
        }
    }

    // 날짜를 "YYYY.MM.DD" 문자열로 표시
    private static func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    // 특정 키워드에 해당하는 에피소드
    private func episodes(for keyword: Keyword) -> [Episode] {
        viewModel.generatedEpisodes.filter { $0.keyword.id == keyword.id }
    }

    // MARK: - 키워드 카드 (가로 스크롤 아이템)
    private func keywordCard(for keyword: Keyword) -> some View {
        KeywordEpisodeCard(
            keyword: keyword,
            episodes: episodes(for: keyword),
            episodeLimit: 2,
            showsSummary: true
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                selectedEpisodeKeyword = keyword
            }
        }
        .scaleEffect(selectedEpisodeKeyword?.id == keyword.id ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: selectedEpisodeKeyword)
    }

    // MARK: - 선택된 키워드의 에피소드 상세
    private func detailSection(for keyword: Keyword) -> some View {
        let filteredEpisodes = episodes(for: keyword)

        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "tag")
                    .font(.system(size: 10))
                    .foregroundStyle(.blue)
                    .padding(4)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue.opacity(0.25)))

                Text(keyword.name)
                    .font(Font.custom("SF Pro", size: 14).weight(.semibold))

                Text("\(filteredEpisodes.count)")
                    .font(.system(size: 10))
                    .frame(width: 18, height: 18)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.1)))
            }

            // 실제 AI가 생성한 Episode 데이터 바인딩
            ForEach(filteredEpisodes) { episode in
                episodeDetailRow(episode)
            }
        }
        .padding(.top, 8)
    }

    private func episodeDetailRow(_ episode: Episode) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(episode.experience.title): \(episode.title)")
                .font(Font.custom("SF Pro", size: 16).weight(.bold))
                .foregroundColor(.black)

            VStack(alignment: .leading, spacing: 6) {
                Text("- 문제상황: \(episode.problemContext)")
                Text("- 고민 포인트: \(episode.concernPoint)")
                Text("- 나의 액션: \(episode.myAction)")
                Text("- 성과 및 배움: \(episode.outcome)")
            }
            .font(Font.custom("SF Pro", size: 13))
            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
            .lineSpacing(4)
        }
        .padding(.top, 4)
    }
}


// MARK: - Preview
#Preview {
    let container = try! ModelContainer(
        for: Keyword.self,
        Episode.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let previewViewModel = KeywordViewModel(modelContext: container.mainContext)
    previewViewModel.draftExperienceTitle = "애플 디벨로퍼 아카데미 C3"
    previewViewModel.draftStartDate = .now
    previewViewModel.draftEndDate = .now
    previewViewModel.draftKeywords = ["협업", "문제해결력", "자기주도성"]
    previewViewModel.draftStatement = "디자이너 부재 위기 속에서 임시 PM을 맡아 스탠드업 미팅을 도입하고 R&R을 재분배하여 성공적으로 프로젝트를 완수했다."

    previewViewModel.draftAttachedFiles = [
        DraftAttachment(url: URL(fileURLWithPath: "/tmp/1.pdf"), fileName: "C4 마일스톤-1", fileType: "pdf", fileSize: 100),
        DraftAttachment(url: URL(fileURLWithPath: "/tmp/2.pdf"), fileName: "C4 childrunner", fileType: "pdf", fileSize: 100)
    ]
    
    return KeywordDraftView(viewModel: previewViewModel)
        .modelContainer(container)
        .frame(width: 850, height: 800)
}
