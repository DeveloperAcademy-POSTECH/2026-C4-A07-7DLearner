//
//  CharacterView.swift
//  C4
//
//  Created by jiwon hong on 7/20/26.
//

import SwiftUI
import SwiftData

struct CharacterView: View {
    
    @State private var viewModel: CharacterViewModel
    @State private var isDeleteConfirmationPresented = false
    @State private var isInfoPopoverPresented = false
    @Query private var characters: [Character]
        
    private let columns = [
        GridItem(.fixed(228), spacing: 24),
        GridItem(.fixed(228), spacing: 24)
    ]
    
    init(viewModel: CharacterViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        Group {
                switch viewModel.currentInspectorScreen {
                    
                case .create:
                    if viewModel.draftKeywords.isEmpty {
                        CharacterList
                       
                    } else {
                        SelectedKeywordView(viewModel: viewModel)
                    }
                    
                case.detail:
                    if viewModel.isEditing == false {
                        CharacterList
                    } else {
                        if viewModel.draftKeywords.isEmpty {
                            CharacterList
                           
                        } else {
                            SelectedKeywordView(viewModel: viewModel)
                        }
                    }
                
                default:
                    CharacterList
                }
            }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .inspector(isPresented: Binding(
            get: { true },
            set: { _ in }
        )
        ){
            CharacterInspectorView(viewModel: viewModel)
        }
        .toolbar {
            characterToolbar
        }
        .confirmationDialog(
            "캐릭터를 삭제하시겠습니까?",
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible) {
                Button("삭제", role: .destructive) {
                    if let character = viewModel.selectedCharacter {
                        viewModel.delete(character)
                    }
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("삭제한 캐릭터는 복구할 수 없습니다.")
            }
    }
    
    // MARK: - CharacterList
    private var CharacterList: some View {
        VStack (alignment: .leading) {
            
            VStack (alignment: .leading, spacing: 3){
                
                HStack (alignment: .firstTextBaseline) {
                    Text("캐릭터")
                        .font(
                            Font.custom("SF Pro", size: 17)
                                .weight(.semibold)
                        )
                        .foregroundColor(.black)
                    
                    Button {
                        isInfoPopoverPresented = true
                    } label: {
                         Image(systemName: "info.circle")
                            .font(.system(size: 14, weight: .semibold))
                            .offset(y: -1)
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $isInfoPopoverPresented,arrowEdge: .top) {
                        InfoPopover(
                            message1: "관련 키워드와 경험을 활용해, 특정 분야나 역량을 보여주는 ‘캐릭터'를 만들어요.",
                            message2: "‘새 캐릭터’를 눌러 보여주고 싶은 키워드를 고른 뒤, 캐릭터를 만들어요.",
                            message3: "만든 캐릭터를 선택해 연결된 키워드와 에피소드를 한눈에 확인할 수 있어요.\n또한, 목적에 맞는 캐릭터들을 오피스에 모을 수 있어요.")
                    }
                    
                    
                }
                

                Text("CV와 포트폴리오를 위한 캐릭터를 만들어보세요!")
                  .font(Font.custom("SF Pro", size: 10))
                  .foregroundColor(Constants.ndTextColor)
                  .frame(width: 252, height: 13, alignment: .leading)
            }
            .padding(.top, 30)
            .padding(.horizontal, 30)
           
            
            
            
            if characters.isEmpty {
                Text("아직 생성된 캐릭터가 없습니다. \n+ 버튼을 눌러 새로운 캐릭터를 만들어 보세요")
            }
            else {
                ScrollView {
                    LazyVGrid(

                        columns: columns,

                        alignment: .leading,

                        spacing: 16

                    )  {
                        ForEach(characters, id: \.id){ character in
                            
                            Group {
                                if character == viewModel.selectedCharacter {
                                    CharacterCard(character: character, keywordLimit: 2, isSelected: true)
                                } else {
                                    CharacterCard(character: character, keywordLimit: 2, isSelected: false)
                                }
                            }
                                .onTapGesture {
                                    viewModel.selectCharacter(character)
                                }
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
        }
        
    }
    
    
    // MARK: - SelectedKeywordView
    private struct SelectedKeywordView: View {
        
        @Bindable var viewModel: CharacterViewModel
        
        var body: some View {
            
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "선택된 키워드", descriptions: "키워드별 에피소드를 확인해보세요!")
                    
                    ScrollView {

                        VStack(alignment: .leading) {
                            ForEach(viewModel.draftKeywords, id: \.id) { keyword in
                                
                                    KeywordEpisodeCard(
                                        keyword: keyword,
                                        episodes: keyword.episodes,
                                        episodeLimit: nil,
                                        showsSummary: false
                                    )
                                    .padding(20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white)
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
                        }
                        }
                        
                    }
                }
                .padding(30)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
    
    // MARK:  - Toolbar
    @ToolbarContentBuilder
    private var characterToolbar: some ToolbarContent {
        switch viewModel.currentInspectorScreen {
            
        case.empty:
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.startCharacterCreation()
                } label: {
                    Text("+ 새 캐릭터")
                }
            }
            
        case .create:
            if viewModel.isEditing {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        viewModel.currentInspectorScreen = .detail
                        viewModel.isEditing = false
                    } label: {
                        Text("취소")
                            .font(
                            Font.custom("SF Pro", size: 13)
                            .weight(.medium)
                            )
                            .foregroundColor(Constants.LabelsVibrantUsePlusLighterDarkerPrimary)
                            
                    }
                    .buttonStyle(.glass)
                }
                
                ToolbarSpacer()
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.saveEditedCharacter()
                    } label: {
                        Text("저장")
                            .font(
                            Font.custom("SF Pro", size: 13)
                            .weight(.medium)
                            )
                            .foregroundColor(Constants.LabelsWhite)
                            
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!viewModel.isDraftReadyToSave)
                }
            } else {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        viewModel.currentInspectorScreen = .empty
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.glass)
                }
                
                ToolbarSpacer()
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        //action
                    } label: {
                        Text("임시저장")
                            .font(
                            Font.custom("SF Pro", size: 13)
                            .weight(.medium)
                            )
                            .foregroundColor(Constants.LabelsVibrantUsePlusLighterDarkerPrimary)
                    }
                    .buttonStyle(.glass)
                }
                

                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.completeCharacterGeneration()
                    } label: {
                        Text("생성")
                            .font(
                            Font.custom("SF Pro", size: 13)
                            .weight(.medium)
                            )
                            .foregroundColor(Constants.LabelsWhite)
                            
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!viewModel.isDraftReadyToSave)
                }
            }
            
        case .loading:
            ToolbarItem(placement: .primaryAction) {
                Button {
                 //
                } label: {
                   //
                }
            }
        case .draft:
            ToolbarItem(placement: .automatic) {
            }
                        
        case .detail:
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        isDeleteConfirmationPresented = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            
            
            ToolbarSpacer()
            
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.startCharacterCreation()
                } label: {
                    Text("+ 새 캐릭터")
                }
                .buttonStyle(.glass)
            }
            
            ToolbarSpacer()
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.startEditingCharacter()
                } label: {
                    Text("편집")
                }
                .buttonStyle(.glass)
            }
        }
        
    }
    
}

// MARK: - Preview
//#Preview {
//    let container = try! ModelContainer(
//        for: Character.self,
//        Keyword.self,
//        Episode.self,
//        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//    )
//    
//    let keyword1 = Keyword(name: "협업")
//    let keyword2 = Keyword(name: "회복탄력성")
//    let keyword3 = Keyword(name: "책임감")
//    
//    let character1 = Character(
//        title: "기획자",
//        characterStatement: "사용자 중심으로 사고한다.",
//        keywords: [keyword1, keyword2, keyword3]
//    )
//    
//    let character2 = Character(
//        title: "문제 해결사",
//        characterStatement: "문제를 끝까지 해결한다.",
//        keywords: [keyword2, keyword3]
//    )
//    
//    container.mainContext.insert(keyword1)
//    container.mainContext.insert(keyword2)
//    container.mainContext.insert(keyword3)
//    
//    container.mainContext.insert(character1)
//    container.mainContext.insert(character2)
//    
//    try! container.mainContext.save()
//    
//    let viewModel = CharacterViewModel(
//        modelContext: container.mainContext
//    )
//    
//    return CharacterView(viewModel: viewModel)
//        .modelContainer(container)
//}
