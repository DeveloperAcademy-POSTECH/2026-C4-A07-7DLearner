//
//  RootView.swift
//  C4
//
//  Created by YOOJUN PARK on 7/14/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var selection: SidebarItem? = .home
    
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
        List(SidebarItem.allCases, id: \.self, selection: $selection) { item in
            Label(item.rawValue, systemImage: item.icon)
                .tag(item)
        }
        .navigationSplitViewColumnWidth(min: 130, ideal: 180)
    }
}

// MARK: - 화면
private extension RootView {
    @ViewBuilder
    var detailContent: some View {
        switch selection {
        case .home:
            HomeView(viewModel: HomeViewModel(modelContext: modelContext))
        case .experience:
            Text("경험 화면")
        case .character:
            Text("캐릭터 화며")
        case .none:
            Text("사이드바에서 항목을 선택하세요")
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Character.self, Experience.self, Keyword.self, Attachment.self, Episode.self], inMemory: true)
}
