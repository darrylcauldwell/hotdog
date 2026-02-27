import SwiftUI

struct ResultView: View {
    let result: ImageClassifier.ClassificationResult
    @State private var opacity: Double = 0.0

    var body: some View {
        HStack(spacing: 8) {
            Text(isHotdog ? "🌭" : "🚫")
                .font(.title)

            Text(isHotdog ? "HOTDOG!" : "NOT HOTDOG!")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(isHotdog ? .green : .red)

            Text(confidenceText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1.0
            }
        }
    }

    private var isHotdog: Bool {
        if case .hotdog = result { return true }
        return false
    }

    private var confidenceText: String {
        switch result {
        case .hotdog(let confidence):
            return String(format: "%.0f%%", confidence * 100)
        case .notHotdog(_, let confidence):
            return String(format: "%.0f%%", confidence * 100)
        }
    }
}
