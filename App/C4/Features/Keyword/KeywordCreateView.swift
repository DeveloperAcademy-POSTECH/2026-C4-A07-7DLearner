//
//  KeywordCreateView.swift
//  C4
//
//  Created by 박시은 on 7/20/26.
//

import SwiftUI
import SwiftData

struct KeywordCreateView: View {
    
    // MARK: ViewModel
    @Bindable var viewModel: KeywordViewModel
    
    // MARK: - State Properties
    @State private var experienceTitle: String = ""
    @State private var startDate: String = ""
    @State private var endDate: String = ""
    @State private var statement: String = ""
    
    // 키워드 입력 및 관리용 state
    @State private var newKeyword: String = ""
    @State private var selectedKeywords: [String] = ["협업", "실패", "소통", "회복 탄력성"]
    
    var body: some View {
        // MARK: - 입력 폼
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 경험 명, 기간
                HStack(alignment: .top, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "경험 명", descriptions: "무엇을 했던 경험인가요?")
                        CustomTextField(placeholder: "애플 디벨로퍼 아카데미 C4", text: $experienceTitle)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "기간", descriptions: "해당 경험을 얼마나 진행했나요?")
                        HStack(spacing: 8) {
                            CustomTextField(placeholder: "YYYY.MM.DD", text: $startDate)
                            Text("—")
                                .foregroundColor(.gray)
                            CustomTextField(placeholder: "YYYY.MM.DD", text: $endDate)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 17)
                
                Divider()
                    .padding(.bottom, 63)
                
                // 키워드 작성
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "키워드 작성", descriptions: "이 경험을 가장 잘 나타내는 핵심 키워드를 1개 이상 작성해주세요.\n선택한 키워드에 맞게 에피소드를 구성합니다.")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(selectedKeywords, id: \.self) { keyword in
                                KeywordTag(text: keyword, onRemove: {
                                    selectedKeywords.removeAll { $0 == keyword }
                                }, style: .selected)
                            }
                            
                            //
                        }
                    }
                }
            }
        }
    }
}

