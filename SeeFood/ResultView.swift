import SwiftUI

struct ResultView: View {
    let result: ImageClassifier.ClassificationResult
    @State private var appeared = false

    private var isHotdog: Bool {
        if case .hotdog = result { return true }
        return false
    }

    private var resultColor: Color {
        isHotdog ? AppColors.hotdog : AppColors.notHotdog
    }

    private var confidenceText: String {
        switch result {
        case .hotdog(let confidence):
            return String(format: "%.0f%%", confidence * 100)
        case .notHotdog(_, let confidence):
            return String(format: "%.0f%%", confidence * 100)
        }
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: isHotdog ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(resultColor)

            Text(isHotdog ? "HOTDOG!" : "NOT HOTDOG!")
                .font(.title2.bold())
                .foregroundStyle(resultColor)

            Text(confidenceText)
                .font(.subheadline)
                .foregroundStyle(AppColors.neutralGray)
                .monospacedDigit()
        }
        .glassCard(material: .thin, cornerRadius: CornerRadius.lg, shadowRadius: 6, padding: Spacing.md)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.9)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}
