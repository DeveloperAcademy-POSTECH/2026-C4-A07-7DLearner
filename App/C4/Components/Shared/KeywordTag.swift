//
//  KeywordTag.swift
//  C4
//
//  Created by jiwon hong on 7/20/26.
//

import SwiftUI
import SwiftData

enum KeywordTagStyle {
    case selected
    case picker
}

struct KeywordTag: View {
    
    let text: String
    let onRemove: (() -> Void)? //실행할 함수가 있을 수도 있고 없을 수도 있답니당
    let style: KeywordTagStyle
    
    init(
        text: String,
        onRemove: (() -> Void)? = nil, //매번 onRemove: nil 안 해도 되도록
        style: KeywordTagStyle
    ){
        self.text = text
        self.onRemove = onRemove
        self.style = style
    }
    
    private var foregroundColor: Color {
        switch style {
        case .selected:
            return Color(red: 0, green: 0.4, blue: 0.8).opacity(0.85)
        case .picker:
            return Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.85)
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .selected:
            return Color(red: 0.85, green: 0.93, blue: 1)
        case .picker:
            return Color(red: 0.95, green: 0.95, blue: 0.95)
        }
    }
    
    var body: some View {
//        Text(text)
//            .font(
//                Font.custom("SF Pro", size:Constants.GlobalFontSize)
//                    .weight(.medium)
//            )
//            .foregroundColor(Color(red: 0, green: 0.4, blue: 0.8).opacity(0.85))
//            .multilineTextAlignment(.center)
//            .lineLimit(1)
//            .fixedSize(horizontal: true, vertical: false)
//            .padding(.horizontal, 6)
//            .padding(.vertical, 3)
//            .background(Color(red: 0.85, green: 0.93, blue: 1))
//            .cornerRadius(8)
        
        
        HStack (spacing: 4) {
            Text(text)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            
            if let onRemove {
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.plain)
                
            }
        }
        .font(Font.custom("SF Pro", size: 12))
        .foregroundColor(foregroundColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(backgroundColor)
        .cornerRadius(20)
    }
}
