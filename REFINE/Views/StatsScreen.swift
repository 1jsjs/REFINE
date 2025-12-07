import SwiftUI
import Charts
import SwiftData

struct DailyData: Identifiable {
    let id = UUID()
    let day: String
    let dayNumber: Int
    let chars: Int
    let photos: Int
}

struct StatsScreen: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @Query(sort: \DailyEntry.date) var allEntries: [DailyEntry]

    var currentCycleEntries: [DailyEntry] {
        allEntries.filter { $0.cycleNumber == appState.currentCycle }
    }

    var dailyData: [DailyData] {
        return (1...appState.piecesPerCycle).map { pieceNum in
            let entry = currentCycleEntries.first { $0.pieceNumber == pieceNum }
            return DailyData(
                day: "\(pieceNum)",
                dayNumber: pieceNum,
                chars: entry?.text.count ?? 0,
                photos: entry?.imageData?.count ?? 0
            )
        }
    }

    var totalChars: Int {
        currentCycleEntries.reduce(0) { $0 + $1.text.count }
    }

    var totalPhotos: Int {
        currentCycleEntries.reduce(0) { $0 + ($1.imageData?.count ?? 0) }
    }

    var avgChars: Int {
        let count = currentCycleEntries.count
        return count > 0 ? totalChars / count : 0
    }

    var maxDay: DailyData? {
        dailyData.filter { $0.chars > 0 }.max(by: { $0.chars < $1.chars })
    }

    var minDay: DailyData? {
        dailyData.filter { $0.chars > 0 }.min(by: { $0.chars < $1.chars })
    }

    var averageWritingTime: String {
        guard !currentCycleEntries.isEmpty else { return "기록 없음" }
        let calendar = Calendar.current
        let hours = currentCycleEntries.map { calendar.component(.hour, from: $0.date) }
        let avgHour = hours.reduce(0, +) / hours.count
        let period = avgHour < 12 ? "오전" : "오후"
        let displayHour = avgHour <= 12 ? avgHour : avgHour - 12
        return "\(period) \(displayHour)시경"
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

                Text("통계")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                Text("현재 사이클 작성 패턴")
                    .font(.system(size: 17))
                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                // Overview Cards
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("총 글자 수")
                            .font(.system(size: 15))
                            .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)

                        Text("\(totalChars)")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(themeManager.theme == .dark ? .white : .black)

                        Text("평균 \(avgChars)자")
                            .font(.system(size: 13))
                            .foregroundColor(.systemGreen)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                    .cornerRadius(20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("첨부한 사진")
                            .font(.system(size: 15))
                            .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)

                        Text("\(totalPhotos)")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(themeManager.theme == .dark ? .white : .black)

                        Text("총 개수")
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                    .cornerRadius(20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // Daily Chart
                VStack(alignment: .leading, spacing: 24) {
                    Text("조각별 작성량")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeManager.theme == .dark ? .white : .black)

                    Chart(dailyData) { data in
                        BarMark(
                            x: .value("Day", data.day),
                            y: .value("Characters", data.chars)
                        )
                        .foregroundStyle(data.chars == (maxDay?.chars ?? 0) && data.chars > 0 ? Color.systemBlue : Color.systemGray4)
                        .cornerRadius(8)
                    }
                    .frame(height: 200)
                }
                .padding(24)
                .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // Insights
                Text("인사이트")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                VStack(spacing: 12) {
                    // Most Active Day
                    if let maxDay = maxDay {
                        InsightCard(
                            icon: "arrow.up.right",
                            iconColor: .systemGreen,
                            title: "가장 많이 쓴 조각",
                            subtitle: "\(maxDay.day)번 조각에 \(maxDay.chars)자를 작성했어요",
                            theme: themeManager.theme
                        )
                    }

                    // Least Active Day
                    if let minDay = minDay, maxDay != nil {
                        InsightCard(
                            icon: "arrow.down.right",
                            iconColor: .systemOrange,
                            title: "적게 쓴 조각",
                            subtitle: "\(minDay.day)번 조각에 \(minDay.chars)자를 작성했어요",
                            theme: themeManager.theme
                        )
                    }

                    // Average Time
                    if !currentCycleEntries.isEmpty {
                        InsightCard(
                            icon: "clock",
                            iconColor: .systemBlue,
                            title: "평균 작성 시간",
                            subtitle: "\(averageWritingTime)에 주로 기록해요",
                            theme: themeManager.theme
                        )
                    }

                    if currentCycleEntries.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.system(size: 48))
                                .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray3)

                            Text("아직 기록이 없어요")
                                .font(.system(size: 17))
                                .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)

                            Text("일기를 작성하면 통계가 표시됩니다")
                                .font(.system(size: 15))
                                .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, max(40, geometry.safeAreaInsets.bottom + 20))
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(themeManager.theme == .dark ? Color.darkBackground : .white)
    }
}

struct InsightCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let theme: Theme

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme == .dark ? .white : .black)

                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
            }

            Spacer()
        }
        .padding(20)
        .background(theme == .dark ? Color.darkElevated : Color.systemGray6)
        .cornerRadius(16)
    }
}
