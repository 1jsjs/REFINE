import Foundation
import SwiftUI
import SwiftData

enum Screen {
    case dashboard
    case write
    case analysis
    case result
    case stats
    case list
    case weeks
    case share
    case settings
}

class AppState: ObservableObject {
    @Published var currentScreen: Screen = .dashboard
    @Published var navigationStack: [Screen] = []
    @Published var inputText: String = ""
    @Published var currentPiece: Int = 0 // 현재 조각 번호
    @Published var currentCycle: Int = 1 // 현재 사이클 번호
    @Published var piecesPerCycle: Int = 7 // 사이클당 조각 수 (1/3/5/7)

    // Analysis results (populated after API call)
    @Published var analysisKeywords: [String] = []
    @Published var analysisSummary: String = ""
    @Published var analysisOneLiner: String = ""

    // Statistics
    @Published var totalCharacters: Int = 0
    @Published var totalPhotos: Int = 0
    @Published var totalCycles: Int = 0

    // Error handling
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // First launch
    @Published var isFirstLaunch: Bool = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")

    init() {
        // Load saved pieces per cycle setting
        let savedPieces = UserDefaults.standard.integer(forKey: "piecesPerCycle")
        if savedPieces != 0 {
            piecesPerCycle = savedPieces
        }
    }

    func setPiecesPerCycle(_ count: Int) {
        piecesPerCycle = count
        UserDefaults.standard.set(count, forKey: "piecesPerCycle")
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        isFirstLaunch = false
    }

    func navigate(to screen: Screen) {
        withAnimation(.easeInOut(duration: 0.35)) {
            // Don't add dashboard to stack to prevent going back from dashboard
            if currentScreen != .dashboard {
                navigationStack.append(currentScreen)
            }

            // Clear analysis results when navigating away from result screen
            if currentScreen == .result && screen != .result {
                clearAnalysisResults()
            }

            currentScreen = screen
        }
    }
    
    func navigateBack() {
        withAnimation(.easeInOut(duration: 0.35)) {
            // Clear analysis results when navigating away from result screen
            if currentScreen == .result {
                clearAnalysisResults()
            }

            if !navigationStack.isEmpty {
                var targetScreen = navigationStack.removeLast()

                // Skip analysis screen when navigating back from result
                if currentScreen == .result && targetScreen == .analysis {
                    targetScreen = navigationStack.isEmpty ? .dashboard : navigationStack.removeLast()
                }

                currentScreen = targetScreen
            } else {
                currentScreen = .dashboard
            }
        }
    }

    func saveEntry(text: String, context: ModelContext, images: [Data]? = nil) {
        let entry = DailyEntry(
            date: Date(),
            text: text,
            pieceNumber: currentPiece + 1,
            cycleNumber: currentCycle,
            imageData: images
        )

        context.insert(entry)

        do {
            try context.save()
            currentPiece += 1
            print("✅ Entry saved: Piece \(currentPiece)/\(piecesPerCycle)")
        } catch {
            print("❌ Failed to save entry: \(error)")
            errorMessage = "저장 실패: \(error.localizedDescription)"
            showError = true
        }
    }

    // handleRefine는 이제 AnalysisScreen에서 직접 처리합니다

    func handleBack() {
        navigateBack()
    }

    func handleReset() {
        withAnimation(.easeInOut(duration: 0.35)) {
            navigationStack.removeAll()
            currentScreen = .dashboard
            inputText = ""
            // Clear analysis results when resetting
            clearAnalysisResults()
        }
    }

    func completeCycle() {
        // Move to next cycle
        currentCycle += 1
        currentPiece = 0
    }

    func clearAnalysisResults() {
        analysisKeywords = []
        analysisSummary = ""
        analysisOneLiner = ""
    }

    func loadStatistics(from entries: [DailyEntry]) {
        totalCharacters = entries.reduce(0) { $0 + $1.text.count }
        totalPhotos = entries.reduce(0) { $0 + ($1.imageData?.count ?? 0) }
    }

    func loadCurrentProgress(from entries: [DailyEntry]) {
        let currentCycleEntries = entries.filter { $0.cycleNumber == currentCycle }
        currentPiece = currentCycleEntries.count
    }
}
