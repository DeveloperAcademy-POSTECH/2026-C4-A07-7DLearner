//
//  KeywordTag.swift
//  C4
//
//  Created by jiwon hong on 7/20/26.
//

import SwiftUI
import SwiftData

struct KeywordTag: View {
    
    let text: String
    
    var body: some View {
        Text(text)
            .font(
                Font.custom("SF Pro", size:Constants.GlobalFontSize)
                    .weight(.medium)
            )
            .foregroundColor(Color(red: 0, green: 0.4, blue: 0.8).opacity(0.85))
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color(red: 0.85, green: 0.93, blue: 1))
            .cornerRadius(8)
    }
}
