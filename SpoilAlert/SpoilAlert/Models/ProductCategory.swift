import Foundation

enum ProductCategory: String, CaseIterable {
    case cleanser = "Cleanser"
    case toner = "Toner"
    case serum = "Serum"
    case moisturizer = "Moisturizer"
    case sunscreen = "Sunscreen"
    case eyeCream = "Eye Cream"
    case exfoliant = "Exfoliant"
    case mask = "Mask"
    case oil = "Face Oil"
    case other = "Other"

    var defaultPAO: Int {
        switch self {
        case .cleanser: return 12
        case .toner: return 12
        case .serum: return 6
        case .moisturizer: return 12
        case .sunscreen: return 12
        case .eyeCream: return 6
        case .exfoliant: return 12
        case .mask: return 12
        case .oil: return 6
        case .other: return 12
        }
    }

    var iconName: String {
        switch self {
        case .cleanser: return "drop.fill"
        case .toner: return "spraybottle.fill"
        case .serum: return "eyedropper.full"
        case .moisturizer: return "cloud.fill"
        case .sunscreen: return "sun.max.fill"
        case .eyeCream: return "eye.fill"
        case .exfoliant: return "sparkles"
        case .mask: return "face.smiling.fill"
        case .oil: return "flame.fill"
        case .other: return "circle.fill"
        }
    }
}
