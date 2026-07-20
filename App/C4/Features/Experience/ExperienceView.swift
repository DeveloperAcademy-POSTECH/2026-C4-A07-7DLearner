//
//  ExperienceView.swift
//  C4
//
//  Created by 박시은 on 7/16/26.
//

import SwiftUI
import SwiftData

struct ExperienceView: View {
    // MARK: - 의존성 및 상태 관리
    @StateObject private var viewModel: ExperienceViewModel
    @State private var selectedItem: AnyHashable?
    
    @State private var isInspectorPresented: Bool = false
    @State private var isCreating: Bool = false
    // MARK: - 뷰 초기화
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ExperienceViewModel(context: modelContext))
    }
    
    // MARK: - 뷰 본문
    var body: some View {
        VStack {
            // 상단 모드 전환 Picker
            Picker("모드", selection: $viewModel.isKeywordMode) {
                Text("키워드").tag(true)
                Text("경험").tag(false)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding()
            
            // 리스트 영역
            List(selection: $selectedItem) {
                if viewModel.isKeywordMode {
                    ForEach(viewModel.keywords) { keyword in
                        KeywordRow(keyword: keyword)
                            .tag(keyword as AnyHashable)
                    }
                } else {
                    ForEach(viewModel.experiences) { exp in
                        ExperienceRow(experience: exp)
                            .tag(exp as AnyHashable)
                    }
                }
            }
        }
        .navigationTitle("경험")
        
        // 툴바 버튼 세팅 (우측 상단)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    // 더미 데이터 버튼
                    Button(action: {
                        viewModel.addDummyData()
                    }) {
                        Image(systemName: "pencil.and.outline")
                        Text("더미데이터")
                    }
                    
                    // 실제 경험 생성창으로 연결될 버튼 (+)
                    Button(action: {
                        selectedItem = nil // 리스트 선택 해제
                        isCreating = true  // 생성 모드 ON
                        isInspectorPresented = true // 인스펙터 열기
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        // 항목 선택 시 자동 오픈 (리스트를 누르면 생성 모드는 자동으로 꺼짐)
        .onChange(of: selectedItem) { _, newValue in
            if newValue != nil {
                isCreating = false // 생성 모드 OFF
                isInspectorPresented = true
            }
        }
        
        // MARK: - 인스펙터 (상세 보기 & 생성창 통합)
        .inspector(isPresented: $isInspectorPresented) {
            Group {
                if isCreating {
                    // 생성 모드
                    VStack(spacing: 20) {
                        Text("경험 생성창 (추후 CreateExperienceView 연결 예정)")
                            .font(.headline)
                        Button("취소") {
                            isCreating = false
                            isInspectorPresented = false
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let keyword = selectedItem as? Keyword {
                    // 키워드 선택
                    KeywordDetailView(keyword: keyword)
                } else if let experience = selectedItem as? Experience {
                    // 경험 선택
                    ExperienceDetailView(experience: experience)
                } else {
                    Text("항목을 선택하세요")
                        .foregroundColor(.secondary)
                }
            }
            .inspectorColumnWidth(min: 250, ideal: 450, max: 800)
        }
    }
}
// MARK: - 하위뷰
struct KeywordRow: View {
    let keyword: Keyword
    
    var body: some View {
        Text(keyword.name)
            .padding(.vertical, 2)
    }
}

struct ExperienceRow: View {
    let experience: Experience
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(experience.title)
                .font(.headline)
            Text("\(experience.periodStart, style: .date) ~ \(experience.periodEnd, style: .date)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct KeywordDetailView: View {
    let keyword: Keyword
    
    var body: some View {
        Text("\(keyword.name) 상세 화면")
            .navigationTitle(keyword.name)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
