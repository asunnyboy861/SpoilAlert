import SwiftUI

enum ExpiryStatus {
    case safe
    case warning
    case critical
    case expired

    var color: Color {
        switch self {
        case .safe: return .green
        case .warning: return .orange
        case .critical: return Color(red: 1.0, green: 0.44, blue: 0.26)
        case .expired: return .red
        }
    }

    static func from(daysRemaining: Int) -> ExpiryStatus {
        switch daysRemaining {
        case ..<0: return .expired
        case 0...7: return .critical
        case 8...30: return .warning
        default: return .safe
        }
    }
}
