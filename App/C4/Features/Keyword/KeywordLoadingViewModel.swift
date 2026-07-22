//
//  KeywordLoadingViewModel.swift
//  C4
//
//  Created by 이경민 on 7/22/26.
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

    // 뷰가 사라질 때 호출 — 진행 중인 백그라운드 Task를 정리한다.
    // (화면이 없어진 뒤 onComplete가 뒤늦게 호출되거나 Task가 겹쳐 도는 것을 방지)
    func cancel() {
        tickTask?.cancel()
        generationTask?.cancel()
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

