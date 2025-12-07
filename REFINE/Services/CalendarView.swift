import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let entries: [DailyEntry]
    let currentCycle: Int
    
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
    
    private var firstEntryDate: Date? {
        entries.map { $0.date }.min()
    }
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: currentMonth)
    }
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "오늘은 M월 d일입니다"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        while days.count < 42 { // 6 weeks max
            if calendar.isDate(currentDate, equalTo: monthInterval.start, toGranularity: .month) {
                days.append(currentDate)
            } else {
                days.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            
            if currentDate >= monthInterval.end && days.count >= 28 {
                break
            }
        }
        
        return days
    }
    
    private func entriesCount(for date: Date) -> Int {
        entries.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
    }
    
    private var currentStreak: Int {
        var streak = 0
        var checkDate = Date()
        
        while true {
            let hasEntry = entries.contains { calendar.isDate($0.date, inSameDayAs: checkDate) }
            if hasEntry {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    private var daysInCurrentCycle: Int {
        entries.filter { $0.cycleNumber == currentCycle }.count
    }
    
    private var totalDaysInMonth: Int {
        calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 30
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Month Header with navigation
            HStack(alignment: .firstTextBaseline) {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(canGoPrevious ? (themeManager.theme == .dark ? .white : .black) : (themeManager.theme == .dark ? .darkSeparator : .systemGray4))
                }
                .disabled(!canGoPrevious)
                
                Text(monthTitle)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(canGoNext ? (themeManager.theme == .dark ? .white : .black) : (themeManager.theme == .dark ? .darkSeparator : .systemGray4))
                }
                .disabled(!canGoNext)
                
                Spacer()
                
                Text("사이클 \(currentCycle)/5")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.systemBlue)
            }
            .padding(.horizontal, 24)
            
            Text(todayDateString)
                .font(.system(size: 15))
                .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                .padding(.horizontal, 24)
            
            // Calendar Grid
            VStack(spacing: 8) {
                // Days of week
                HStack(spacing: 0) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(day == "일" ? .systemRed : (day == "토" ? .systemBlue : (themeManager.theme == .dark ? .darkSecondary : .systemGray)))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 4)
                
                // Calendar days
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                    ForEach(daysInMonth.indices, id: \.self) { index in
                        if let date = daysInMonth[index] {
                            CalendarDayCell(
                                date: date,
                                entriesCount: entriesCount(for: date),
                                isToday: calendar.isDateInToday(date),
                                theme: themeManager.theme
                            )
                        } else {
                            Color.clear
                                .frame(height: 44)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 16)
            .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
            .cornerRadius(20)
            .padding(.horizontal, 24)
            
            // Stats Cards
            HStack(spacing: 12) {
                CalendarStatCard(
                    icon: "🔥",
                    title: "연속 기록",
                    value: "\(currentStreak)일",
                    subtitle: "연속 중",
                    theme: themeManager.theme
                )
                
                CalendarStatCard(
                    icon: "📝",
                    title: "이번 달",
                    value: "\(daysInCurrentCycle)/\(totalDaysInMonth)일",
                    subtitle: "기록됨",
                    theme: themeManager.theme
                )
                
                CalendarStatCard(
                    icon: "⏱",
                    title: "평균 시간",
                    value: "2분",
                    subtitle: "하루 평균",
                    theme: themeManager.theme
                )
            }
            .padding(.horizontal, 24)
            
            // Legend
            VStack(alignment: .leading, spacing: 12) {
                Text("범례")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                
                HStack(spacing: 4) {
                    LegendItem(color: .systemBlue.opacity(0.3), text: "기록 1회", theme: themeManager.theme)
                    LegendItem(color: .systemBlue.opacity(0.6), text: "기록 2회 이상", theme: themeManager.theme)
                    LegendItem(color: .systemPurple.opacity(0.5), text: "감정 강한 날", theme: themeManager.theme)
                }
            }
            .padding(20)
            .background(themeManager.theme == .dark ? Color.darkElevated : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(themeManager.theme == .dark ? Color.darkSeparator : Color.systemGray5, lineWidth: 1)
            )
            .padding(.horizontal, 24)
        }
        .onAppear {
            // Set initial month to first entry date if available
            if let firstDate = firstEntryDate {
                currentMonth = firstDate
            }
        }
    }
    
    private var canGoPrevious: Bool {
        guard let firstDate = firstEntryDate else { return false }
        let firstMonth = calendar.startOfMonth(for: firstDate)
        let displayingMonth = calendar.startOfMonth(for: currentMonth)
        return displayingMonth > firstMonth
    }
    
    private var canGoNext: Bool {
        let today = Date()
        let currentMonthStart = calendar.startOfMonth(for: currentMonth)
        let todayMonthStart = calendar.startOfMonth(for: today)
        return currentMonthStart < todayMonthStart
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentMonth = newMonth
            }
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentMonth = newMonth
            }
        }
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

struct CalendarDayCell: View {
    let date: Date
    let entriesCount: Int
    let isToday: Bool
    let theme: Theme
    
    private let calendar = Calendar.current
    
    private var dayNumber: String {
        "\(calendar.component(.day, from: date))"
    }
    
    private var backgroundColor: Color {
        if entriesCount == 0 {
            return theme == .dark ? Color.darkElevated2 : .white
        } else if entriesCount == 1 {
            return .systemBlue.opacity(0.3)
        } else {
            return .systemBlue.opacity(0.6)
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
            
            if isToday {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.systemBlue, lineWidth: 2)
            }
            
            Text(dayNumber)
                .font(.system(size: 15, weight: isToday ? .bold : .regular))
                .foregroundColor(isToday ? .systemBlue : (theme == .dark ? .white : .black))
        }
        .frame(height: 44)
    }
}

struct CalendarStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let theme: Theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(icon)
                .font(.system(size: 28))
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(theme == .dark ? .white : .black)
            
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(theme == .dark ? Color.darkElevated : Color.systemGray6)
        .cornerRadius(16)
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
        }
    }
}

#Preview {
    CalendarView(entries: [], currentCycle: 1)
        .environmentObject(ThemeManager())
}
