import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Background color
            (themeManager.theme == .dark ? Color.darkBackground : Color.white)
                .ignoresSafeArea()

            // Show onboarding if first launch
            if appState.isFirstLaunch {
                OnboardingScreen()
                    .transition(.opacity)
            } else {
                // Screen content with transitions
                Group {
                    switch appState.currentScreen {
                case .dashboard:
                    DashboardScreen()
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .leading)
                        ))
                case .write:
                    HomeScreen()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        ))
                        .gesture(createSwipeGesture())
                case .analysis:
                    AnalysisScreen()
                        .transition(.opacity)
                        .gesture(createSwipeGesture())
                case .result:
                    ResultScreen()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        ))
                        .gesture(createSwipeGesture())
                case .stats:
                    StatsScreen()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        ))
                        .gesture(createSwipeGesture())
                case .list:
                    ListScreen()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        ))
                        .gesture(createSwipeGesture())
                case .weeks:
                    WeeksScreen()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        ))
                        .gesture(createSwipeGesture())
                case .share:
                    ShareScreen()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        ))
                        .gesture(createSwipeGesture())
                    case .settings:
                        SettingsScreen()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .trailing)
                            ))
                            .gesture(createSwipeGesture())
                    }
                }
            }
        }
    }
    
    private func createSwipeGesture() -> some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .global)
            .onChanged { value in
                // Only allow right swipe (going back)
                if value.translation.width > 0 {
                    dragOffset = value.translation.width
                }
            }
            .onEnded { value in
                // If swiped more than 100 points to the right, go back
                if value.translation.width > 100 && value.translation.height < 50 {
                    withAnimation(.easeOut(duration: 0.3)) {
                        appState.navigateBack()
                    }
                }
                dragOffset = 0
            }
    }
}
