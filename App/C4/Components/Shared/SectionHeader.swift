//
//  SectionHeader.swift
//  C4
//
//  Created by jiwon hong on 7/21/26.
//

import SwiftUI

struct SectionHeader: View {
    
    let title: String
    let descriptions: String?
    
    // descriptions = nil 기본값 넣어주기~
    init(
            title: String,
            descriptions: String? = nil
        ) {
            self.title = title
            self.descriptions = descriptions
        }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(
                    Font.custom("SF Pro", size: 15)
                        .weight(.semibold)
                )
                .foregroundColor(.black)
            
            if let descriptions {
                Text(descriptions)
                    .font(Font.custom("SF Pro", size: 12))
                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
            }
        }
        

    }
}

//#Preview {
//    SectionHeader()
//}
