import SwiftUI

struct OnboardingScreen: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedPieces: Int = 7

    let pieceOptions = [1, 3, 5, 7]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: max(40, geometry.size.height * 0.08))

                    // Logo/Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.systemBlue, .systemPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)

                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 30)

                    // Title
                    Text("REFINE")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(themeManager.theme == .dark ? .white : .black)
                        .padding(.bottom, 12)

                    Text("생각의 조각을 모아...")
                        .font(.system(size: 17))
                        .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 40)

                    // Pieces Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("몇 개의 조각을 모을까요?")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(themeManager.theme == .dark ? .white : .black)
                            .padding(.horizontal, 24)

                        Text("조각이 모이면 AI가 당신의 생각을 분석합니다")
                            .font(.system(size: 15))
                            .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 8)

                        VStack(spacing: 12) {
                            ForEach(pieceOptions, id: \.self) { count in
                                PieceOptionCard(
                                    count: count,
                                    isSelected: selectedPieces == count,
                                    theme: themeManager.theme
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedPieces = count
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 30)

                    // Start Button
                    Button(action: {
                        appState.setPiecesPerCycle(selectedPieces)
                        appState.navigate(to: .dashboard)
                    }) {
                        Text("시작하기")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.systemBlue, .systemPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(40, geometry.safeAreaInsets.bottom + 20))
                }
                .frame(minHeight: geometry.size.height)
            }
            .scrollIndicators(.hidden)
        }
        .background(themeManager.theme == .dark ? Color.darkBackground : .white)
    }
}

struct PieceOptionCard: View {
    let count: Int
    let isSelected: Bool
    let theme: Theme
    let action: () -> Void

    var description: String {
        switch count {
        case 1:
            return "빠른 인사이트"
        case 3:
            return "간단한 기록"
        case 5:
            return "균형잡힌 탐구"
        case 7:
            return "깊이 있는 성찰"
        default:
            return ""
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.systemBlue.opacity(0.15) : (theme == .dark ? Color.darkElevated : Color.systemGray6))
                        .frame(width: 56, height: 56)

                    Text("\(count)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(isSelected ? .systemBlue : (theme == .dark ? .darkSecondary : .systemGray))
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(count)개의 조각")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(theme == .dark ? .white : .black)

                    Text(description)
                        .font(.system(size: 15))
                        .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.systemBlue)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme == .dark ? Color.darkElevated : Color.systemGray6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.systemBlue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
