import SwiftUI
import SwiftData

struct WeekData: Identifiable {
    let id = UUID()
    let week: Int
    let startDate: Date
    let endDate: Date
    let completed: Bool
    let keywords: [String]
    let charCount: Int
    let photoCount: Int
}

struct WeeksScreen: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @Query(sort: \DailyEntry.cycleNumber) var allEntries: [DailyEntry]
    @Query(sort: \CycleAnalysis.cycleNumber, order: .reverse) var cycleAnalyses: [CycleAnalysis]

    var weekDataList: [WeekData] {
        let cycleNumbers = Set(allEntries.map { $0.cycleNumber })
        return cycleNumbers.sorted(by: >).compactMap { cycleNum in
            let entries = allEntries.filter { $0.cycleNumber == cycleNum }
            guard !entries.isEmpty else { return nil }

            let analysis = cycleAnalyses.first { $0.cycleNumber == cycleNum }
            let piecesPerCycle = appState.piecesPerCycle
            let completed = entries.count == piecesPerCycle && analysis != nil

            return WeekData(
                week: cycleNum,
                startDate: entries.map { $0.date }.min() ?? Date(),
                endDate: entries.map { $0.date }.max() ?? Date(),
                completed: completed,
                keywords: analysis?.keywords ?? [],
                charCount: entries.reduce(0) { $0 + $1.text.count },
                photoCount: entries.reduce(0) { $0 + ($1.imageData?.count ?? 0) }
            )
        }
    }

    var totalChars: Int {
        allEntries.reduce(0) { $0 + $1.text.count }
    }

    var totalPhotos: Int {
        allEntries.reduce(0) { $0 + ($1.imageData?.count ?? 0) }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            appState.handleBack()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))

                                Text("대시보드")
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(.systemBlue)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, max(60, geometry.safeAreaInsets.top + 20))
                    .padding(.bottom, 24)

                Text("사이클 관리")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                Text("과거 사이클 히스토리")
                    .font(.system(size: 17))
                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                // Summary Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)

                        Text("전체 통계")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("완료 사이클")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))

                            Text("\(weekDataList.filter { $0.completed }.count)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("총 글자")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))

                            Text("\(totalChars)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("총 사진")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))

                            Text("\(totalPhotos)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [.systemBlue, .systemPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // Weeks List
                Text("사이클별 기록")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                if weekDataList.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "square.stack.3d.up")
                            .font(.system(size: 48))
                            .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray3)

                        Text("아직 완료된 사이클이 없어요")
                            .font(.system(size: 17))
                            .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)

                        Text("조각을 모아 사이클을 완료하세요")
                            .font(.system(size: 15))
                            .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                    .padding(.horizontal, 24)
                } else {
                    VStack(spacing: 12) {
                        ForEach(weekDataList) { week in
                            WeekCard(week: week, theme: themeManager.theme) {
                                // Load analysis for this cycle if available
                                if week.completed, let analysis = cycleAnalyses.first(where: { $0.cycleNumber == week.week }) {
                                    appState.analysisKeywords = analysis.keywords
                                    appState.analysisSummary = analysis.summary
                                    appState.analysisOneLiner = analysis.oneLiner
                                    appState.navigate(to: .result)
                                }
                            }
                            .environmentObject(appState)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

                // New Cycle Button - Only show if current cycle is complete
                if !weekDataList.isEmpty && weekDataList.first?.week == appState.currentCycle && weekDataList.first?.completed == true {
                    Button(action: {
                        appState.currentCycle += 1
                        appState.currentPiece = 0
                        appState.navigate(to: .dashboard)
                    }) {
                    Text("새로운 사이클 시작하기")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.systemBlue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

                Spacer().frame(height: max(40, geometry.safeAreaInsets.bottom + 20))
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(themeManager.theme == .dark ? Color.darkBackground : .white)
    }
}

struct WeekCard: View {
    @EnvironmentObject var appState: AppState
    let week: WeekData
    let theme: Theme
    let action: () -> Void

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.systemBlue)
                                .frame(width: 48, height: 48)

                            Text("\(week.week)주")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text("\(week.week)번째 사이클")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(theme == .dark ? .white : .black)

                                if week.completed {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.systemGreen)
                                }
                            }

                            Text("\(dateFormatter.string(from: week.startDate)) - \(dateFormatter.string(from: week.endDate))")
                                .font(.system(size: 13))
                                .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(theme == .dark ? .darkSeparator : Color.systemGray3)
                }

                if !week.keywords.isEmpty {
                    Text(week.keywords.joined(separator: " "))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(theme == .dark ? .white : .black)
                } else {
                    Text("분석 대기 중")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
                }

                HStack(spacing: 8) {
                    Text("\(week.charCount)자")
                        .font(.system(size: 13))
                        .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)

                    Text("•")
                        .foregroundColor(theme == .dark ? .darkSeparator : .systemGray)

                    Text("사진 \(week.photoCount)장")
                        .font(.system(size: 13))
                        .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
                }
            }
            .padding(20)
            .background(theme == .dark ? Color.darkElevated : Color.systemGray6)
            .cornerRadius(16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
