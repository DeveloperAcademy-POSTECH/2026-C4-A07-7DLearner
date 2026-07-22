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
    @Query private var characters: [Character]
    
    //    @Query(sort: \Character.createdAt, order: .reverse) private var characters: [Character]
        
    private let columns = [GridItem(.adaptive(minimum: 224))]
    
    init(viewModel: CharacterViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack{
            if characters.isEmpty {
                Text("아직 생성된 캐릭터가 없습니다. + 버튼을 눌러 새로운 캐릭터를 만들어 보세요")
            }
            else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(characters, id: \.id){ character in
                            CharacterCard(character: character, keywordLimit: 2)
                                
                                .onTapGesture {
                                    viewModel.selectCharacter(character)
                                }
                        }
                    }
                }
                .padding()
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
                    Image(systemName: "plus")
                }
            }
            
        case .create:
            
            if viewModel.isEditing {
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.currentInspectorScreen = .detail
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
                    .tint(.blue)
                    .disabled(!viewModel.isDraftReadyToSave)
                }
            } else {
                ToolbarItem(placement: .navigation) {
                    Button {
                        viewModel.currentInspectorScreen = .empty
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.glass)
                }
                
                ToolbarItem(placement: .primaryAction) {
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
                
                ToolbarSpacer()
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.completeCharacterGeneration()
                    } label: {
                        Text("분석")
                            .font(
                            Font.custom("SF Pro", size: 13)
                            .weight(.medium)
                            )
                            .foregroundColor(Constants.LabelsWhite)
                            
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.blue)
                    .disabled(!viewModel.isDraftReadyToSave)
                }
            }
            
        case .loading:
            ToolbarItem(placement: .primaryAction) {
                Button {

                    viewModel.currentInspectorScreen = .detail
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
        case .draft:
            ToolbarItem(placement: .automatic) {
                
            }
                        
        case .detail:
            ToolbarItem(placement: .automatic) {
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
#Preview {
    let container = try! ModelContainer(
        for: Character.self,
        Keyword.self,
        Episode.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let keyword1 = Keyword(name: "협업")
    let keyword2 = Keyword(name: "회복탄력성")
    let keyword3 = Keyword(name: "책임감")
    
    let character1 = Character(
        title: "기획자",
        characterStatement: "사용자 중심으로 사고한다.",
        keywords: [keyword1, keyword2, keyword3]
    )
    
    let character2 = Character(
        title: "문제 해결사",
        characterStatement: "문제를 끝까지 해결한다.",
        keywords: [keyword2, keyword3]
    )
    
    container.mainContext.insert(keyword1)
    container.mainContext.insert(keyword2)
    container.mainContext.insert(keyword3)
    
    container.mainContext.insert(character1)
    container.mainContext.insert(character2)
    
    try! container.mainContext.save()
    
    let viewModel = CharacterViewModel(
        modelContext: container.mainContext
    )
    
    return CharacterView(viewModel: viewModel)
        .modelContainer(container)
}
