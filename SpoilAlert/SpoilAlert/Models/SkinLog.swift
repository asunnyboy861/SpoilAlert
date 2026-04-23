import SwiftData
import Foundation

@Model
final class SkinLog {
    var id: UUID
    var date: Date
    var condition: Int
    var notes: String
    var productID: UUID?

    init(condition: Int, notes: String, productID: UUID? = nil) {
        self.id = UUID()
        self.date = Date()
        self.condition = condition
        self.notes = notes
        self.productID = productID
    }
}
