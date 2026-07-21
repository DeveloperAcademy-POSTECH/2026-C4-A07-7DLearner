//
//  KeywordLoadingView.swift
//  C4
//
//  Created by 이경민 on 7/21/26.
//

import SwiftUI
import SwiftData

struct KeywordLoadingView: View {

    @State private var viewModel: KeywordLoadingViewModel

    init(experience: Experience, manager: EpisodeGenerationManager, onComplete: @escaping () -> Void) {
        _viewModel = State(initialValue: KeywordLoadingViewModel(experience: experience, manager: manager, onComplete: onComplete))
    }

    var body: some View {
        Group {
            if viewModel.isFailed {
                errorContent
            } else {
                loadingContent
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .task {
            viewModel.start()
        }
    }
}

// MARK: - 로딩 중 화면
private extension KeywordLoadingView {

    var loadingContent: some View {
        VStack(alignment: .center, spacing: 26) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 138, height: 138)
                .background(
                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(24)
                        .frame(width: 138, height: 138)
                )
                .cornerRadius(7)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .inset(by: 0.5)
                        .stroke(.black, lineWidth: 1)
                )

            Text("자료를 읽고 있어요")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)

            Text("자료를 취합하는 중입니다.\n잠시만 기다려 주세요.")
                .font(.system(size: 17))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(Int(viewModel.progress * 100))%")
                .font(.system(size: 17))
                .foregroundColor(.black)

            progressBar

            VStack(alignment: .leading, spacing: 12) {
                ForEach(LoadingStep.allCases, id: \.self) { step in
                    StepRow(step: step, state: viewModel.stepState(for: step))
                }
            }
        }
    }

    var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(red: 0.79, green: 0.79, blue: 0.79))
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.accentColor)
                    .frame(width: geometry.size.width * viewModel.progress)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.progress)
            }
        }
        .frame(height: 10)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 에러 화면
private extension KeywordLoadingView {

    var errorContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)

            Text("생성에 실패했어요")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)

            Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
                .font(.system(size: 15))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)

            Button("다시 시도") {
                viewModel.retry()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - 단계 한 줄 (체크 / 스피너 / 대기 dot)
private struct StepRow: View {
    let step: LoadingStep
    let state: StepState

    var body: some View {
        HStack(spacing: 8) {
            icon
            Text(step.title)
                .font(.system(size: 13))
                .foregroundColor(.black)
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch state {
        case .done:
            Image(systemName: "checkmark")
                .foregroundColor(.green)
        case .inProgress:
            ProgressView()
                .scaleEffect(0.6)
        case .pending:
            Circle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 6, height: 6)
        }
    }
}

// MARK: - Preview 공용: 인메모리 컨테이너 + 키워드 1개가 붙은 샘플 Experience
// (키워드가 없으면 EpisodeGenerationManager가 API를 부르지도 않고 즉시 에러 처리하므로 반드시 필요)
private func makePreviewFixture() -> (context: ModelContext, experience: Experience) {
    let container = try! ModelContainer(
        for: Experience.self, Keyword.self, Attachment.self, Episode.self, Character.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext

    let keyword = Keyword(name: "미리보기키워드")
    context.insert(keyword)

    let experience = Experience(
        title: "미리보기 경험",
        periodStart: .now,
        periodEnd: .now,
        experienceStatement: "미리보기용 진술"
    )
    context.insert(experience)
    experience.keywords = [keyword]

    return (context, experience)
}

#Preview("진행 중 (5초 후 성공)") {
    let fixture = makePreviewFixture()
    return KeywordLoadingView(
        experience: fixture.experience,
        manager: EpisodeGenerationManager(
            modelContext: fixture.context,
            episodeGenerating: FakeEpisodeGenerating(outcome: .success(after: 5))
        ),
        onComplete: { print("완료 콜백 호출됨") }
    )
}

#Preview("실패 (1초 후 에러)") {
    let fixture = makePreviewFixture()
    return KeywordLoadingView(
        experience: fixture.experience,
        manager: EpisodeGenerationManager(
            modelContext: fixture.context,
            episodeGenerating: FakeEpisodeGenerating(outcome: .failure(after: 1, message: "미리보기 테스트 에러"))
        ),
        onComplete: { print("완료 콜백 호출됨") }
    )
}
