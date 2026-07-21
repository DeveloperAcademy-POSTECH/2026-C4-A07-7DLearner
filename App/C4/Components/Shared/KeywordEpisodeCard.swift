//
//  KeywordEpisodeCard.swift
//  C4
//
//  Created by jiwon hong on 7/20/26.
//

import SwiftUI
import SwiftData

struct KeywordEpisodeCard: View {
    
    let keyword: Keyword
    let episodes: [Episode]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            HStack{
                HStack(spacing: 6){
                    Image(systemName: "tag")
                        .font(.system(size: 10))
                        .foregroundStyle(.blue)
                        .padding(3)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.blue.opacity(0.25))
                                .frame(height: 20)
                        )
                    
                    Text(keyword.name)
                        .font(
                            Font.custom("SF Pro", size: 12)
                                .weight(.semibold)
                        )
                    
                    Text("\(episodes.count)")
                        .font(.system(size: 10))
                        .frame(width: 15, height: 15, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black.opacity(0.125))
                                                            
                        )
                }
            }
            
            ForEach(episodes, id: \.id) { episode in
                VStack(alignment: .leading,spacing: 7) {
                    Text(episode.experience.title)
                        .font(
                            Font.custom("SF Pro", size: 10)
                                .weight(.semibold)
                        )
                        .foregroundColor(.black)
                    
                    Text(episode.problemContext + episode.concernPoint + episode.myAction + episode.outcome)
                        .font(
                            Font.custom("SF Pro", size: 10)
                                .weight(.medium)
                        )
                        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                        .frame(maxWidth: .infinity, minHeight: 39, maxHeight: 39, alignment: .topLeading)
                }
                
                
            }
        }
        .padding(20)
        .frame(width: 232, alignment: .topLeading)
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .inset(by: 0.2)
                .stroke(Color(red: 0.53, green: 0.53, blue: 0.53), lineWidth: 0.4)
        )

    }
}

// MARK: - Preview
//#Preview {
//    let keyword = Keyword(name: "협업")
//    
//    let experience = Experience(
//        title: "C4 프로젝트",
//        periodStart: .now,
//        periodEnd: .now,
//        experienceStatement: "사용자 중심 서비스를 기획했다."
//    )
//    
//    let attachment = Attachment(
//        fileName: "sample.pdf",
//        storedFileName: "sample.pdf",
//        fileType: "pdf",
//        fileSize: 1024,
//        experience: experience
//    )
//    
//    let episode = Episode(
//        title: "역할 분담",
//        problemContext: "팀원 간 역할이 겹쳤다. ",
//        concernPoint: "일정이 지연될 수 있었다. ",
//        myAction: "업무를 재분배했다. ",
//        outcome: "프로젝트를 일정 내 완료했다.",
//        sourceExcerpt: "",
//        experience: experience,
//        keyword: keyword,
//        attachment: attachment
//    )
//    
//    KeywordEpisodeCard(
//        keyword: keyword,
//        episodes: [episode]
//    )
//    .padding()
//}
