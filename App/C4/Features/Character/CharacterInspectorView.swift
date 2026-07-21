//
//  CharacterInspectorView.swift
//  C4
//
//  Created by jiwon hong on 7/20/26.
//

import SwiftUI

enum InspectorScreen {
    case create
    case loading
    case draft
    case detail
}

struct CharacterInspectorView: View {
    
    @Bindable var viewModel: CharacterViewModel
    
    var body: some View {
        
        Group {
            switch viewModel.currentInspectorScreen {
            case .create: CharacterCreateView(viewModel: viewModel)
            case .draft: CharacterDraftView(viewModel: viewModel)
            case .loading: CharacterLoadingView(viewModel: viewModel)
            case .detail: CharacterDetailView(viewModel: viewModel)
            case nil: EmptyView()
            }
        }
        .inspectorColumnWidth(min: 350, ideal: 420, max: 600)
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
            characterTitleSection
            characterStatementSection
            keywordSection
        }
        .padding(30)
    }
    
    // MARK: Title
    private var titleSection: some View {
        VStack (alignment: .leading,spacing: 6){
            Text("캐릭터 생성하기")
                .font(
                    Font.custom("SF Pro", size: 22)
                        .weight(.bold)
                )
                .foregroundColor(.black)
            
            Text("정리한 경험을 바탕으로 키워드를 선택하여 나만의 캐릭터를 만들어보세요.")
                .font(Font.custom("SF Pro", size: 12))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
            
            Divider()
        }
    }
    
    // MARK: Character Title
    private var characterTitleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: "캐릭터명 (필수)", descriptions: "만들고 싶은 캐릭터를 한 문장이나 짧은 이름으로 표현해보세요.")
            CustomTextField(placeholder: "ex) 실패를 두려워하지 않는 개발자", text: $viewModel.draftTitle)
            
            Divider()
        }
    }
    
    // MARK: Character Statement
    private var characterStatementSection: some View {
        VStack(alignment:.leading, spacing: 6){
            SectionHeader(title: "캐릭터 설명", descriptions: "이 캐릭터가 어떤 사람인지 자유롭게 설명해주세요.")
            CustomTextField(placeholder: "ex) 개발 과정에서 마주하는 실패와 어려움을 성장의 기회로 받아들입니다.", text: $viewModel.draftCharacterStatement)
        }
    }
    
    // MARK: Keyword
    private var keywordSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: "키워드 선택", descriptions: "이 캐릭터를 가장 잘 나타내는 핵심 키워드를 1개 이상 선택해주세요.\n선택한 키워드와 연결된 경험을 모아 캐릭터를 구성합니다.")
            
            LazyVGrid(columns:columns, alignment: .leading, spacing: 15) {
                Button {
                    isKeywordPickerExpanded.toggle()
                } label: {
                    Image(systemName: "plus")
                }
                
                ForEach (viewModel.draftKeywords, id: \.id) {keyword in
                    KeywordTag(text: keyword.name, onRemove: {
                        viewModel.removeDraftKeyword(keyword)
                    }, style: .selected)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if isKeywordPickerExpanded {
                TextField("검색",text: $viewModel.searchText)
                
                LazyVGrid(columns:columns, alignment: .leading){
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
            Divider()
        }
    }
}

// MARK: - Character Loading View
struct CharacterLoadingView: View {
    
    @Bindable var viewModel: CharacterViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 26) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 138, height: 138)
                .background(
                    Image("PATH_TO_IMAGE")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 138, height: 138)
                        .clipped()
                )
                .cornerRadius(7)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .inset(by: 0.5)
                        .stroke(.black, lineWidth: 1)
                )
            
            Text("자료를 읽고 있어요")
                .font(
                    Font.custom("Inter", size: 17)
                        .weight(.bold)
                )
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text("자료를 취합하는 중입니다.\n잠시만 기다려 주세요.")
                .font(Font.custom("SF Pro", size: 17))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("37%")
                .font(Font.custom("SF Pro", size: 17))
                .foregroundColor(.black)
            
            Image("Line 4")
                .frame(maxWidth: .infinity)
                .overlay(
                    Rectangle()
                        .stroke(Color(red: 0.79, green: 0.79, blue: 0.79), lineWidth: 10)
                )
                .rotationEffect(Angle(degrees: 0.07))
            
            Text("텍스트 추출 완료!\n\n키워드 분석 중...\n\n중심 경험 요약 중...\n\n경험 생성 중...")
                .font(Font.custom("SF Pro", size: 13))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Character Draft View
struct CharacterDraftView: View {

    @Bindable var viewModel: CharacterViewModel

    private let keywordColumns = [GridItem(.adaptive(minimum:50),spacing: 8, alignment: .leading)]
    private let episodeColumns = [GridItem(.adaptive(minimum:232), spacing: 8, alignment: .leading)]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            titleSection
            characterTitleSection
            characterStatementSection
            keywordSection
            episodeSection
        }
        .padding(30)
    }
    
    // MARK: Title
    private var titleSection: some View {
        VStack(alignment: .leading,spacing: 6){
            Text("캐릭터 초안")
                .font(
                    Font.custom("SF Pro", size: 22)
                        .weight(.bold)
                )
                .foregroundColor(.black)
            
            Text("편집 버튼을 눌러 내용을 수정 후 캐릭터를 완성해보세요.")
                .font(Font.custom("SF Pro", size: 12))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
            
            Divider()
        }
    }
    
    // MARK: - Character Title
    private var characterTitleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: "캐릭터명")
            
            Group {
                if viewModel.isEditingDraft == true {
                    CustomTextField(placeholder: "", text: $viewModel.draftTitle)
                } else {
                    Text(viewModel.draftTitle)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            Divider()
        }
    }
    
    // MARK: Keyword
    private var keywordSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: "키워드 선택")
            
            LazyVGrid(columns: keywordColumns, alignment: .leading, spacing: 15) {
                
                ForEach(viewModel.draftKeywords, id: \.id) {keyword in
                    KeywordTag(text: keyword.name,onRemove: {
                        viewModel.removeDraftKeyword(keyword)
                    },style: .selected)
                }
            }
            .background(.clear)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .overlay{
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(red: 0.77, green: 0.77, blue: 0.77), lineWidth: 1)
            }
            Divider()
        }
    }
    
    // MARK: Character Statement
    private var characterStatementSection: some View {
        VStack(alignment:.leading, spacing: 6){
            
            SectionHeader(title: "캐릭터 설명")
            
            Group {
                if viewModel.isEditingDraft {
                    CustomTextField(placeholder: "", text: $viewModel.draftCharacterStatement)
                } else {
                    Text(viewModel.draftCharacterStatement)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            Divider()
        }
    }
    
    // MARK: Episode
    private var episodeSection: some View {
        VStack(alignment: .leading, spacing: 6){
            SectionHeader(title: "키워드와 연결된 에피소드")
            
            LazyVGrid(columns: episodeColumns,alignment: .leading, spacing: 8) {
                ForEach(viewModel.draftKeywords, id: \.id) { keyword in
                    KeywordEpisodeCard(keyword: keyword, episodes: viewModel.episodesForKeyword(keyword: keyword))
                }
            }
        }
    }
}

// MARK: - Character Detail View
struct CharacterDetailView: View {
    
    @Bindable var viewModel: CharacterViewModel
    
    private let episodeColumns = [GridItem(.adaptive(minimum:232), spacing: 8, alignment: .top)]
    
    var body: some View {
        if let character = viewModel.selectedCharacter {
            
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 10) {
                    Image("캐릭터")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        
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
                    SectionHeader(title: "키워드")

                    LazyVGrid(columns: episodeColumns, alignment: .leading, spacing: 8){
                        ForEach(character.keywords, id: \.id) { keyword in
                            KeywordEpisodeCard(keyword: keyword, episodes: keyword.episodes)
                        }
                    }
                }

            }
            .padding(30)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(
              LinearGradient(
                stops: [
                  Gradient.Stop(color: Color(red: 0.85, green: 0.85, blue: 0.93), location: 0.00),
                  Gradient.Stop(color: .white, location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 0.13)
              )
            )
            .cornerRadius(15)
        }
    }
}





//#Preview {
//    CharacterInspectorView()
//}
