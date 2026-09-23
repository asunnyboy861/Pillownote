import SwiftUI

enum Theme {
    static let coral = Color(red: 1.0, green: 0.478, blue: 0.42)
    static let coralDark = Color(red: 1.0, green: 0.557, blue: 0.522)
    static let sage = Color(red: 0.659, green: 0.765, blue: 0.627)
    static let cream = Color(uiColor: .systemBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

extension View {
    func cozyCard() -> some View {
        modifier(CardStyle())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.coral)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct EnvelopeSealedView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: [Theme.coral, Theme.coral.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(spacing: 8) {
                Image(systemName: "envelope.open.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Sealed")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }
}
