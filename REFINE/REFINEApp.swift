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

            modelContainer = try ModelContainer(
                for: DailyEntry.self, CycleAnalysis.self,
                configurations: config
            )

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
