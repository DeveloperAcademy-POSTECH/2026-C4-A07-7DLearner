//
//  CharacterInspectorView.swift
//  C4
//
//  Created by jiwon hong on 7/20/26.
//

import SwiftUI

struct CharacterInspectorView: View {
    
    @Bindable var viewModel: CharacterViewModel
    
    var body: some View {
        
        Group {
            switch viewModel.currentInspectorScreen {
            case .empty: CharacterEmptyView()
            case .create: CharacterCreateView(viewModel: viewModel)
            case .draft: EmptyView()
            case .loading: EmptyView()
            case .detail: CharacterDetailView(viewModel: viewModel)
            }
        }
    }
}

private struct CharacterEmptyView: View {
    var body: some View {
        Text("캐릭터를 선택하거나 새로운 캐릭터를 만들어보세요")
    }
}


// MARK: - Character Create View
private struct CharacterCreateView: View {
    
    @Bindable var viewModel: CharacterViewModel
    @State private var isKeywordPickerExpanded = false
    
    private let columns = [GridItem(.adaptive(minimum:50),spacing: 8, alignment: .leading)]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            titleSection
                .padding(.bottom, 29)
            
            if viewModel.isEditing {
                characterCard
                    .padding(.bottom, 48)
            }
            
            characterTitleSection
                .padding(.bottom, 48)
            characterStatementSection
                .padding(.bottom, 48)
            keywordSection
        }
        .padding(30)
        .padding(.top, 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    // MARK: characterCard
    private var characterCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("캐릭터 카드")
                .font(
                    Font.custom("SF Pro", size: 15)
                        .weight(.semibold)
                )
            
            Group {
                if viewModel.isEditing  {
                    if let character = viewModel.selectedCharacter {
                        DetailCharacterCard(character: character, keywords: character.keywords)
                    }
                }
            }
        }
    }
    
    // MARK: Title
    private var titleSection: some View {
        VStack (alignment: .leading, spacing: 6){
            Text(viewModel.isEditing ? "캐릭터 편집" : "캐릭터 생성하기")
                .font(
                    Font.custom("SF Pro", size: 22)
                        .weight(.bold)
                )
                .foregroundColor(.black)
            
            Text(viewModel.isEditing ? "나를 표현하는 캐릭터를 수정해보세요!" : "정리한 경험을 바탕으로 키워드를 선택하여 나만의 캐릭터를 만들어보세요.")
                .font(Font.custom("SF Pro", size: 12))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
        }
    }
    
    // MARK: Character Title
    private var characterTitleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: "캐릭터명", descriptions: "만들고 싶은 캐릭터를 한 문장이나 짧은 이름으로 표현해보세요.")
            
            Group {
                if viewModel.isEditing {
                    CustomTextField(placeholder: "", text: $viewModel.draftTitle)
                } else {
                    CustomTextField(placeholder: "ex) 실패를 두려워하지 않는 개발자", text: $viewModel.draftTitle)
                }
            }
            
            Divider()
        }
    }
    
    // MARK: Character Statement
    private var characterStatementSection: some View {
        VStack(alignment:.leading, spacing: 6){
            SectionHeader(title: "캐릭터 설명", descriptions: "이 캐릭터가 어떤 사람인지 자유롭게 설명해주세요.")
            
            Group {
                if viewModel.isEditing {
                    CustomTextField(placeholder: "", text: $viewModel.draftCharacterStatement)
                } else {
                    CustomTextField(placeholder: "ex) 개발 과정에서 마주하는 실패와 어려움을 성장의 기회로 받아들입니다.", text: $viewModel.draftCharacterStatement)
                }
            }
            
            Divider()
        }
    }
    
    // MARK: Keyword
    private var keywordSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: "키워드 선택", descriptions: "이 캐릭터를 가장 잘 나타내는 핵심 키워드를 1개 이상 선택해주세요.")
            
            Group {
                if viewModel.isEditing {
                    
                    HStack {
                        Button {
                            isKeywordPickerExpanded.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(viewModel.draftKeywords, id: \.id) { keyword in
                                    KeywordTag(text: keyword.name,onRemove: {
                                        viewModel.draftKeywords.removeAll { $0.id == keyword.id }
                                    },style: .selected)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
    
                    if isKeywordPickerExpanded {
                        VStack {
                            TextField("검색",text: $viewModel.searchText)
                            
                            ScrollView(.horizontal) {
                                HStack(spacing: 10) {
                                    ForEach (viewModel.filteredKeywords, id: \.id) {keyword in
                                        Button {
                                            viewModel.addDraftKeyword(keyword)
                                            viewModel.searchText = ""
                                        } label: {
                                            KeywordTag(text: keyword.name, style: .picker)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                } else {
                    
                    HStack {
                        Button {
                            isKeywordPickerExpanded.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(viewModel.draftKeywords, id: \.id) { keyword in
                                    KeywordTag(
                                        text: keyword.name,
                                        onRemove: {
                                            viewModel.removeDraftKeyword(keyword)
                                        },
                                        style: .selected
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    if isKeywordPickerExpanded {
                        VStack {
                            TextField("검색",text: $viewModel.searchText)
                            
                            ScrollView(.horizontal) {
                                HStack(spacing: 10) {
                                    ForEach (viewModel.filteredKeywords, id: \.id) {keyword in
                                        Button {
                                            viewModel.addDraftKeyword(keyword)
                                            viewModel.searchText = ""
                                        } label: {
                                            KeywordTag(text: keyword.name, style: .picker)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                
            }
        }
    }
}

// MARK: - Character Detail View
private struct CharacterDetailView: View {
    
    @State private var selectedKeyword: Keyword?
    @Bindable var viewModel: CharacterViewModel
    
    private let episodeColumns = [GridItem(.adaptive(minimum:232), spacing: 8, alignment: .top)]
    
    var body: some View {
        if let character = viewModel.selectedCharacter {
            
            VStack(alignment: .leading, spacing: 28) {
                HStack(alignment: .top, spacing: 10) {
                    ZStack {
                        Image(character.bodyAssetName)
                            .resizable()
                            .scaledToFit()
                        Image(character.headAssetName)
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 52, height: 57)
                    
        //            RoundedRectangle(cornerRadius: 7)
        //                .fill(Color.gray.opacity(0.2))
        //                .frame(width: 52, height: 57)
                    
                    VStack(alignment:.leading, spacing: 12){
                        Text(character.title)
                            .font(
                                Font.custom("SF Pro", size: 12)
                                    .weight(.semibold)
                            )
                            .foregroundColor(.black)
                        
                        Text(character.characterStatement)
                            .font(Font.custom("SF Pro", size: 12))
                            .foregroundColor(.black)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "키워드", descriptions: "키워드 카드를 눌러 자세한 내용을 확인하세요")
                    
                    ScrollView(.horizontal,) {
                        HStack(alignment: .top, spacing: 9) {
                            ForEach(character.keywords, id: \.id) { keyword in
                                KeywordEpisodeCard(keyword: keyword, episodes: keyword.episodes, episodeLimit: 2, showsSummary: true)
                                    .padding(20)
                                    .frame(width: 230, alignment: .topLeading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                selectedKeyword?.id == keyword.id ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color.white)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .inset(by: 0.2)
                                            .stroke(
                                                Color(red: 0.53, green: 0.53, blue: 0.53),
                                                lineWidth: 0.4
                                            )
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedKeyword = keyword
                                    }
                            }
                        }
                    }
                    
                    Divider()
                    
                    if let selectedKeyword {
                        ScrollView {
                            KeywordEpisodeCard(keyword: selectedKeyword, episodes: selectedKeyword.episodes, episodeLimit: nil, showsSummary: false)
                        }
                        .padding(.top, 50)
                    }
                }
            }
            .padding(30)
            .padding(.top, 50)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}



//#Preview {
//    CharacterInspectorView()
//}
