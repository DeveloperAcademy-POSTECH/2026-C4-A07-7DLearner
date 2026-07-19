//
//  HomeView.swift
//  C4
//
//  Created by YOOJUN PARK on 7/13/26.
//

import SwiftUI
import SwiftData
internal import UniformTypeIdentifiers

struct HomeView: View {
    
    @Query private var experiences: [Experience]
    private let viewModel: HomeViewModel
    
    @State private var isFileImporting: Bool = false
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        List {
            Button("파일 첨부하기") {
                isFileImporting = true
            }
            
            Button("Claude API 테스트") {
                Task {
                    do {
                        let service = ClaudeService()
                        let response = try await service.testConnection()
                        print("✅ 응답: \(response)")
                    } catch {
                        print("❌ 에러: \(error)")
                    }
                }
            }
            
            ForEach(experiences) { experience in
                Section(experience.title) {
                    ForEach(experience.attachments) { attachment in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(attachment.fileName)
                                .font(.headline)
                            Text("\(attachment.fileType) / \(attachment.formattedFileSize)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(attachment.extractedText ?? "텍스트 추출 실패")
                                .font(.caption2)
                        }
                    }
                }
            }
            
        }
        .fileImporter(isPresented: $isFileImporting, allowedContentTypes: [.plainText, .pdf]) { result in
            switch result {
            case .success(let url):
                viewModel.addAttachment(from: url)
            case .failure(let error):
                print("파일 선택 실패: \(error)")
            }
        }
        
    }
    
}
