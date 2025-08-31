import SwiftUI

struct Theme {
    static let primaryColor = Color(hex: "#0d7ff2")
    static let secondaryColor = Color(hex: "#1a202c")
    static let backgroundColor = Color(hex: "#121826")
    static let textPrimary = Color(hex: "#e2e8f0")
    static let textSecondary = Color(hex: "#a0aec0")
    static let accentColor = Color(hex: "#4299e1")

    // NOTE: The intended font is "Space Grotesk" from Google Fonts.
    // As we cannot bundle custom fonts in this environment, we use the system font.
    static func appFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight)
    }
}

@available(macOS 10.15, *)
extension Color {
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
