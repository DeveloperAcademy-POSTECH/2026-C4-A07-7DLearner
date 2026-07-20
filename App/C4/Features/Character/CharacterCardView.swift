import SwiftUI
import SwiftData

// MARK: Design Constants
struct Constants {
    static let GlobalFontSize: CGFloat = 13
}

// MARK: Keyword Tag
struct KeywordTagView: View {
    
    // MARK: Properties
    let text: String
    
    // MARK: Body
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

// MARK: Character Card
struct CharacterCardView: View {
    
    // MARK: Properties
    let character: Character
    
    // MARK: Body
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
                    ForEach(character.keywords.prefix(2), id: \.id) { keyword in
                        if keyword.name.count > 3 {
                            KeywordTagView(text: String(keyword.name.prefix(3)) + "...")
                        }
                        else {
                            KeywordTagView(text: keyword.name)
                        }
                    }
                    
                    if character.keywords.count > 2 {
                        KeywordTagView(text: "+\(character.keywords.count - 2)")
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
//    return CharacterCardView(character: character)
//}
