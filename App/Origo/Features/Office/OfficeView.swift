//
//  OfficeView.swift
//  C4
//
//  Created by YOOJUN PARK on 7/22/26.
//

import SwiftUI
import SwiftData

struct OfficeView: View {
    
    @Query private var offices: [Office]
    @Query private var characters: [Character]
    
    @State private var viewModel: OfficeViewModel
    
    init(viewModel: OfficeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            activeOffice
            officeList
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("오피스")
        .toolbar {
            officeToolbar
        }
    }
    
}

// MARK: - 활성 오피스
private extension OfficeView {
    
    @ViewBuilder
    var activeOffice: some View {
        if let office = viewModel.selectedOffice {
            VStack(alignment: .leading, spacing: 8) {
                Text(office.title)
                    .font(.title)
                
                OfficeCanvasService(characters: office.characters) { character in
                    viewModel.selectCharacter(character) // onSelect() 콜백 클로저
                }
                .frame(height: 320)
            }
        } else {
            Text("목록에서 오피스를 선택하세요")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 320)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.1))
                )
        }
    }
    
}

// MARK: - 오피스 목록
private extension OfficeView {
    
    var officeList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("오피스 목록")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 8)], spacing: 8) {
                ForEach(offices, id: \.id) { office in
                    officeRow(office)
                }
            }
        }
    }
    
    func officeRow(_ office: Office) -> some View {
        Button {
            viewModel.activate(office)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(office.title)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                Text("캐릭터 \(office.characters.count)명")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(viewModel.selectedOffice?.id == office.id
                          ? Color.accentColor
                          : Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
    
}

// MARK: - 툴바
private extension OfficeView {
    
    @ToolbarContentBuilder
    var officeToolbar: some ToolbarContent {
        switch viewModel.currentInspectorScreen {
        case .create:
            ToolbarItem(placement: .navigation) {
                Button {
                    viewModel.cancelCreating()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("생성") {
                    viewModel.createOffice(from: characters)
                }
                .disabled(!viewModel.isDraftReadyToSave)
            }
        default:
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.startCreating()
                } label: {
                    Label("새 오피스", systemImage: "plus")
                }
            }
        }
    }
    
}

// MARK: - 인스펙터
extension OfficeView {
    
    @ViewBuilder
    static func inspectorContent(viewModel: OfficeViewModel, characters: [Character]) -> some View {
        switch viewModel.currentInspectorScreen {
        case .create:
            OfficeCreateView(viewModel: viewModel, allCharacters: characters)
        case .detail:
            if let character = viewModel.selectedCharacter {
                characterDetail(character)
            }
        default:
            Text("오피스에 돌아다니는 캐릭터를 눌러보세요~^^")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
}

private extension OfficeView {
    
    // 캐릭터 상세 뷰
    @ViewBuilder
    static func characterDetail(_ character: Character) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CharacterCard(character: character, keywordLimit: nil, isSelected: false)
                
                SectionHeader(title: "키워드", descriptions: "해당 캐릭터를 구성하는 키워드와 에피소드")
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 232), spacing: 8, alignment: .top)],
                          alignment: .leading, spacing: 8) {
                    ForEach(character.keywords, id: \.id) { keyword in
                        KeywordEpisodeCard(keyword: keyword, episodes: keyword.episodes, episodeLimit: nil, showsSummary: true)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
    
}

// MARK: - 새 오피스 생성 뷰
private struct OfficeCreateView: View {
    
    @Bindable var viewModel: OfficeViewModel
    let allCharacters: [Character]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "새로운 오피스 생성하기", descriptions: "캐릭터를 선택해 오피스를 구성하세요.")
                
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "오피스 이름", descriptions: "오피스의 이름을 지어주세요.")
                    CustomTextField(placeholder: "ex) 박유준의 멋진 오피스", text: $viewModel.draftTitle)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "캐릭터 선택", descriptions: "오피스에 배치할 캐릭터를 1개 이상 선택해주세요.")
                    
                    ForEach(allCharacters, id: \.id) { character in
                        Toggle(character.title, isOn: Binding(
                            get: { viewModel.draftCharacterIDs.contains(character.id) },
                            set: { isOn in
                                if isOn { viewModel.draftCharacterIDs.insert(character.id) }
                                else { viewModel.draftCharacterIDs.remove(character.id) }
                            }
                        ))
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
    
}

#Preview {
    let container = try! ModelContainer(
        for: Attachment.self, Character.self, Episode.self, Experience.self, Keyword.self, Office.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    return OfficeView(viewModel: OfficeViewModel(modelContext: container.mainContext))
        .modelContainer(container)
}
