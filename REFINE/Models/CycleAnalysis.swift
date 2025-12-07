import Foundation
import SwiftData

@Model
class CycleAnalysis {
    var id: UUID
    var cycleNumber: Int
    var firstPieceDate: Date
    var lastPieceDate: Date
    var keywords: [String]
    var summary: String
    var oneLiner: String
    var toneRaw: String
    var createdAt: Date

    init(cycleNumber: Int, firstPieceDate: Date, lastPieceDate: Date, keywords: [String], summary: String, oneLiner: String, toneRaw: String = RefineTone.neutral.rawValue) {
        self.id = UUID()
        self.cycleNumber = cycleNumber
        self.firstPieceDate = firstPieceDate
        self.lastPieceDate = lastPieceDate
        self.keywords = keywords
        self.summary = summary
        self.oneLiner = oneLiner
        self.toneRaw = toneRaw
        self.createdAt = Date()
    }

    var tone: RefineTone {
        RefineTone(looseRaw: toneRaw)
    }
}
