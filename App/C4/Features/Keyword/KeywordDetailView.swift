//
//  KeywordDetailView.swift
//  C4
//
//  Created by 박시은 on 7/20/26.
//

import SwiftUI

struct KeywordDetailView: View {
    
    let keyword: Keyword
    let episodes: [Episode]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(keyword.name)
                    .font(Font.custom("SF Pro", size: 22).weight(.bold))
                    .foregroundColor(.black)
                
                Text("이 키워드에 연결된 에피소드가 \(episodes.count)개 있습니다.")
                
                // 캐릭터창 KeywordEpisodeCard 배치
            }
            .padding(30)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}
