//
//  GeneralSettingsView.swift
//  C4
//
//  Created by YOOJUN PARK on 7/21/26.
//

import SwiftUI
import SwiftData

struct GeneralSettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var isSeeding = false // 초기화 과정: FoundationModel 분석에 시간 소요
    
    var body: some View {
        Button(isSeeding ? "초기화 중..." : "데이터 초기화 (목업)") {
            Task { await resetData() }
        }
        .disabled(isSeeding)
        .frame(width: 500, height: 300)
    }
    
}

private extension GeneralSettingsView {
    
    @MainActor
    func resetData() async {
        isSeeding = true
        await MockDataSeeder.seedAll(modelContext: modelContext)
        isSeeding = false
    }
    
}

#Preview {
    GeneralSettingsView()
        .modelContainer(for: [Character.self, Experience.self, Keyword.self, Attachment.self, Episode.self], inMemory: true)
}
