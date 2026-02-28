import SwiftUI
import UIKit

// MARK: - Adaptive Color Provider

struct AppColors {

    // MARK: - Primary Blue Theme Colors (shared Dreamfold palette)

    static let primary = Color(light: (0.15, 0.45, 0.85), dark: (0.35, 0.6, 1.0))
    static let secondary = Color(light: (0.4, 0.65, 0.95), dark: (0.5, 0.7, 1.0))
    static let accent = Color(light: (0.0, 0.5, 1.0), dark: (0.3, 0.7, 1.0))
    static let deep = Color(light: (0.1, 0.3, 0.6), dark: (0.25, 0.5, 0.85))
    static let light = Color(light: (0.85, 0.92, 1.0), dark: (0.15, 0.25, 0.4))

    // MARK: - Result Colors

    static let hotdog = Color(light: (0.2, 0.7, 0.4), dark: (0.35, 0.85, 0.5))
    static let notHotdog = Color(light: (0.9, 0.25, 0.25), dark: (1.0, 0.4, 0.4))

    // MARK: - Status Colors

    static let active = Color(light: (0.2, 0.7, 0.4), dark: (0.35, 0.85, 0.5))
    static let inactive = Color(light: (0.5, 0.55, 0.65), dark: (0.45, 0.5, 0.6))
    static let warning = Color(light: (0.95, 0.65, 0.15), dark: (1.0, 0.75, 0.35))
    static let error = Color(light: (0.9, 0.25, 0.25), dark: (1.0, 0.4, 0.4))

    // MARK: - Surface Colors

    static let cardBackground = Color(light: (0.94, 0.96, 0.99), dark: (0.12, 0.14, 0.18))
    static let elevatedSurface = Color(light: (0.97, 0.98, 1.0), dark: (0.16, 0.18, 0.22))

    // MARK: - Neutral

    static let neutralGray = Color(light: (0.55, 0.55, 0.6), dark: (0.5, 0.5, 0.55))
}

// MARK: - Color Extension for Light/Dark (iOS 16 compatible)

extension Color {
    init(light: (CGFloat, CGFloat, CGFloat), dark: (CGFloat, CGFloat, CGFloat)) {
        self.init(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: dark.0, green: dark.1, blue: dark.2, alpha: 1)
            } else {
                return UIColor(red: light.0, green: light.1, blue: light.2, alpha: 1)
            }
        })
    }
}
