import SwiftUI

/// Central palette, gradients, and spacing. Adapts to light/dark for contrast and a premium feel.
enum AppTheme {

    enum Spacing {
        static let xs: CGFloat = 6
        static let s: CGFloat = 10
        static let m: CGFloat = 16
        static let l: CGFloat = 22
        static let xl: CGFloat = 28
        static let xxl: CGFloat = 40
    }

    enum Corner {
        static let card: CGFloat = 22
        static let capsule: CGFloat = 999
        static let hud: CGFloat = 20
    }

    // MARK: - Screen backgrounds

    static func homeBackgroundGradient(for scheme: ColorScheme) -> [Color] {
        switch scheme {
        case .light:
            return [
                Color(red: 0.42, green: 0.76, blue: 0.98),
                Color(red: 0.62, green: 0.48, blue: 0.98),
                Color(red: 0.98, green: 0.58, blue: 0.78)
            ]
        case .dark:
            return [
                Color(red: 0.06, green: 0.09, blue: 0.22),
                Color(red: 0.12, green: 0.04, blue: 0.22),
                Color(red: 0.02, green: 0.18, blue: 0.24)
            ]
        @unknown default:
            return [.blue, .purple]
        }
    }

    static func playfieldBackgroundGradient(for scheme: ColorScheme) -> [Color] {
        switch scheme {
        case .light:
            return [
                Color(red: 0.93, green: 0.96, blue: 1.0),
                Color(red: 0.88, green: 0.92, blue: 0.99),
                Color(red: 0.95, green: 0.90, blue: 0.98)
            ]
        case .dark:
            return [
                Color(red: 0.05, green: 0.07, blue: 0.14),
                Color(red: 0.08, green: 0.05, blue: 0.12),
                Color(red: 0.04, green: 0.12, blue: 0.14)
            ]
        @unknown default:
            return [.gray.opacity(0.3), .gray.opacity(0.5)]
        }
    }

    // MARK: - Buttons

    static func primaryButtonGradient(for scheme: ColorScheme) -> [Color] {
        switch scheme {
        case .light:
            return [
                Color(red: 1.0, green: 0.45, blue: 0.35),
                Color(red: 0.95, green: 0.35, blue: 0.65)
            ]
        case .dark:
            return [
                Color(red: 0.2, green: 0.85, blue: 0.95),
                Color(red: 0.55, green: 0.35, blue: 0.98)
            ]
        @unknown default:
            return [.orange, .pink]
        }
    }

    static func secondaryButtonStroke(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.35)
            : Color.primary.opacity(0.2)
    }

    // MARK: - HUD / accents

    static func hudAccent(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.4, green: 0.95, blue: 0.9)
            : Color(red: 0.15, green: 0.45, blue: 0.85)
    }

    static func impactFlashColor(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.red.opacity(0.45)
            : Color.red.opacity(0.35)
    }
}
