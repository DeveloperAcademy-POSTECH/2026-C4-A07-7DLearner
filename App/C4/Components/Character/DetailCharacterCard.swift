//
//  DetailCharacterCard.swift
//  C4
//
//  Created by jiwon hong on 7/21/26.
//

import SwiftUI

struct DetailCharacterCard: View {
    
    let character: Character
    let keywords: [Keyword]

    var body: some View {
        
        HStack(alignment: .center, spacing: 10) {
            
            RoundedRectangle(cornerRadius: 7)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 52, height: 57)
                
                
            VStack(alignment: .leading, spacing: 12) {
                Text(character.title)
                    .font(
                        Font.custom("SF Pro", size: 12)
                            .weight(.semibold)
                    )
                    .foregroundColor(.black)
                
                HStack(spacing: 4) {
                    ForEach(keywords, id: \.id) { keyword in
                        KeywordTag(text: keyword.name, style: .selected)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(red: 0.85, green: 0.85, blue: 0.93))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(red: 0.46, green: 0.42, blue: 1), lineWidth: 1.2)
        )
    }    
}
//
//#Preview {
//    DetailCharacterCard()
//}
