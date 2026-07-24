//
//  RootView.swift
//  C4
//
//  Created by YOOJUN PARK on 7/14/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.openSettings) private var openSettings
    @Environment(\.modelContext) private var modelContext
    
    @Query private var characters: [Character]
    @Query private var keywords: [Keyword]
    @Query private var offices: [Office]
    
    @State private var selection: SidebarItem? = .keyword
    
    @State private var keywordViewModel: KeywordViewModel
    @State private var characterViewModel: CharacterViewModel
    @State private var officeViewModel: OfficeViewModel
    @State private var trashViewModel: TrashViewModel
    
    init(modelContext: ModelContext) {
        _keywordViewModel = State(initialValue: KeywordViewModel(modelContext: modelContext))
        _characterViewModel = State(initialValue: CharacterViewModel(modelContext: modelContext))
        _officeViewModel = State(initialValue: OfficeViewModel(modelContext: modelContext))
        _trashViewModel = State(initialValue: TrashViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } detail: {
            detailContent
                .frame(minWidth: 420, idealWidth: 420, maxWidth: .infinity)
                .inspector(isPresented: .constant(true)) {
                    inspectorContent
                        .inspectorColumnWidth(min: 400, ideal: 500, max: 650)
                }
        }
        .frame(
            minWidth: 1080, idealWidth: 1400, maxWidth: 1920,
            minHeight: 640, idealHeight: 720, maxHeight: 1200
        )
    }
}

// MARK: - 사이드바
private extension RootView {
    var sidebar: some View {
        VStack(spacing: 0) {
            Button {
                // 위젯 눌렀을 때 동작 - 보여줄 뷰
            } label: {
                SidebarStatsWidget(
                    characterCount: characters.count,
                    keywordCount: keywords.count,
                    officeCount: offices.count,
                    draftCount: 0
                )
            }
            .buttonStyle(.plain)
            .padding()
            
            Divider()
            
            List(selection: $selection) {
                ForEach(SidebarItem.allCases.filter(\.isPrimarySection), id: \.self) { item in
                    Label(item.rawValue, systemImage: item.icon)
                        .font(.body.weight(.semibold))
                        .tag(item)
                }
                
                Divider()
                
                ForEach(SidebarItem.allCases.filter { !$0.isPrimarySection }, id: \.self) { item in
                    Label(item.rawValue, systemImage: item.icon)
                        .tag(item)
                }
            }
            .padding(.top, 16)
            
            Spacer()
            
            Button {
                openSettings()
            } label: {
                Label("설정", systemImage: "gearshape")
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

// MARK: - 화면
private extension RootView {
    @ViewBuilder
    var detailContent: some View {
        switch selection {
        case .keyword:
            KeywordView(viewModel: keywordViewModel)
        case .character:
            CharacterView(viewModel: characterViewModel)
        case .office:
            OfficeView(viewModel: officeViewModel)
        case .draft:
            Text("임시저장 화면")
        case .trash:
            TrashView(viewModel: trashViewModel)
        case .none:
            Text("사이드바에서 항목을 선택하세요")
        }
    }
}

// MARK: - 인스펙터
private extension RootView {
    @ViewBuilder
    var inspectorContent: some View {
        switch selection {
        case .keyword:
            KeywordView.inspectorContent(viewModel: keywordViewModel)
        case .character:
            CharacterView.inspectorContent(viewModel: characterViewModel)
        case .office:
            OfficeView.inspectorContent(viewModel: officeViewModel, characters: characters)
        case .trash:
            TrashView.inspectorContent(viewModel: trashViewModel)
        case .draft, nil:
            Text("항목을 선택하세요")
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Character.self, Experience.self, Keyword.self, Attachment.self, Episode.self, Office.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    return RootView(modelContext: container.mainContext)
        .modelContainer(container)
}
