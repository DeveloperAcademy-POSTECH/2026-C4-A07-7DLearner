//
//  FoundationTestView.swift
//  C4
//
//  Created by YOOJUN PARK on 7/18/26.
//

import SwiftUI
import FoundationModels

// MARK: - Foundation Model 성능/동작 테스트
struct FoundationTestView: View {
    
    @State private var resultText: String = ""
    
    @State private var isGenerating = false
    @State private var elapsedTime: TimeInterval?
    
    var body: some View {
        Form {
            Section("Foundation Model - 에피소드 생성 테스트") {
                
                Button(isGenerating ? "실행 중..." : "테스트 실행") {
                    Task { await runTest() }
                }
                .disabled(isGenerating)
                
                if let elapsedTime {
                    Text("소요 시간: \(formattedDuration(elapsedTime))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                ScrollView {
                    Text(resultText)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
    }
    
}

// MARK: - 테스트 로직
private extension FoundationTestView {
    
    @MainActor
    func runTest() async {
        isGenerating = true
        resultText = ""
        elapsedTime = nil
        
        let startTime = Date()
        defer {
            elapsedTime = Date().timeIntervalSince(startTime)
            isGenerating = false
        }
        
        let input = EpisodeGenerationInput(
            keywordNames: ["협업", "문제해결력"],
            experienceStatement: "팀 프로젝트에서 디자이너가 갑자기 이탈해서, 개발자들이 역할을 나눠 UI 작업까지 대신 맡았다.",
            attachmentTexts: [
                AttachmentText(
                    attachmentID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    text: """
                    프로젝트 회고 노트 (전체)
                    
                    출시 3주 전, 메인 디자이너가 하드웨어 UI 설계를 전담 중이던 팀 전체가 패닉에 빠졌다. \
                    개발팀과 남은 인원들 사이에서 '누가 이 업무를 맡을 것인가'에 대한 혼선이 생겼고, \
                    누구도 나서서 업무를 조율하고 소통 창구가 되지 않으면 프로젝트가 엎어질 것이라 판단했다. \
                    이에 임시로 PM 역할을 자처해 매일 15분 스탠드업 미팅을 도입했다. 개발 파트의 제약 사항을 \
                    파악한 뒤, 이를 바탕으로 대체 디자인 방안을 조율하고 팀원 간 업무 R&R을 명확히 재분배했다. \
                    갈등 없이 프로젝트 정상 궤도 복귀 및 기한 내 앱 스토어 제출 완료. 직군을 넘어선 소통 능력과 \
                    위기 속 유연한 협업의 중요성을 깨달았다.
                    
                    한편, 기술적으로도 리소스 부족 문제가 있었다. CreateML로 학습한 이미지 분류 모델의 정확도가 \
                    기대치에 크게 못 미쳤는데, 원인을 데이터셋의 클래스 불균형으로 특정했다. 소수 클래스 데이터를 \
                    추가 수집하고 augmentation 기법을 적용해 재학습한 결과, 정확도를 78%에서 91%까지 끌어올렸다. \
                    처음부터 다시 설계해야 하는 상황에서도 포기하지 않고 여러 방법을 시도하며 끝까지 완성도를 \
                    높인 경험이었다.
                    """
                ),
                AttachmentText(
                    attachmentID: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                    text: """
                    기술 회고 (별도 문서)
                    
                    디자이너 부재로 개발 리소스가 절대적으로 부족한 상황에서, 모든 기능을 다 구현하려다간 \
                    일정을 못 맞출 것이 분명했다. 그래서 사용자 조사 결과를 바탕으로 핵심 플로우만 남기고 \
                    부가 애니메이션, 커스텀 트랜지션 요구사항을 과감히 쳐내는 방향으로 스코프를 재조정했다. \
                    우선순위를 다시 정리하는 과정에서 이해관계자들의 반발도 있었지만, 데이터를 근거로 \
                    설득해 합의를 이끌어냈고 결과적으로 일정 내 MVP 출시에 성공했다.
                    """
                ),
                AttachmentText(
                    attachmentID: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                    text: """
                    팀원 피드백 정리 (설문 응답 요약)
                    
                    "초기엔 역할 분담이 불명확해서 답답했는데, 스탠드업 미팅이 생기고 나서는 누가 무슨 일을 \
                    하는지 훨씬 명확해졌다."
                    "임시로 나서서 조율해준 덕분에 붕 뜬 업무 없이 다들 각자 할 일에 집중할 수 있었다."
                    "디자이너 공백을 이렇게 빨리 메꿀 수 있을 거라 생각 못 했는데, 매일 짧게라도 맞춰보는 \
                    자리가 있어서 불안감이 많이 줄었다."
                    """
                )
            ]
        )
        
        do {
            let service = FoundationModelService()
            let episodes = try await service.generateEpisodes(input: input)
            resultText = format(episodes)
        } catch {
            resultText = format(error)
        }
    }
    
}

// MARK: - 출력 포맷
private extension FoundationTestView {
    
    func format(_ episodes: [EpisodeGenerationOutput]) -> String {
        episodes
            .map { episode in
                """
                EpisodeGenerationOutput(
                    keywordName: "\(episode.keywordName)",
                    title: "\(episode.title)",
                    problemContext: "\(episode.problemContext)",
                    concernPoint: "\(episode.concernPoint)",
                    myAction: "\(episode.myAction)",
                    outcome: "\(episode.outcome)",
                    sourceExcerpt: "\(episode.sourceExcerpt)",
                    sourceAttachmentID: \(episode.sourceAttachmentID.map { "\($0)" } ?? "nil")
                )
                """
            }
            .joined(separator: "\n\n---\n\n")
    }
    
    func format(_ error: Error) -> String {
        switch error {
        case FoundationModelError.invalidResponseEncoding:
            return "=== error: invalidResponseEncoding ==="
            
        case FoundationModelError.decodingFailed(let rawResponse, let underlying):
            return """
            === error: decodingFailed ===
            
            === 모델 원본 응답 ===
            \(rawResponse)
            
            === 에러 상세 ===
            \(underlying)
            """
            
        default:
            return "=== error: \(error) ==="
        }
    }
    
    func formattedDuration(_ interval: TimeInterval) -> String {
        if interval < 60 {
            return String(format: "%.1f초", interval)
        } else {
            let minutes = Int(interval) / 60
            let seconds = interval.truncatingRemainder(dividingBy: 60)
            return String(format: "%d분 %.1f초", minutes, seconds)
        }
    }
    
}

#Preview {
    FoundationTestView()
}

