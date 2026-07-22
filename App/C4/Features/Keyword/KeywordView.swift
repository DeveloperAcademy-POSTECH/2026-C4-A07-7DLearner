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
    @Bindable var viewModel: KeywordViewModel
    @State private var selectedTab = "키워드"
    
    let selectedColor = Color("selectedColor")
    
    var body: some View {
        // MARK: - 리스트 영역
        VStack(spacing: 0) {
            if viewModel.keywords.isEmpty {
                emptyStateView
            } else {
                contentListView
            }
        }
        .navigationTitle("키워드")
        // 메인 툴바 분기 처리
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
                case .create:
                    KeywordCreateView(viewModel: viewModel)
                case .loading:
                    // 잠시 로딩창 넣엇듬
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("AI가 에피소드를 분석하고 있어요...")
                            .font(Font.custom("SF Pro", size: 14))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .draft:
                    KeywordDraftView(viewModel: viewModel)
                case .detail:
                    if let keyword = viewModel.selectedKeyword {
                        KeywordDetailView(keyword: keyword, episodes: viewModel.episodesForKeyword(keyword: keyword))
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
            // 상단 탭
            HStack(spacing: 0) {
                Button(action: { selectedTab = "키워드" }) {
                    Text("키워드")
                        .font(Font.custom("SF Pro", size: 13))
                        .frame(width: 361 / 2, height: 24)
                        .background(selectedTab == "키워드" ? selectedColor : Color.clear)
                        .foregroundColor(selectedTab == "키워드" ? .white : .black)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: { selectedTab = "경험" }) {
                    Text("경험")
                        .font(Font.custom("SF Pro", size: 13))
                        .frame(width: 361 / 2, height: 24)
                        .background(selectedTab == "경험" ? selectedColor : Color.clear)
                        .foregroundColor(selectedTab == "경험" ? .white : .black)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .frame(width: 361, height: 24)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(6)
            .padding(.vertical, 12)
            
            // 키워드 리스트
            if selectedTab == "키워드" {
                List(viewModel.keywords, id: \.id, selection: $viewModel.selectedKeyword) { keyword in
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
                Spacer()
                Text("경험 리스트 영역")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
    
    // MARK: - 툴바
    @ToolbarContentBuilder
    private var keywordToolbar: some ToolbarContent {
        switch viewModel.currentInspectorScreen {
            
            // 인스펙터 안 켜져 있을 때 (기본 메인 화면)
        case nil:
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.startKeywordCreation()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("새 키워드")
                    }
                }
            }
            
            // 인스펙터 [생성창] 상태일 때
        case .create:
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.currentInspectorScreen = .loading
                    Task {
                        await viewModel.generateEpisodes()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(!viewModel.isDraftReadyToAnalyze)
            }
            
            // 인스펙터 [로딩] 상태일 때 (캐릭터 파트처럼 다음 버튼으로 초안 확인)
        case .loading:
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.currentInspectorScreen = .draft
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            
            // 인스펙터 [초안창] 상태일 때
        case .draft:
            ToolbarItem(placement: .cancellationAction) {
                HStack(spacing: 8) {
                    Button {
                        viewModel.currentInspectorScreen = nil
                    } label: {
                        Image(systemName: "xmark")
                    }
                    
                    Button {
                        // 편집 버튼 액션
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 12) {
                    Button {
                        // 임시저장 액션
                    } label: {
                        Text("임시저장")
                    }
                    
                    Button {
                        viewModel.fetchKeywords()
                        viewModel.currentInspectorScreen = nil
                    } label: {
                        Text("저장")
                    }
                }
            }
            
            // 인스펙터 [디테일 / 키워드 리스트] 상태일 때
        case .detail:
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    viewModel.startKeywordCreation()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

// 인스펙터 [생성창] 상태일 때
//        case .create:
//            ToolbarItem(placement: .cancellationAction) {
//                Button {
//                    viewModel.currentInspectorScreen = nil
//                } label: {
//                    Image(systemName: "xmark")
//                }
//            }
//
//            ToolbarItem(placement: .primaryAction) {
//                HStack(spacing: 12) {
//                    Button {
//                        // 임시저장 액션
//                    } label: {
//                        Text("임시저장")
//                    }
//
//                    Button {
//                        viewModel.currentInspectorScreen = .loading
//                        // 비동기로 AI 분석 실행 후, 끝나면 초안창으로 자동 전환
//                        Task {
//                            await viewModel.generateEpisodes()
//                            viewModel.currentInspectorScreen = .draft
//                        }
//                    } label: {
//                        Text("분석")
//                    }
//                    .disabled(!viewModel.isDraftReadyToAnalyze)
//                }
//            }
