import SwiftUI
import SwiftData

@main
struct REFINEApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var appState = AppState()

    let modelContainer: ModelContainer

    init() {
        do {
            // Configure iCloud sync with CloudKit
            let config = ModelConfiguration(
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )

            let container = try ModelContainer(
                for: DailyEntry.self, CycleAnalysis.self,
                configurations: config
            )

            // 기존 CycleAnalysis에 toneRaw 기본값 설정
            let context = container.mainContext
            let descriptor = FetchDescriptor<CycleAnalysis>()
            if let analyses = try? context.fetch(descriptor) {
                for analysis in analyses where analysis.toneRaw.isEmpty {
                    analysis.toneRaw = RefineTone.neutral.rawValue
                }
                try? context.save()
            }

            modelContainer = container

            print("✅ ModelContainer initialized with iCloud sync enabled")
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(appState)
                .preferredColorScheme(themeManager.theme == .dark ? .dark : .light)
        }
        .modelContainer(modelContainer)
    }
}
