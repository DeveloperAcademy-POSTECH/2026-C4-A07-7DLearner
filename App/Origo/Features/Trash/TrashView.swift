//
//  TrashView.swift
//  C4
//
//  Created by YOOJUN PARK on 7/22/26.
//

import SwiftUI
import SwiftData

struct TrashView: View {
    
    @Query private var keywords: [Keyword]
    @Query private var characters: [Character]
    @Query private var experiences: [Experience]
    
    @State private var viewModel: TrashViewModel
    
    init(viewModel: TrashViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            tabPicker
            itemList
        }
        .navigationTitle("휴지통")
        .toolbar {
            trashToolbar
        }
        .alert("항목을 영구삭제 할까요?", isPresented: $viewModel.isShowingDeleteConfirmation) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) { viewModel.deleteSelected() }
        } message: {
            Text("선택한 항목을 영구삭제 합니다.")
        }
    }
    
}

// MARK: - 헤더
private extension TrashView {
    
    var header: some View {
        Text("7일 뒤면 삭제 됩니다!!")
            .font(.caption)
            .foregroundStyle(.red)
            .padding(.horizontal)
            .padding(.top, 8)
    }
    
}

// MARK: - 탭
private extension TrashView {
    
    var tabPicker: some View {
        Picker("", selection: Binding(
            get: { viewModel.selectedTab },
            set: { viewModel.changeTab(to: $0) }
        )) {
            ForEach(TrashTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .padding(.horizontal)
    }
    
}

// MARK: - 목록
private extension TrashView {
    
    @ViewBuilder
    var itemList: some View {
        switch viewModel.selectedTab {
        case .keyword:
            List(keywords, id: \.id, selection: keywordSelection) { keyword in
                row(title: keyword.name,
                    subtitle: keyword.episodes.first?.title ?? "에피소드 없음")
                .tag(keyword)
            }
        case .character:
            List(characters, id: \.id, selection: characterSelection) { character in
                row(title: character.title,
                    subtitle: character.characterStatement)
                .tag(character)
            }
        case .experience:
            List(experiences, id: \.id, selection: experienceSelection) { experience in
                row(title: "\(experience.title) → \(experience.keywords.map(\.name).joined(separator: ", "))",
                    subtitle: "에피소드 \(experience.episodes.count)개 / 첨부 \(experience.attachments.count)개")
                .tag(experience)
            }
        }
    }
    
    // item의 제목 + 부제 set
    func row(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body.weight(.semibold))
                .lineLimit(1)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
    
    // List가 탭별로 다른 타입을 받으므로, 각각 변환 작업 필요
    var keywordSelection: Binding<Keyword?> {
        Binding(
            get: {
                if case .keyword(let keyword) = viewModel.selection { return keyword }
                return nil
            },
            set: { keyword in
                if let keyword { viewModel.select(.keyword(keyword)) }
            }
        )
    }
    
    var characterSelection: Binding<Character?> {
        Binding(
            get: {
                if case .character(let character) = viewModel.selection { return character }
                return nil
            },
            set: { character in
                if let character { viewModel.select(.character(character)) }
            }
        )
    }
    
    var experienceSelection: Binding<Experience?> {
        Binding(
            get: {
                if case .experience(let experience) = viewModel.selection { return experience }
                return nil
            },
            set: { experience in
                if let experience { viewModel.select(.experience(experience)) }
            }
        )
    }
    
}

// MARK: - 툴바
private extension TrashView {
    
    @ToolbarContentBuilder
    var trashToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            
            // 영구삭제
            Button {
                viewModel.requestDelete()
            } label: {
                Label("영구 삭제", systemImage: "trash")
            }
            .disabled(viewModel.selection == nil)
            
            // 복원
            Button {
                // TODO: 복원 기능
            } label: {
                Label("복원", systemImage: "tray.and.arrow.up")
            }
            .disabled(true)
            
        }
    }
    
}

// MARK: - 인스펙터
extension TrashView {
    
    @ViewBuilder
    static func inspectorContent(viewModel: TrashViewModel) -> some View{
        switch viewModel.selection {
        case .keyword(let keyword):
            keywordDetail(keyword)
        case .character(let character):
            characterDetail(character)
        case .experience(let experience):
            experienceDetail(experience)
        case nil:
            Text("항목을 선택하세요")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
}

private extension TrashView {
    
    // MARK: 키워드 상세
    static func keywordDetail(_ keyword: Keyword) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: keyword.name, descriptions: "이 키워드에 연결된 에피소드예요")
                
                Divider()
                
                ForEach(keyword.episodes, id: \.id) { episode in
                    episodeBullets(episode)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
    
    // MARK: 캐릭터 상세
    static func characterDetail(_ character: Character) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CharacterCard(character: character, keywordLimit: nil, isSelected: false)
                
                Divider()
                
                SectionHeader(title: "키워드", descriptions: "이 캐릭터를 구성하는 키워드와 에피소드예요")
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 232), spacing: 8, alignment: .top)],
                          alignment: .leading, spacing: 8) {
                    ForEach(character.keywords, id: \.id) { keyword in
                        KeywordEpisodeCard(keyword: keyword, episodes: keyword.episodes, episodeLimit: 3, showsSummary: true)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
    
    // MARK: 경험 상세
    static func experienceDetail(_ experience: Experience) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("개요")
                    .font(.title3.weight(.bold))
                
                overviewSection(experience)
                
                Divider()
                
                ForEach(experience.keywords, id: \.id) { keyword in
                    VStack(alignment: .leading, spacing: 10) {
                        KeywordTag(text: keyword.name, style: .selected)
                        
                        ForEach(experience.episodes.filter { $0.keyword.id == keyword.id }, id: \.id) { episode in
                            episodeBullets(episode)
                        }
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
    
    // 개요 밑 경험 명 기간 등 템플릿
    static func overviewSection(_ experience: Experience) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("경험 명").font(.callout.weight(.semibold))
                fieldBox(experience.title)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("기간").font(.callout.weight(.semibold))
                HStack(spacing: 8) {
                    fieldBox(experience.periodStart.formatted(date: .numeric, time: .omitted))
                    Text("—").foregroundStyle(.secondary)
                    fieldBox(experience.periodEnd.formatted(date: .numeric, time: .omitted))
                }
            }
        }
    }
    
    // read only 필드 박스 ----> 스페로가 만들어둔 커스텀텍스트필드는 readonly 없었음.....
    static func fieldBox(_ text: String) -> some View {
        Text(text)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
    
    // 에피소드 상세
    static func episodeBullets(_ episode: Episode) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(episode.title)
                .font(.callout.weight(.bold))
            
            bulletRow(label: "문제 상황", content: episode.problemContext)
            bulletRow(label: "고민 포인트", content: episode.concernPoint)
            bulletRow(label: "나의 액션", content: episode.myAction)
            bulletRow(label: "성과 및 배움", content: episode.outcome)
        }
    }
    
    static func bulletRow(label: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text("•")
            Text("\(label):").fontWeight(.semibold)
            Text(content)
        }
        .font(.caption)
    }
    
}

#Preview {
    let container = try! ModelContainer(
        for: Attachment.self, Character.self, Episode.self, Experience.self, Keyword.self, Office.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    return TrashView(viewModel: TrashViewModel(modelContext: container.mainContext))
        .modelContainer(container)
}
