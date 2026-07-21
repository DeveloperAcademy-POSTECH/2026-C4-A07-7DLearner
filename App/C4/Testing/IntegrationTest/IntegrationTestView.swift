//
//  IntegrationTestView.swift
//  C4
//
//  Created by YOOJUN PARK on 7/19/26.
//

// 목록은 @Query(실시간 업데이트), 동작은 ViewModel, 필드 입력 상태는 View의 @State

import SwiftUI
import SwiftData
internal import UniformTypeIdentifiers

struct IntegrationTestView: View {
    
    // 데이터 조회
    @Query private var experiences: [Experience]
    @Query private var keywords: [Keyword]
    @Query private var characters: [Character]
    
    @State private var viewModel: IntegrationTestViewModel
    
    // 경험 생성 필드
    @State private var experienceTitle = ""
    @State private var experienceStatement = ""
    @State private var keywordInput = ""
    
    // 캐릭터 생성 필드
    @State private var characterTitle = ""
    @State private var characterStatement = ""
    @State private var selectedKeywordIDs: Set<UUID> = []
    
    // 파일 첨부
    @State private var attachingExperience: Experience?
    @State private var isFileImporting = false
    
    // 편집 대상
    @State private var editingExperience: Experience?
    
    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: IntegrationTestViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        Form {
            statusSection
            experienceCreateSection
            experienceListSection
            keywordSection
            characterCreateSection
            characterListSection
        }
        .formStyle(.grouped)
        .fileImporter(isPresented: $isFileImporting, allowedContentTypes: [.plainText, .pdf]) { result in
            switch result {
            case .success(let url):
                if let experience = attachingExperience {
                    viewModel.addAttachment(from: url, to: experience)
                }
            case .failure(let error):
                print("파일 첨부 실패: \(error)")
            }
            attachingExperience = nil
        }
        .sheet(item: $editingExperience) { experience in
            ExperienceEditSheet(experience: experience) { title, statement in
                viewModel.updateExperience(experience, title: title, statement: statement)
            }
        }
    }
    
}

// MARK: - 상태
private extension IntegrationTestView {
    
    var statusSection: some View {
        Section("상태") {
            Text(viewModel.statusMessage.isEmpty ? "대기 중" : viewModel.statusMessage)
        }
    }
    
}

// MARK: - 경험 생성
private extension IntegrationTestView {
    
    var experienceCreateSection: some View {
        Section("경험 생성") {
            TextField("제목", text: $experienceTitle)
            TextField("경험 진술", text: $experienceStatement, axis: .vertical)
            TextField("키워드 (쉼표로 구분)", text: $keywordInput)
            
            Button("경험 생성") {
                viewModel.createExperience(
                    title: experienceTitle,
                    statement: experienceStatement,
                    keywordInput: keywordInput
                )
                
                experienceTitle = ""
                experienceStatement = ""
                keywordInput = ""
            }
        }
    }
    
}

// MARK: - 경험 목록
private extension IntegrationTestView {
    
    var experienceListSection: some View {
        Section("경험 목록") {
            ForEach(experiences) { experience in
                experienceDetail(experience)
            }
        }
    }
    
    func experienceDetail(_ experience: Experience) -> some View {
        VStack(alignment: .leading) {
            Text(experience.title)
            Text("키워드: \(experience.keywords.map(\.name).joined(separator: ", "))")
            Text("에피소드: \(experience.episodes.count)개")
            
            Text("\n첨부파일: \(experience.attachments.count)개")
            ForEach(experience.attachments) { attachment in
                Text("\(attachment.fileName) (\(attachment.formattedFileSize))")
            }
            
            Text("\n에피소드 목록")
            ForEach(experience.episodes) { episode in
                episodeDetail(episode)
            }
            
            HStack {
                Button("파일 첨부") {
                    attachingExperience = experience
                    isFileImporting = true
                }
                
                Button(viewModel.isGenerating ? "생성 중..." : "에피소드 생성") {
                    Task { await viewModel.generateEpisodes(for: experience) }
                }
                .disabled(viewModel.isGenerating)
                
                Button("편집") { editingExperience = experience }
                
                Button("삭제", role: .destructive) { viewModel.delete(experience) }
            }
        }
    }
    
}

// MARK: - 에피소드 목록
private extension IntegrationTestView {
    
    var keywordSection: some View {
        Section("키워드별 에피소드") {
            ForEach(keywords) { keyword in
                VStack(alignment: .leading) {
                    Text("\(keyword.name) (\(keyword.episodes.count)개)")
                    ForEach(keyword.episodes) { episode in
                        episodeDetail(episode)
                    }
                }
            }
        }
    }
    
}

// MARK: - 캐릭터 생성
private extension IntegrationTestView {
    
    var characterCreateSection: some View {
        Section("캐릭터 생성") {
            TextField("캐릭터 이름", text: $characterTitle)
            TextField("캐릭터 설명", text: $characterStatement, axis: .vertical)
            Text("")
            
            // 저장된 키워드에서 다중 선택
            ForEach(keywords) { keyword in
                Toggle(keyword.name, isOn: Binding(
                    get: { selectedKeywordIDs.contains(keyword.id) },
                    set: { isOn in
                        if isOn { selectedKeywordIDs.insert(keyword.id) }
                        else { selectedKeywordIDs.remove(keyword.id) }
                    }
                ))
            }
            
            Button("캐릭터 생성") {
                let selected = keywords.filter { selectedKeywordIDs.contains($0.id) }
                viewModel.createCharacter(
                    title: characterTitle,
                    statement: characterStatement,
                    keywords: selected
                )
                
                characterTitle = ""
                characterStatement = ""
                selectedKeywordIDs = []
            }
        }
    }
    
}

// MARK: - 캐릭터 목록
private extension IntegrationTestView {
    
    var characterListSection: some View {
        Section("캐릭터 목록") {
            ForEach(characters) { character in
                characterRow(character)
            }
        }
    }
    
    func characterRow(_ character: Character) -> some View {
        VStack(alignment: .leading) {
            Text("제목:\(character.title)")
            Text("캐릭터 설명: \(character.characterStatement)")
            Text("키워드: \(character.keywords.map(\.name).joined(separator: ", "))")
            Text("")
            
            Text("연관된 에피소드")
            ForEach(character.episodes) { episode in
                episodeDetail(episode)
            }
            
            Button("삭제", role: .destructive) { viewModel.delete(character) }
        }
    }
    
}

// MARK: - 에피소드 상세 내용
private extension IntegrationTestView {
    
    func episodeDetail(_ episode: Episode) -> some View {
        VStack(alignment: .leading) {
            Text("[\(episode.keyword.name)] \(episode.title)")
            Text("문제상황: \(episode.problemContext)")
            Text("고민포인트: \(episode.concernPoint)")
            Text("나의 액션: \(episode.myAction)")
            Text("성과: \(episode.outcome)")
            Text("발췌: \(episode.sourceExcerpt)")
            Text("근거 파일: \(episode.attachment?.fileName ?? "없음: 경험 진술 기반 내용")")
            Text("")
        }
    }
    
}

// MARK: - 경험 편집 sheet
private struct ExperienceEditSheet: View {
    
    let experience: Experience
    let onSave: (String, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var statement: String
    
    init(experience: Experience, onSave: @escaping (String, String) -> Void) {
        self.experience = experience
        self.onSave = onSave
        _title = State(initialValue: experience.title)
        _statement = State(initialValue: experience.experienceStatement)
    }
    
    var body: some View {
        Form {
            TextField("제목", text: $title)
            TextField("경험 진술", text: $statement, axis: .vertical)
            
            Button("저장") {
                onSave(title, statement)
                dismiss()
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 250)
    }
    
}

