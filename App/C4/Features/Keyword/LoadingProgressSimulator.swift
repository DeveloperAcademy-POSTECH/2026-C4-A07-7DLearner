//
//  LoadingProgressSimulator.swift
//  C4
//

import SwiftUI

// MARK: - 로딩 화면 4단계 정의
enum LoadingStep: Int, CaseIterable, Hashable {
    case extractText
    case analyzeKeyword
    case summarize
    case generate

    var title: String {
        switch self {
        case .extractText: return "텍스트 추출 완료!"
        case .analyzeKeyword: return "키워드 분석 중..."
        case .summarize: return "중심 경험 요약 중..."
        case .generate: return "경험 생성 중..."
        }
    }
}

// MARK: - 단계별 표시 상태 (체크 / 스피너 / 대기)
enum StepState {
    case pending
    case inProgress
    case done
}

// MARK: - 경과 시간 → (현재 단계, 진행률) 순수 계산
enum LoadingProgressSimulator {

    struct Phase {
        let step: LoadingStep
        let startProgress: Double
        let endProgress: Double
        let duration: TimeInterval
    }

    // "텍스트 추출 완료"는 진입 즉시 완료 상태라 시뮬레이션 대상이 아님 — 이 3단계만 시간표를 탐
    static let phases: [Phase] = [
        Phase(step: .analyzeKeyword, startProgress: 0.0, endProgress: 0.40, duration: 2.5),
        Phase(step: .summarize, startProgress: 0.40, endProgress: 0.65, duration: 2.5),
        Phase(step: .generate, startProgress: 0.65, endProgress: 0.92, duration: 3.0)
    ]

    static let cappedProgress: Double = 0.92

    static func state(atElapsed elapsed: TimeInterval) -> (step: LoadingStep, progress: Double) {
        var accumulated: TimeInterval = 0
        for phase in phases {
            let phaseEnd = accumulated + phase.duration
            if elapsed < phaseEnd {
                let phaseElapsed = elapsed - accumulated
                let fraction = phase.duration > 0 ? phaseElapsed / phase.duration : 1
                let progress = phase.startProgress + (phase.endProgress - phase.startProgress) * fraction
                return (phase.step, progress)
            }
            accumulated = phaseEnd
        }
        return (phases.last!.step, cappedProgress)
    }
}

// MARK: - 수동 검증: 경계값(2.5s, 5s, 8s)에서 단계가 올바르게 넘어가는지 눈으로 확인
#Preview("LoadingProgressSimulator 검증") {
    struct Sample {
        let elapsed: TimeInterval
        let expectedStep: LoadingStep
    }
    let samples: [Sample] = [
        Sample(elapsed: 0, expectedStep: .analyzeKeyword),
        Sample(elapsed: 2.4, expectedStep: .analyzeKeyword),
        Sample(elapsed: 2.6, expectedStep: .summarize),
        Sample(elapsed: 4.9, expectedStep: .summarize),
        Sample(elapsed: 5.1, expectedStep: .generate),
        Sample(elapsed: 7.9, expectedStep: .generate),
        Sample(elapsed: 100, expectedStep: .generate)
    ]

    return List(samples, id: \.elapsed) { sample in
        let result = LoadingProgressSimulator.state(atElapsed: sample.elapsed)
        let passed = result.step == sample.expectedStep
        HStack {
            Text(passed ? "✅" : "❌")
            Text("경과 \(sample.elapsed)초 → \(result.step.title) (\(Int(result.progress * 100))%)")
        }
    }
}
