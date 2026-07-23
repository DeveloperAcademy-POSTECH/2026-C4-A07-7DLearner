//
//  SidebarWidget.swift
//  C4
//
//  Created by YOOJUN PARK on 7/21/26.
//

import SwiftUI

// MARK: 통계 위젯
struct SidebarStatsWidget: View {
    let characterCount: Int
    let keywordCount: Int
    let officeCount: Int
    let draftCount: Int
    
    var body: some View {
        HStack(spacing: 0) {
            stat(label: "캐릭터", count: characterCount)
            divider
            stat(label: "키워드", count: keywordCount)
            divider
            stat(label: "오피스", count: officeCount)
            divider
            stat(label: "임시저장", count: draftCount)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1.2)
        )
    }
    
    private func stat(label: String, count: Int) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.primary)
            Text("\(count)")
                .font(.title2.weight(.bold))
        }
        .frame(maxWidth: .infinity)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 1.2, height: 30)
    }
}

#Preview {
    SidebarStatsWidget(characterCount: 1, keywordCount: 2, officeCount: 3, draftCount: 4)
}
