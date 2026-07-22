//
//  KeywordCreateView.swift
//  C4
//
//  Created by 박시은 on 7/20/26.
//

import SwiftUI
import SwiftData
internal import UniformTypeIdentifiers

struct KeywordCreateView: View {

    // MARK: ViewModel
    @Bindable var viewModel: KeywordViewModel

    @State private var newKeyword: String = ""
    @State private var isPresentingFileImporter = false

    var body: some View {
        // MARK: - 입력 폼
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 경험 명, 기간
                HStack(alignment: .top, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "경험 명", descriptions: "무엇을 했던 경험인가요?")
                        CustomTextField(placeholder: "ex.애플 디벨로퍼 아카데미 C4", text: $viewModel.draftExperienceTitle)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "기간", descriptions: "해당 경험을 얼마나 진행했나요?")
                        HStack(spacing: 8) {
                            DatePicker(
                                "",
                                selection: $viewModel.draftStartDate,
                                in: ...viewModel.draftEndDate,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.field)

                            Text("—")
                                .foregroundColor(.gray)

                            DatePicker(
                                "",
                                selection: $viewModel.draftEndDate,
                                in: viewModel.draftStartDate...,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.field)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 17)

                Divider()
                    .padding(.bottom, 63)

                // MARK: - 키워드 작성
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "키워드 작성", descriptions: "이 경험을 가장 잘 나타내는 핵심 키워드를 1개 이상 작성해주세요. 선택한 키워드에 맞게 에피소드를 구성합니다.")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // 작성된 키워드 태그들
                            ForEach(viewModel.draftKeywords, id: \.self) { keyword in
                                KeywordTag(text: keyword, onRemove: {
                                    viewModel.draftKeywords.removeAll { $0 == keyword }
                                }, style: .selected)
                            }

                            // 새 키워드 입력 필드
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)

                                TextField("키워드 입력", text: $newKeyword)
                                    .textFieldStyle(.plain)
                                    .font(Font.custom("SF Pro", size: 13))
                                    .frame(minWidth: 60)
                                    .onSubmit {
                                        let trimmed = newKeyword.trimmingCharacters(in: .whitespaces)
                                        if !trimmed.isEmpty && !viewModel.draftKeywords.contains(trimmed) {
                                            viewModel.draftKeywords.append(trimmed)
                                        }
                                        newKeyword = ""
                                    }
                            }
                            .padding(.horizontal, 10)
                            .frame(height: 28)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                            
                            // 작성된 키워드 태그들
                            ForEach(viewModel.draftKeywords, id: \.self) { keyword in
                                KeywordTag(text: keyword, onRemove: {
                                    viewModel.draftKeywords.removeAll { $0 == keyword }
                                }, style: .selected)
                            }
                            
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.bottom, 17)

                Divider()
                    .padding(.bottom, 63)

                // MARK: - 자료 첨부
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "자료 첨부 (선택)", descriptions: "해당 경험과 관련된 자료를 첨부해주세요.")

                    if viewModel.draftAttachedFiles.isEmpty {
                        // 첨부파일 없을 때 (점선 박스 UI)
                        VStack(spacing: 8) {
                            Image(systemName: "icloud.and.arrow.up")
                                .font(.system(size: 24))
                                .foregroundColor(Color.gray.opacity(0.6))
                            Text("txt, md, csv, pdf • Up to 50MB")
                                .font(Font.custom("SF Pro", size: 11))
                                .foregroundColor(.gray)

                            Button(action: {
                                isPresentingFileImporter = true
                            }) {
                                Text("자료 첨부")
                                    .font(Font.custom("SF Pro", size: 11))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                                    )
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background(Color.gray.opacity(0.02))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
                        )
                    } else {
                        // 첨부파일 있을 때 (파일 리스트 뷰)
                        VStack(spacing: 12) {
                            ForEach(viewModel.draftAttachedFiles) { file in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(file.fileName)
                                            .font(Font.custom("SF Pro", size: 14).weight(.medium))
                                            .foregroundColor(.black)
                                        Text("\(file.fileType.uppercased()) 문서 • \(file.formattedFileSize)")
                                            .font(Font.custom("SF Pro", size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()

                                    // 파일 삭제 버튼
                                    Button(action: {
                                        viewModel.draftAttachedFiles.removeAll { $0.id == file.id }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray.opacity(0.5))
                                            .font(.system(size: 20))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(16)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                )
                            }

                            // 파일 추가 버튼 (파일이 이미 있을 때)
                            Button(action: {
                                isPresentingFileImporter = true
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("파일 추가하기")
                                }
                                .font(Font.custom("SF Pro", size: 13).weight(.medium))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.bottom, 17)
                .fileImporter(
                    isPresented: $isPresentingFileImporter,
                    allowedContentTypes: [.plainText, .pdf, .commaSeparatedText, .data], // 허용할 확장자
                    allowsMultipleSelection: false
                ) { result in
                    handleFileImport(result)
                }

                Divider()
                    .padding(.bottom, 63)

                // MARK: - 경험 진술
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "경험진술", descriptions: "아래 질문에 답하듯 편하게 썰을 풀어주세요. 완벽한 문장이 아니어도 괜찮아요! 자세한 내용이 담길수록 명확한 에피소드가 생성됩니다.")

                    CustomTextEditor(
                        placeholder: "막막하다면 아래 질문에 대답하듯 의식의 흐름대로 적어보세요!\n\nQ. 이 프로젝트에서 나의 메인 역할은 무엇이었나요?\nQ. 진행 중 겪었던 가장 빡쳤던(?) 위기나 한계는 무엇이었나요?\nQ. 그 위기를 넘기기 위해 '나'는 구체적으로 어떤 고민과 행동을 했나요?\nQ. 결과적으로 무엇을 이뤄냈고, 무엇을 배웠나요?",
                        text: $viewModel.draftStatement
                    )
                }
            }
            .padding(24)
        }
    }

    // MARK: - 파일 선택 처리
    // 실제 파일 복사/텍스트 추출은 분석 시점에 수행하고, 여기서는 URL과 표시 정보만 보관한다.
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            // 파일 정보 추출 (보안 스코프 접근)
            let gotAccess = url.startAccessingSecurityScopedResource()
            defer {
                if gotAccess { url.stopAccessingSecurityScopedResource() }
            }

            let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int).flatMap { $0 } ?? 0

            let draft = DraftAttachment(
                url: url,
                fileName: url.lastPathComponent,
                fileType: url.pathExtension,
                fileSize: fileSize
            )

            // 같은 파일 중복 방지
            if !viewModel.draftAttachedFiles.contains(where: { $0.url == url }) {
                viewModel.draftAttachedFiles.append(draft)
            }
        case .failure(let error):
            print("파일 선택 실패: \(error.localizedDescription)")
        }
    }
}
