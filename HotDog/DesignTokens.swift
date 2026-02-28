import SwiftUI

// MARK: - Spacing Scale

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let jumbo: CGFloat = 32
}

// MARK: - Corner Radius Scale

enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let pill: CGFloat = 9999
}

// MARK: - Tap Target Sizes

enum TapTarget {
    static let standard: CGFloat = 44
    static let comfortable: CGFloat = 60
    static let large: CGFloat = 80
}

// MARK: - Shadow Scale

enum Shadow {
    static let subtle = ShadowConfig(color: .black.opacity(0.06), radius: 4, y: 2)
    static let medium = ShadowConfig(color: .black.opacity(0.08), radius: 8, y: 4)
    static let prominent = ShadowConfig(color: .black.opacity(0.12), radius: 12, y: 6)
    static let glass = ShadowConfig(color: .black.opacity(0.08), radius: 10, y: 4)
}

struct ShadowConfig {
    let color: Color
    let radius: CGFloat
    let y: CGFloat
    var x: CGFloat = 0
}

// MARK: - Border Width

enum BorderWidth {
    static let subtle: CGFloat = 0.5
    static let standard: CGFloat = 1
    static let emphasis: CGFloat = 2
}

// MARK: - Opacity Scale

enum Opacity {
    static let ultraLight: Double = 0.05
    static let light: Double = 0.1
    static let mediumLight: Double = 0.15
    static let medium: Double = 0.2
    static let mediumHeavy: Double = 0.3
    static let heavy: Double = 0.4
}

// MARK: - Animation Durations

enum AnimationDuration {
    static let fast: Double = 0.15
    static let standard: Double = 0.25
    static let slow: Double = 0.35
}

// MARK: - View Modifiers

extension View {
    func standardShadow(_ config: ShadowConfig = Shadow.medium) -> some View {
        self.shadow(color: config.color, radius: config.radius, x: config.x, y: config.y)
    }

    func minimumTapTarget(_ size: CGFloat = TapTarget.standard) -> some View {
        self.frame(minWidth: size, minHeight: size)
    }
}

// MARK: - Primary Action Button Style

struct PrimaryActionButtonStyle: ButtonStyle {
    let color: Color

    init(color: Color = AppColors.primary) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(Spacing.lg)
            .background(configuration.isPressed ? color.opacity(0.8) : color)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: AnimationDuration.fast), value: configuration.isPressed)
    }
}
