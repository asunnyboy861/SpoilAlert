import SwiftData
import Foundation

@Model
final class SkincareProduct {
    @Attribute(.unique) var id: UUID
    var name: String
    var brand: String
    var category: String
    var openDate: Date
    var expirationDate: Date
    var paoMonths: Int
    var imageData: Data?
    var barcode: String?
    var notes: String?
    var usageStatus: String
    var dailyUsageCount: Int
    var lastUsedDate: Date?
    var createdAt: Date
    var updatedAt: Date

    init(name: String, brand: String, category: String, openDate: Date, paoMonths: Int) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.category = category
        self.openDate = openDate
        self.paoMonths = paoMonths
        self.expirationDate = Calendar.current.date(byAdding: .month, value: paoMonths, to: openDate) ?? openDate
        self.usageStatus = "active"
        self.dailyUsageCount = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
    }

    var expiryStatus: String {
        switch daysRemaining {
        case ..<0: return "expired"
        case 0...7: return "critical"
        case 8...30: return "warning"
        default: return "safe"
        }
    }
}
