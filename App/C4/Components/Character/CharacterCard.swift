//
//  CharacterCard.swift
//  C4
//
//  Created by jiwon hong on 7/20/26.
//

import SwiftUI
import SwiftData

struct Constants {
    static let GlobalFontSize: CGFloat = 13
}

struct CharacterCard: View {
    
    let character: Character
    let keywordLimit: Int?
    
    private var displayedKeywords: [Keyword] {
        if let keywordLimit {
            return Array(character.keywords.prefix(keywordLimit))
        } else {
            return character.keywords
        }
    }
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 10) {
            
            RoundedRectangle(cornerRadius: 7)
                .fill(Color.white)
                .frame(width: 52, height: 57)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(character.title)
                    .font(
                        Font.custom("SF Pro", size: 12)
                            .weight(.semibold)
                    )
                    .foregroundColor(.black)
                
                HStack(spacing: 4) {
                    ForEach(displayedKeywords, id: \.id) { keyword in
                        if keyword.name.count > 3 {
                            KeywordTag(text: String(keyword.name.prefix(3)) + "...", style: .selected)
                        }
                        else {
                            KeywordTag(text: keyword.name, style: .selected)
                        }
                    }
                    
                    if let keywordLimit,
                       character.keywords.count > keywordLimit {
                        KeywordTag(text: "+\(character.keywords.count - keywordLimit)", style: .selected)
                    }
                }
                
            }
            
        }
        .frame(width: 224, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray, lineWidth: 1.2)
        )
    }
    
}

// MARK: Preview
//#Preview {
//    let keywords = [
//        Keyword(name: "협업"),
//        Keyword(name: "회복탄력성"),
//        Keyword(name: "책임감")
//    ]
//    
//    let character = Character(
//        title: "기획자",
//        characterStatement: "설명",
//        keywords: keywords
//    )
//    
//    return Card(character: character)
//}
