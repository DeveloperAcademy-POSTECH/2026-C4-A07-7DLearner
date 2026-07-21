//
//  CustomTextEditor.swift
//  C4
//
//  Created by jiwon hong on 7/21/26.
//

import SwiftUI

struct CustomTextEditor: View {

    let placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .topLeading) {

            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }

            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 68)
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

//#Preview {
//    CustomTextEditor()
//}
