import Foundation
import SwiftUI

enum Theme: String {
    case light
    case dark
}

struct TonePalette {
    let accent: Color
    let glow: Color
    let chipBg: Color
    let softGradientTop: Color
}

class ThemeManager: ObservableObject {
    @Published var theme: Theme = .light
    @Published var currentTone: RefineTone = .neutral

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

    func paletteFor(_ tone: RefineTone) -> TonePalette {
        switch tone {
        case .calm:
            return .init(
                accent: .cyan,
                glow: .cyan.opacity(0.55),
                chipBg: .cyan.opacity(0.12),
                softGradientTop: .cyan.opacity(0.22)
            )
        case .growth:
            return .init(
                accent: .green,
                glow: .green.opacity(0.55),
                chipBg: .green.opacity(0.12),
                softGradientTop: .green.opacity(0.22)
            )
        case .challenge:
            return .init(
                accent: .orange,
                glow: .orange.opacity(0.55),
                chipBg: .orange.opacity(0.12),
                softGradientTop: .orange.opacity(0.22)
            )
        case .joy:
            return .init(
                accent: .yellow,
                glow: .yellow.opacity(0.50),
                chipBg: .yellow.opacity(0.12),
                softGradientTop: .yellow.opacity(0.20)
            )
        case .reflection:
            return .init(
                accent: .purple,
                glow: .purple.opacity(0.55),
                chipBg: .purple.opacity(0.12),
                softGradientTop: .purple.opacity(0.22)
            )
        case .neutral:
            return .init(
                accent: .gray,
                glow: .gray.opacity(0.45),
                chipBg: .gray.opacity(0.10),
                softGradientTop: .gray.opacity(0.16)
            )
        }
    }
}
