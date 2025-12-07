import SwiftUI
import SwiftData

enum DashboardViewMode: String {
    case pieces = "조각"
    case calendar = "달력"
}

struct DashboardScreen: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @Query private var allEntries: [DailyEntry]
    @Query private var allAnalyses: [CycleAnalysis]
    
    @State private var viewMode: DashboardViewMode = .pieces

    private var currentCycleEntries: [DailyEntry] {
        allEntries.filter { $0.cycleNumber == appState.currentCycle }
    }

    var menuItems: [(icon: String, label: String, subtitle: String, screen: Screen, color: Color)] {
        [
            ("pencil.line", "생각 기록하기", "조각을 하나씩 모아보세요", .write, .systemBlue),
            ("list.bullet", "기록 목록", "모은 조각 모아보기", .list, .systemGreen),
            ("chart.bar.fill", "통계", "작성 패턴과 인사이트", .stats, .systemOrange),
            ("square.stack.3d.up", "사이클 관리", "과거 사이클 히스토리", .weeks, .systemRed),
            ("square.and.arrow.up", "공유하기", "결과를 카드로 만들어 공유", .share, .systemPurple),
            ("gearshape.fill", "설정", "조각 수 변경 및 백업", .settings, .systemGray)
        ]
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack(alignment: .center) {
                        Text("REFINE")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundColor(themeManager.theme == .dark ? .white : .black)

                        Spacer()

                        // Dark Mode Toggle
                        Button(action: {
                            themeManager.toggleTheme()
                        }) {
                            Image(systemName: themeManager.theme == .light ? "moon" : "sun.max.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(themeManager.theme == .light ? .systemBlue : .systemYellow)
                                .frame(width: 44, height: 44)
                                .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, max(60, geometry.safeAreaInsets.top + 20))
                    .padding(.bottom, 8)

                Text("가장 개인적인 것이 가장 창의적인 것이다.")
                    .font(.system(size: 17))
                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                
                // View Mode Picker
                Picker("뷰 모드", selection: $viewMode) {
                    Text(DashboardViewMode.pieces.rawValue).tag(DashboardViewMode.pieces)
                    Text(DashboardViewMode.calendar.rawValue).tag(DashboardViewMode.calendar)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // Content based on view mode
                if viewMode == .pieces {
                    PiecesView(
                        currentPiece: appState.currentPiece,
                        piecesPerCycle: appState.piecesPerCycle,
                        totalCharacters: appState.totalCharacters,
                        totalPhotos: appState.totalPhotos,
                        totalCycles: appState.totalCycles,
                        menuItems: menuItems,
                        theme: themeManager.theme
                    ) { screen in
                        appState.navigate(to: screen)
                    }
                } else {
                    CalendarView(
                        entries: currentCycleEntries,
                        currentCycle: appState.currentCycle
                    )
                    .environmentObject(themeManager)
                }
                
                Spacer().frame(height: max(40, geometry.safeAreaInsets.bottom + 20))
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(themeManager.theme == .dark ? Color.darkBackground : .white)
        .onAppear {
            appState.loadCurrentProgress(from: currentCycleEntries)
            appState.loadStatistics(from: allEntries)
            appState.totalCycles = Set(allEntries.map { $0.cycleNumber }).count
        }
    }
}

// Extract pieces view to separate component for cleaner code
struct PiecesView: View {
    let currentPiece: Int
    let piecesPerCycle: Int
    let totalCharacters: Int
    let totalPhotos: Int
    let totalCycles: Int
    let menuItems: [(icon: String, label: String, subtitle: String, screen: Screen, color: Color)]
    let theme: Theme
    let onNavigate: (Screen) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Card - 조각 개념
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("모은 조각")
                            .font(.system(size: 15))
                            .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(currentPiece)")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(theme == .dark ? .white : .black)

                            Text("/ \(piecesPerCycle)")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
                        }
                    }

                    Spacer()

                    // Piece visualization
                    HStack(spacing: 8) {
                        ForEach(0..<piecesPerCycle, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(index < currentPiece ?
                                      LinearGradient(colors: [.systemBlue, .systemPurple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                      LinearGradient(colors: [theme == .dark ? Color.darkElevated2 : Color.white], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 20, height: 20)
                        }
                    }
                }

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme == .dark ? Color.darkElevated2 : .white)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(
                                colors: [.systemBlue, .systemPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * CGFloat(currentPiece) / CGFloat(piecesPerCycle), height: 8)
                    }
                }
                .frame(height: 8)

                Text(currentPiece < piecesPerCycle
                     ? "\(piecesPerCycle - currentPiece)개 더 모으면 나의 형태가 보여요"
                     : "정제하기 준비가 완료되었습니다!")
                    .font(.system(size: 13))
                    .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
            }
            .padding(24)
            .background(theme == .dark ? Color.darkElevated : Color.systemGray6)
            .cornerRadius(20)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)

            // Quick Stats
            HStack(spacing: 12) {
                StatCard(title: "총 글자", value: "\(totalCharacters)", theme: theme)
                StatCard(title: "사진", value: "\(totalPhotos)", theme: theme)
                StatCard(title: "사이클", value: "\(totalCycles)", theme: theme)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)

            // Menu Items
            VStack(spacing: 8) {
                ForEach(0..<menuItems.count, id: \.self) { index in
                    let item = menuItems[index]
                    MenuItemButton(
                        icon: item.icon,
                        label: item.label,
                        subtitle: item.subtitle,
                        color: item.color,
                        theme: theme
                    ) {
                        onNavigate(item.screen)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

struct MenuItemButton: View {
    let icon: String
    let label: String
    let subtitle: String
    let color: Color
    let theme: Theme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(color)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(theme == .dark ? .white : .black)

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(theme == .dark ? .darkSeparator : Color.systemGray3)
            }
            .padding(20)
            .background(theme == .dark ? Color.darkElevated : Color.systemGray6)
            .cornerRadius(16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let theme: Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(theme == .dark ? .white : .black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(theme == .dark ? Color.darkElevated : Color.systemGray6)
        .cornerRadius(12)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
