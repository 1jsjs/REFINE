import SwiftUI

enum RefineTone: String, Codable, CaseIterable {
    case calm
    case growth
    case challenge
    case joy
    case reflection
    case neutral
}

extension RefineTone {
    init(looseRaw: String?) {
        let v = (looseRaw ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self = RefineTone(rawValue: v) ?? .neutral
    }

    var displayName: String {
        switch self {
        case .calm: return "평온"
        case .growth: return "성장"
        case .challenge: return "도전"
        case .joy: return "기쁨"
        case .reflection: return "성찰"
        case .neutral: return "중립"
        }
    }
}
