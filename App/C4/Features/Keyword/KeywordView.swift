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
    @Environment(\.modelContext) private var modelContext
    
    @State private var isDeleteConfirmationPresented = false
    
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
            get: { true },
            set: { _ in }
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
                }
            }
            .inspectorColumnWidth(min: 600, ideal: 600, max: 700)
        }
        .confirmationDialog(
            "선택한 항목을 삭제하시겠습니까?",
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("삭제", role: .destructive) {
                deleteSelectedSelection()
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("삭제한 항목은 복구할 수 없습니다.")
        }
    }
    
    // 선택된 키워드 또는 경험 삭제
    private func deleteSelectedSelection() {
        if let selection = viewModel.viewSelection {
            switch selection {
            case .keyword(let keyword):
                for episode in keyword.episodes {
                    modelContext.delete(episode)
                }
                modelContext.delete(keyword)
                
            case .experience(let experience):
                modelContext.delete(experience)
            }
            
            do {
                try modelContext.save()
                viewModel.fetchKeywords()
            } catch {
                print("삭제 저장 실패: \(error)")
            }
            
            // 삭제 후 인스펙터를 비우거나 초기화면으로 복귀
            viewModel.viewSelection = nil
            viewModel.currentInspectorScreen = .empty
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
                    row(title: keyword.name,
                        subtitle: "에피소드 \(keyword.episodes.count)개")
                    .tag(keyword)
                }
                .listStyle(.plain)
            } else {
                List(experiences, id: \.id, selection: experienceSelection) { experience in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(experience.title)
                            .font(Font.custom("SF Pro", size: 13).weight(.semibold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 6) {
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
    
    // Row 컴포넌트
    private func row(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body.weight(.semibold))
                .lineLimit(1)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
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
            
        case .empty:
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    viewModel.startKeywordCreation()
                }) {
                    Text("+ 새 키워드")
                }
                .buttonStyle(.glass) // 캐릭터 창 스타일 차용
            }
            
        case .create:
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    viewModel.currentInspectorScreen = .empty
                }) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.glass)
            }
            
            ToolbarSpacer()
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    // 임시저장 액션
                }) {
                    Text("임시저장")
                        .font(Font.custom("SF Pro", size: 13).weight(.medium))
                }
                .buttonStyle(.glass)
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    viewModel.startAnalysis()
                }) {
                    Text("분석")
                        .font(Font.custom("SF Pro", size: 13).weight(.medium))
                        .foregroundColor(.white)
                }
                .buttonStyle(.glassProminent)
                .disabled(!viewModel.isDraftReadyToAnalyze)
            }
            
        case .loading:
            // 로딩 창에서는 툴바 숨김
            ToolbarItem(placement: .automatic) { }
            
        case .draft, .detail: // 초안(draft) 및 디테일 창
            ToolbarItem(placement: .destructiveAction) {
                Button {
                    isDeleteConfirmationPresented = true
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.glass)
            }
            
            ToolbarSpacer()
            
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.startKeywordCreation()
                } label: {
                    Text("+ 새 키워드")
                }
                .buttonStyle(.glass)
            }
            
            ToolbarSpacer()
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    // TODO: 편집 액션 연동 (어디로 가서 편집할지.. 고민되어... 걍 둔다.. 허허)
                } label: {
                    Text("편집")
                }
                .buttonStyle(.glass)
            }
        }
    }
}
