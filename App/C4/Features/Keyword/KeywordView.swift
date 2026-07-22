//
//  KeywordView.swift
//  C4
//
//  Created by 박시은 on 7/20/26.
//

import SwiftUI
import SwiftData
import Foundation

struct KeywordView: View {
    
    // MARK: ViewModel
    @State private var viewModel: KeywordViewModel
    @Query private var experiences: [Experience]
    
    let selectedColor = Color("selectedColor")
    
    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: KeywordViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        // MARK: - 리스트 영역
        VStack(spacing: 0) {
            if viewModel.keywords.isEmpty && experiences.isEmpty {
                emptyStateView
            } else {
                contentListView
            }
        }
        .navigationTitle("키워드")
        // 상태 기반 통합 툴바
        .toolbar {
            keywordToolbar
        }
        // MARK: - Inspector
        .inspector(isPresented: Binding(
            get: { viewModel.isInspectorPresented },
            set: { isPresented in
                if !isPresented {
                    viewModel.currentInspectorScreen = nil
                }
            }
        )) {
            Group {
                switch viewModel.currentInspectorScreen {
                case .empty:
                    KeywordEmptyView(viewModel: viewModel)
                case .create:
                    KeywordCreateView(viewModel: viewModel)
                case .loading:
                    if let experience = viewModel.analysisExperience {
                        KeywordLoadingView(
                            experience: experience,
                            manager: viewModel.episodeGenerationManager,
                            onComplete: {
                                viewModel.finishAnalysis()
                            }
                        )
                    }
                case .draft:
                    KeywordDraftView(viewModel: viewModel)
                case .detail:
                    switch viewModel.viewSelection {
                    case .keyword(let keyword):
                        KeywordDetailView(keyword: keyword, episodes: viewModel.episodesForKeyword(keyword: keyword))
                    case .experience(let experience):
                        ExperienceDetailView(experience: experience)
                    case nil:
                        Text("선택된 항목이 없습니다.")
                    }
                case nil:
                    KeywordEmptyView(viewModel: viewModel)
                }
            }
            .inspectorColumnWidth(min: 350, ideal: 420, max: 600)
        }
    }
    
    // MARK: - 빈 화면
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Text("아직 생성된 키워드가 없습니다.")
            Text("+ 버튼을 눌러 새로운 키워드를 만들어 보세요.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 리스트 화면
    private var contentListView: some View {
        VStack(spacing: 0) {
            // 상단 탭 (ViewModel의 changeTab과 연동)
            HStack(spacing: 0) {
                Button(action: {
                    viewModel.changeTab(to: "키워드")
                }) {
                    Text("키워드")
                        .font(Font.custom("SF Pro", size: 13))
                        .frame(width: 361 / 2, height: 24)
                        .background(viewModel.selectedTab == "키워드" ? selectedColor : Color.clear)
                        .foregroundColor(viewModel.selectedTab == "키워드" ? .white : .black)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    viewModel.changeTab(to: "경험")
                }) {
                    Text("경험")
                        .font(Font.custom("SF Pro", size: 13))
                        .frame(width: 361 / 2, height: 24)
                        .background(viewModel.selectedTab == "경험" ? selectedColor : Color.clear)
                        .foregroundColor(viewModel.selectedTab == "경험" ? .white : .black)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .frame(width: 361, height: 24)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(6)
            .padding(.vertical, 12)
            
            // 키워드 및 경험 리스트 분기 처리
            if viewModel.selectedTab == "키워드" {
                List(viewModel.keywords, id: \.id, selection: keywordSelection) { keyword in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(keyword.name)
                            .font(Font.custom("SF Pro", size: 15).weight(.semibold))
                            .foregroundColor(.black)
                        Text("에피소드 \(keyword.episodes.count)개")
                            .font(Font.custom("SF Pro", size: 12))
                            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                    }
                    .padding(.vertical, 8)
                    .tag(keyword)
                }
                .listStyle(.plain)
            } else {
                // 💡 진짜 경험 리스트 (경험 명 + 아래에 바짝 붙은 키워드 태그들)
                List(experiences, id: \.id, selection: experienceSelection) { experience in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(experience.title)
                            .font(Font.custom("SF Pro", size: 15).weight(.semibold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 2) {
                            ForEach(experience.keywords, id: \.id) { keyword in
                                KeywordTag(text: keyword.name, style: .selected)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .tag(experience)
                }
                .listStyle(.plain)
            }
        }
    }
    
    // 리스트 선택 바인딩 헬퍼
    private var keywordSelection: Binding<Keyword?> {
        Binding(
            get: {
                if case .keyword(let keyword) = viewModel.viewSelection { return keyword }
                return nil
            },
            set: { keyword in
                if let keyword {
                    viewModel.viewSelection = .keyword(keyword)
                    viewModel.currentInspectorScreen = .detail
                }
            }
        )
    }
    
    private var experienceSelection: Binding<Experience?> {
        Binding(
            get: {
                if case .experience(let experience) = viewModel.viewSelection { return experience }
                return nil
            },
            set: { experience in
                if let experience {
                    viewModel.viewSelection = .experience(experience)
                    viewModel.currentInspectorScreen = .detail
                }
            }
        )
    }
    
    // MARK: - 통합 툴바 (상태 기반)
    @ToolbarContentBuilder
    private var keywordToolbar: some ToolbarContent {
        switch viewModel.currentInspectorScreen {
        case .create:
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    viewModel.currentInspectorScreen = nil
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                .buttonStyle(.plain)
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    // 임시저장 액션
                }) {
                    Text("임시저장")
                        .font(Font.custom("SF Pro", size: 13).weight(.medium))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .frame(height: 28)
                        .overlay(
                            Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    viewModel.startAnalysis()
                }) {
                    Text("분석")
                        .font(Font.custom("SF Pro", size: 13).weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 28)
                        .background(Color(red: 0.0, green: 0.48, blue: 1.0))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.isDraftReadyToAnalyze)
            }
            
        case .detail:
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    viewModel.startKeywordCreation()
                } label: {
                    Image(systemName: "plus")
                }
            }
            
        default:
            if viewModel.keywords.isEmpty && experiences.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        viewModel.startKeywordCreation()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("새 키워드")
                        }
                        .font(Font.custom("SF Pro", size: 14).weight(.medium))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                    }
                    .buttonStyle(.plain)
                    .clipShape(Capsule())
                    .fixedSize()
                }
            } else {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        // 휴지통 액션
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                    .clipShape(Circle())
                    .fixedSize()
                }
                
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        viewModel.startKeywordCreation()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("새 키워드")
                        }
                        .font(Font.custom("SF Pro", size: 14).weight(.medium))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                    }
                    .buttonStyle(.plain)
                    .background(Color.gray.opacity(0.12))
                    .clipShape(Capsule())
                    .fixedSize()
                    
                    Spacer()
                        .frame(width: 120)
                    
                    Button(action: {
                        // 검색 액션
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 13))
                            .foregroundColor(.black)
                            .frame(width: 28, height: 28)
                    }
                }
            }
        }
    }
}
