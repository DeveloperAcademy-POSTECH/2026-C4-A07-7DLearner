//
//  InfoPopover.swift
//  Origo
//
//  Created by jiwon hong on 7/23/26.
//

import SwiftUI

struct InfoPopover: View {
    
    let message1: String
    let message2: String
    let message3: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            PopoverText(title: "왜 만들어요?", message: message1)
            PopoverText(title: "어떻게 만들어요?", message: message2)
            PopoverText(title: "다음에는?", message: message3)
        }
        .padding(24)
        .frame(width: 380, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.black.opacity(0.06), lineWidth: 0.5)
        }
        .shadow(
            color: .black.opacity(0.12),
            radius: 10,
            x: 0,
            y: 6
        )
    }
}

private struct PopoverText: View {
    
    let title: String
    let message: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(
                    Font.custom("SF Pro", size: 11)
                        .weight(.semibold)
                )
                .foregroundColor(Constants.unnamed2)
            
            Text(message)
                .font(
                    Font.custom("SF Pro", size: 10)
                        .weight(.light)
                )
                .foregroundColor(.black)
        }
       
    }
}





//#Preview {
//    InfoPopover()
//}
