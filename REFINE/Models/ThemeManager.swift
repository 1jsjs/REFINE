import Foundation
import SwiftUI

enum Theme: String {
    case light
    case dark
}

class ThemeManager: ObservableObject {
    @Published var theme: Theme = .light

    private let userDefaults = UserDefaults.standard
    private let themeKey = "refine-theme"

    init() {
        // Load saved theme or use system preference
        if let savedTheme = userDefaults.string(forKey: themeKey),
           let theme = Theme(rawValue: savedTheme) {
            self.theme = theme
        } else {
            // Check system preference
            let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
            self.theme = isDarkMode ? .dark : .light
        }
    }

    func toggleTheme() {
        theme = theme == .light ? .dark : .light
        userDefaults.set(theme.rawValue, forKey: themeKey)
    }
}
