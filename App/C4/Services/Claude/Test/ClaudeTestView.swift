//
//  ClaudeTestView.swift
//  C4
//
//  Created by 이경민 on 7/13/26.
//

import SwiftUI
import SwiftData
internal import UniformTypeIdentifiers

    // MARK: - 홈 화면 (Experience 목록 + 생성/첨부/에피소드생성 진입점)
struct ClaudeTestView: View {
    
    @Query(sort: \Experience.periodStart, order: .reverse) private var experiences: [Experience]
    private let viewModel: HomeViewModel
    
        // MARK: - 화면 상태
    @State private var isShowingCreateSheet = false
    @State private var isFileImporting = false
    @State private var attachTarget: Experience?
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            ForEach(experiences) { experience in
                Section {
                    ExperienceRow(
                        experience: experience,
                        isGenerating: viewModel.isGenerating,
                        onAttach: {
                            attachTarget = experience
                            isFileImporting = true
                        },
                        onGenerate: {
                            Task { await viewModel.generateEpisodes(for: experience) }
                        }
                    )
                } header: {
                    Text(experience.title)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    viewModel.deleteExperience(experiences[index])
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    isShowingCreateSheet = true
                } label: {
                    Label("경험 추가", systemImage: "plus")
                }
            }
        }
            // MARK: - Experience 생성 시트
        .sheet(isPresented: $isShowingCreateSheet) {
            CreateExperienceSheet(viewModel: viewModel)
        }
            // MARK: - 파일 첨부 (fileImporter)
        .fileImporter(
            isPresented: $isFileImporting,
            allowedContentTypes: [.plainText, .pdf]
        ) { result in
            guard let experience = attachTarget else { return }
            switch result {
                case .success(let url):
                    viewModel.addAttachment(from: url, to: experience)
                case .failure(let error):
                    viewModel.errorMessage = "파일 선택 실패: \(error.localizedDescription)"
            }
            attachTarget = nil
        }
            // MARK: - 에러 알림
        .alert("오류", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

    // MARK: - 경험 한 줄 (첨부파일 + 액션 + 생성된 에피소드)
private struct ExperienceRow: View {
    let experience: Experience
    let isGenerating: Bool
    let onAttach: () -> Void
    let onGenerate: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(experience.experienceStatement)
                .font(.body)
            
                // MARK: 키워드 태그
            if !experience.keywords.isEmpty {
                HStack {
                    ForEach(experience.keywords) { keyword in
                        Text(keyword.name)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.tertiary, in: Capsule())
                    }
                }
            }
            
                // MARK: 첨부파일 목록
            ForEach(experience.attachments) { attachment in
                HStack {
                    Image(systemName: "paperclip")
                    Text(attachment.fileName)
                    Spacer()
                    Text(attachment.formattedFileSize)
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
            
                // MARK: 액션 버튼 (파일 첨부 / 에피소드 생성)
            HStack {
                Button("파일 첨부", action: onAttach)
                
                Button {
                    onGenerate()
                } label: {
                    if isGenerating {
                        ProgressView().controlSize(.small)
                    } else {
                        Text("에피소드 생성")
                    }
                }
                .disabled(isGenerating)
            }
            
                // MARK: 생성된 에피소드 목록
            ForEach(experience.episodes) { episode in
                EpisodeCard(episode: episode)
            }
        }
        .padding(.vertical, 4)
    }
}

    // MARK: - 생성된 에피소드 카드
private struct EpisodeCard: View {
    let episode: Episode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(episode.title)
                .font(.headline)
            Text("상황: \(episode.problemContext)")
            Text("고민: \(episode.concernPoint)")
            Text("행동: \(episode.myAction)")
            Text("결과: \(episode.outcome)")
        }
        .font(.caption)
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

    // MARK: - 경험 생성 시트
private struct CreateExperienceSheet: View {
    let viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
        // MARK: 입력 폼 상태
    @State private var title = ""
    @State private var experienceStatement = ""
    @State private var keywordInput = ""
    @State private var periodStart = Date()
    @State private var periodEnd = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("제목", text: $title)
                DatePicker("시작일", selection: $periodStart, displayedComponents: .date)
                DatePicker("종료일", selection: $periodEnd, displayedComponents: .date)
                TextField("키워드 (쉼표로 구분)", text: $keywordInput)
                TextField("경험 서술", text: $experienceStatement, axis: .vertical)
                    .lineLimit(5...10)
            }
            .navigationTitle("경험 추가")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        let keywordNames = keywordInput
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                            .filter { !$0.isEmpty }
                        
                        viewModel.createExperience(
                            title: title,
                            periodStart: periodStart,
                            periodEnd: periodEnd,
                            experienceStatement: experienceStatement,
                            keywordNames: keywordNames
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || experienceStatement.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 400)
    }
}
