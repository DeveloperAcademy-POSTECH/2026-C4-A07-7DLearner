//
//  ExperienceView.swift
//  C4
//
//  Created by 박시은 on 7/16/26.
//

import SwiftUI
import SwiftData

// enum으로 선택항목 관리 
enum SelectionItem: Hashable {
    case keyword(PersistentIdentifier)
    case experience(PersistentIdentifier)
}

struct ExperienceView: View {
    // MARK: - 의존성 및 상태 관리
    @State private var viewModel: ExperienceViewModel
    @State private var selectedModelID: PersistentIdentifier?
    @State private var isCreating: Bool = false
    @State private var showInspector: Bool = false
    
    @Query private var experiences: [Experience]
    @Query private var keywords: [Keyword]
    
    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: ExperienceViewModel(context: modelContext))
    }
    
    // MARK: - 뷰 본문
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - 상단 헤더 영역
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.isKeywordMode ? "키워드" : "경험")
                            .font(.largeTitle)
                            .bold()
                        
                        Text(viewModel.isKeywordMode ? "키워드를 통해 캐릭터를 만들 수 있어요!" : "나만의 소중한 경험을 기록하고 관리하세요!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // 토글 버튼
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                clearSelection()
                                viewModel.isKeywordMode = true
                            }
                        }) {
                            Text("키워드")
                                .font(.footnote)
                                .bold()
                                .frame(width: 140, height: 26)
                                .foregroundColor(viewModel.isKeywordMode ? .white : .secondary)
                                .background(viewModel.isKeywordMode ? Color.indigo : Color.indigo.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                clearSelection()
                                viewModel.isKeywordMode = false
                            }
                        }) {
                            Text("경험")
                                .font(.footnote)
                                .bold()
                                .frame(width: 140, height: 26)
                                .foregroundColor(!viewModel.isKeywordMode ? .white : .secondary)
                                .background(!viewModel.isKeywordMode ? Color.indigo : Color.indigo.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // 휴지통 버튼
                Button(action: {
                    // 휴지통 액션
                }) {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            // MARK: - 리스트 영역
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.isKeywordMode {
                        ForEach(keywords) { keyword in
                            KeywordRow(keyword: keyword)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedModelID = keyword.persistentModelID
                                    isCreating = false
                                    showInspector = true
                                }
                                .background(selectedModelID == keyword.persistentModelID ? Color.blue.opacity(0.1) : Color.clear)
                            
                            Divider()
                        }
                    } else {
                        ForEach(experiences) { exp in
                            ExperienceRow(experience: exp)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedModelID = exp.persistentModelID
                                    isCreating = false
                                    showInspector = true
                                }
                                .background(selectedModelID == exp.persistentModelID ? Color.blue.opacity(0.1) : Color.clear)
                            
                            Divider()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 280, idealWidth: 320, maxWidth: 450)
        
        // 툴바 버튼
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button(action: { viewModel.addDummyData() }) {
                        Image(systemName: "pencil.and.outline")
                        Text("더미데이터")
                    }
                    
                    Button(action: {
                        clearSelection()
                        isCreating = true
                        showInspector = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        // MARK: - 인스펙터 영역
        .inspector(isPresented: $showInspector) {
            Group {
                if isCreating {
                    
                    if viewModel.isKeywordMode {
                        CreateKeywordView()
                    } else {
                        Text("새로운 경험 생성창").font(.largeTitle).foregroundColor(.secondary)
                    }
                } else if let id = selectedModelID {
                    // 선택된 데이터 상세 보기
                    if viewModel.isKeywordMode, let keyword = keywords.first(where: { $0.persistentModelID == id }) {
                        KeywordDetailView(keyword: keyword)
                    } else if !viewModel.isKeywordMode, let exp = experiences.first(where: { $0.persistentModelID == id }) {
                        ExperienceDetailView(experience: exp)
                    } else {
                        Text("데이터를 찾을 수 없습니다.").foregroundColor(.secondary)
                    }
                } else {
                    VStack {
                        Text("항목을 선택해주세요.").foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(32)
                }
            }
            .inspectorColumnWidth(min: 400, ideal: 600, max: .infinity)
        }
        .onChange(of: showInspector) { _, isNowOpen in
            if !isNowOpen {
                clearSelection()
            }
        }
    }
    
    private func clearSelection() {
        selectedModelID = nil
        isCreating = false
        showInspector = false
    }
}

// MARK: - 하위뷰
struct KeywordRow: View {
    let keyword: Keyword
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(keyword.name).font(.headline)
            Text("에피소드 \(keyword.episodes.count)개").font(.caption).foregroundColor(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

struct ExperienceRow: View {
    let experience: Experience
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(experience.title).font(.headline)
            if experience.keywords.isEmpty {
                Text("등록된 키워드 없음").font(.caption).foregroundColor(.secondary)
            } else {
                HStack(spacing: 6) {
                    ForEach(experience.keywords) { keyword in
                        Text(keyword.name)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(Color.blue)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}
