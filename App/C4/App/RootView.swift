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
    
    @State private var selection: SidebarItem? = .keyword
    
    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailContent
        }
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
                    officeCount: 0,
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
            KeywordView(modelContext: modelContext)
        case .character:
            CharacterView(viewModel: CharacterViewModel(modelContext: modelContext))
        case .office:
            Text("오피스 화면")
        case .draft:
            Text("임시저장 화면")
        case .trash:
            TrashView(modelContext: modelContext)
        case .none:
            Text("사이드바에서 항목을 선택하세요")
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Character.self, Experience.self, Keyword.self, Attachment.self, Episode.self], inMemory: true)
}
