//
//  KeywordLoadingViewModel.swift
//  C4
//

import Foundation
import Observation

// MARK: - 로딩 화면 상태 관리
// 타이머 기반 연출 진행률과, 실제 EpisodeGenerationManager 호출을 동시에 진행시킨다.
// 실제 호출이 끝나는 시점이 항상 최종 트리거 — 연출이 먼저 끝나든 늦게 끝나든 100%는 실제 완료 때만 찍힌다.
@MainActor
@Observable
final class KeywordLoadingViewModel {

    private(set) var progress: Double = 0
    private(set) var currentStep: LoadingStep = .analyzeKeyword
    private(set) var isFailed: Bool = false
    private(set) var isComplete: Bool = false
    private(set) var errorMessage: String?

    private let experience: Experience
    private let manager: EpisodeGenerationManager
    private let onComplete: () -> Void

    // 참고: tickTask와 generationTask는 SwiftUI 뷰의 생명주기에 묶여있지 않은 별도 백그라운드 Task라서,
    // `.task { }`가 취소돼도 (자기 자신의 클로저만 끝날 뿐) 이 두 Task는 계속 살아있다.
    // 지금은 onComplete가 빈 클로저고 실제 네비게이션도 없어서 문제가 안 되지만,
    // 나중에 실제 네비게이션을 연결할 땐 뷰가 사라질 때 이 두 Task를 꼭 취소해야 한다.
    // 안 그러면 화면이 이미 없어진 뒤에 onComplete()가 뒤늦게 호출되거나,
    // 화면에 다시 들어왔을 때 이전 Task와 겹쳐 돌 수 있다.
    private var tickTask: Task<Void, Never>?
    private var generationTask: Task<Void, Never>?
    private var startTime: Date = .now

    init(experience: Experience, manager: EpisodeGenerationManager, onComplete: @escaping () -> Void) {
        self.experience = experience
        self.manager = manager
        self.onComplete = onComplete
    }

    func start() {
        isFailed = false
        isComplete = false
        errorMessage = nil
        progress = 0
        currentStep = .analyzeKeyword
        startTime = .now
        manager.errorMessage = nil

        tickTask = Task { await self.runTicker() }
        generationTask = Task { await self.runGeneration() }
    }

    func retry() {
        tickTask?.cancel()
        generationTask?.cancel()
        start()
    }

    func stepState(for step: LoadingStep) -> StepState {
        if step == .extractText { return .done }
        if isComplete { return .done }
        if step.rawValue < currentStep.rawValue { return .done }
        if step == currentStep { return .inProgress }
        return .pending
    }

    private func runTicker() async {
        while !Task.isCancelled {
            let elapsed = Date.now.timeIntervalSince(startTime)
            let result = LoadingProgressSimulator.state(atElapsed: elapsed)
            currentStep = result.step
            progress = result.progress
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    private func runGeneration() async {
        await manager.generateEpisodes(for: experience)
        if Task.isCancelled { return }
        tickTask?.cancel()

        if let message = manager.errorMessage {
            isFailed = true
            errorMessage = message
            return
        }

        progress = 1.0
        isComplete = true
        try? await Task.sleep(nanoseconds: 400_000_000)
        onComplete()
    }
}
