import SwiftUI

extension Color {
    // MARK: - Semantic Color Palette
    
    // Primary Brand Colors
    static let primaryBlue = Color(hex: "007AFF")      // Primary actions
    static let secondaryBlue = Color(hex: "5AC8FA")    // Selections, secondary actions
    static let successGreen = Color(hex: "34C759")     // Available status, positive states
    static let warningOrange = Color(hex: "FF9500")    // Warnings and attention states
    static let errorRed = Color(hex: "FF3B30")         // Errors and critical states
    static let powerYellow = Color(hex: "FFCC00")      // Power/energy indicators
    
    // Neutral Colors
    static let primaryText = Color.primary
    static let secondaryText = Color(hex: "6C6C70")
    static let tertiaryText = Color(hex: "C7C7CC")
    static let backgroundGray = Color(hex: "F2F2F7")
    static let cardBackground = Color(UIColor.systemBackground)
    static let neutralGray = Color(hex: "8E8E93")
    
    // MARK: - Status Colors
    static let statusAvailable = successGreen
    static let statusOccupied = warningOrange
    static let statusOutOfOrder = errorRed
    static let statusUnknown = neutralGray
    
    // MARK: - Hex Color Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Charger Status Color Helper
extension ChargerAvailabilityStatus {
    var colorValue: Color {
        switch self {
        case .available:
            return .statusAvailable
        case .occupied:
            return .statusOccupied
        case .outOfOrder:
            return .statusOutOfOrder
        case .unknown:
            return .statusUnknown
        }
    }
    
    var iconName: String {
        switch self {
        case .available:
            return "checkmark.circle.fill"
        case .occupied:
            return "minus.circle.fill"
        case .outOfOrder:
            return "xmark.circle.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
}