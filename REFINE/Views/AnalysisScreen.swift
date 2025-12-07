import SwiftUI
import SwiftData

struct AnalysisScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [DailyEntry]

    private let service = OpenAIService()

    @State private var tint: Color? = nil
    @State private var fill: CGFloat = 0.0
    @State private var shimmering = true
    @State private var polished = false
    @State private var statusText = "당신의 생각을 정제하고 있어요…"

    enum Phase { case start, analyzing, resolve, fill, polish, done, failed }
    @State private var phase: Phase = .start

    private var currentCycleEntries: [DailyEntry] {
        allEntries.filter { $0.cycleNumber == appState.currentCycle }
    }

    var body: some View {
        let palette = themeManager.paletteFor(themeManager.currentTone)

        ZStack {
            // 상단 은은한 그라데이션(톤 반영)
            LinearGradient(
                colors: [palette.softGradientTop, .clear],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                RefineOrb(
                    tint: tint,
                    fillProgress: fill,
                    isShimmering: shimmering,
                    isPolished: polished
                )

                Text(statusText)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
            .padding(.top, 20)
        }
        .background(themeManager.theme == .dark ? Color.darkBackground : .white)
        .onAppear {
            startSequence()
        }
    }

    private func startSequence() {
        // Start: 투명
        phase = .start
        tint = nil
        fill = 0
        shimmering = true
        polished = false
        statusText = "당신의 생각을 정제하고 있어요…"

        // Analyzing: 바로 API 호출
        phase = .analyzing
        Task { await runAnalysis() }
    }

    private func runAnalysis() async {
        do {
            let ai = try await service.analyzeEntries(currentCycleEntries)

            // Resolve: tone 결정
            let tone = RefineTone(looseRaw: ai.tone)
            await MainActor.run {
                phase = .resolve
                applyTone(tone)
                statusText = "형태가 잡히고 있어요…"
            }

            // Fill: 색 차오름
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s
            await MainActor.run {
                phase = .fill
                withAnimation(.easeInOut(duration: 0.8)) {
                    fill = 1.0
                }
            }

            // Polish: 광택/스파클
            try? await Task.sleep(nanoseconds: 850_000_000) // fill 끝쯤
            await MainActor.run {
                phase = .polish
                shimmering = false
                polished = true
                statusText = "정제가 완료됐어요"
            }

            // 결과 저장 + 화면 전환
            try? await Task.sleep(nanoseconds: 320_000_000)
            await MainActor.run {
                persistCycleAnalysis(ai: ai, tone: tone)
                phase = .done

                // AppState에 결과 저장
                appState.analysisKeywords = ai.keywords
                appState.analysisSummary = ai.summary
                appState.analysisOneLiner = ai.oneLiner

                // 사이클 완료 처리 후 이동
                appState.completeCycle()
                appState.navigate(to: .result)
            }

        } catch {
            // 실패 UX: 더미 폴백 + neutral
            await MainActor.run {
                phase = .failed
                shimmering = false
                statusText = "지금은 분석이 어려워요. 대신 임시 결과를 보여드릴게요."
                applyTone(.neutral)
                withAnimation(.easeInOut(duration: 0.6)) { fill = 1.0 }
                polished = true

                // 더미 데이터
                appState.analysisKeywords = ["#기록", "#성찰", "#흐름"]
                appState.analysisSummary = "이번 사이클은 스스로를 돌아보는 시간들이 모였습니다. 작은 조각들이 의미 있는 흐름을 만들었어요."
                appState.analysisOneLiner = "천천히, 하지만 분명히 나를 다듬는 중."

                // 저장 후 이동
                persistCycleAnalysis(
                    ai: RefineAIResponse(
                        tone: "neutral",
                        keywords: appState.analysisKeywords,
                        summary: appState.analysisSummary,
                        oneLiner: appState.analysisOneLiner
                    ),
                    tone: .neutral
                )

                // 사이클 완료 처리 후 이동
                appState.completeCycle()
                appState.navigate(to: .result)
            }
        }
    }

    private func applyTone(_ tone: RefineTone) {
        themeManager.currentTone = tone
        let p = themeManager.paletteFor(tone)
        tint = p.accent
    }

    private func persistCycleAnalysis(ai: RefineAIResponse, tone: RefineTone) {
        let dates = currentCycleEntries.map { $0.date }.sorted()
        let first = dates.first ?? Date()
        let last = dates.last ?? Date()

        let analysis = CycleAnalysis(
            cycleNumber: appState.currentCycle,
            firstPieceDate: first,
            lastPieceDate: last,
            keywords: ai.keywords,
            summary: ai.summary,
            oneLiner: ai.oneLiner,
            toneRaw: tone.rawValue
        )
        modelContext.insert(analysis)
        try? modelContext.save()
    }
}
