import SwiftUI

// MARK: - Glass Material Levels

enum GlassMaterial {
    case ultraThin, thin, regular, thick

    var color: Color {
        switch self {
        case .ultraThin, .thin: return AppColors.cardBackground
        case .regular, .thick: return AppColors.elevatedSurface
        }
    }
}

// MARK: - Glass Card View Modifier

struct GlassCard: ViewModifier {
    let material: GlassMaterial
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let borderWidth: CGFloat
    let padding: CGFloat

    private static let borderGradient = LinearGradient(
        colors: [.white.opacity(0.3), .white.opacity(0.1), .clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    init(
        material: GlassMaterial = .regular,
        cornerRadius: CGFloat = CornerRadius.xl,
        shadowRadius: CGFloat = 10,
        borderWidth: CGFloat = BorderWidth.subtle,
        padding: CGFloat = Spacing.lg
    ) {
        self.material = material
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.borderWidth = borderWidth
        self.padding = padding
    }

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(material.color)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Self.borderGradient, lineWidth: borderWidth)
            )
            .shadow(color: .black.opacity(0.08), radius: shadowRadius, x: 0, y: 4)
    }
}

// MARK: - Glass Button Style

struct GlassButtonStyle: ButtonStyle {
    let tint: Color

    init(tint: Color = AppColors.primary) {
        self.tint = tint
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                    .fill(tint.opacity(configuration.isPressed ? 0.2 : 0.1))
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                    .stroke(tint.opacity(0.3), lineWidth: BorderWidth.subtle)
            )
            .shadow(color: tint.opacity(0.2), radius: configuration.isPressed ? 4 : 8, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func glassCard(
        material: GlassMaterial = .regular,
        cornerRadius: CGFloat = CornerRadius.xl,
        shadowRadius: CGFloat = 10,
        padding: CGFloat = Spacing.lg
    ) -> some View {
        modifier(GlassCard(material: material, cornerRadius: cornerRadius, shadowRadius: shadowRadius, padding: padding))
    }
}
