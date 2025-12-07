import Foundation
import SwiftData

@Model
class DailyEntry {
    var id: UUID
    var date: Date
    var text: String
    var pieceNumber: Int // 조각 번호 (1, 2, 3...)
    var cycleNumber: Int // 몇 번째 사이클인지
    var imageData: [Data]? // Store image data

    init(date: Date, text: String, pieceNumber: Int, cycleNumber: Int, imageData: [Data]? = nil) {
        self.id = UUID()
        self.date = date
        self.text = text
        self.pieceNumber = pieceNumber
        self.cycleNumber = cycleNumber
        self.imageData = imageData
    }
}
