import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var isPurchasing = false
    @State private var successMessage: String?
    @State private var showThemes = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    header
                    if let product = purchaseManager.yearlyProduct {
                        planCard(product: product, badge: "7 days free", highlight: true) {
                            purchase(product)
                        }
                    } else {
                        Text(purchaseManager.loadError ?? "Purchase options are being set up.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .cozyCard()
                    }
                    if let product = purchaseManager.monthlyProduct {
                        planCard(product: product, badge: nil, highlight: false) {
                            purchase(product)
                        }
                    }
                    if let byo = purchaseManager.byoProduct {
                        byoCard(byo)
                    }
                    if let themes = purchaseManager.themesProduct {
                        themesCard(themes)
                    }
                    Button {
                        Task { await purchaseManager.restorePurchases() }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline)
                    }
                    legalLinks
                    autoRenewalText
                }
                .padding(20)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.cream)
            .navigationTitle("Pillownote Plus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .overlay {
                if let message = successMessage {
                    VStack {
                        Text(message)
                            .font(.subheadline.weight(.medium))
                            .padding(14)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: successMessage)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.rectangle.fill")
                .font(.system(size: 52))
                .foregroundStyle(Theme.coral)
            Text("Everything you love, without limits")
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)
            VStack(alignment: .leading, spacing: 8) {
                featureRow("Unlimited pillow notes — text, voice, photos")
                featureRow("Voice-to-text transcription")
                featureRow("Deep AI coaching and reasoning")
                featureRow("Monthly Glow relationship reports")
                featureRow("Anniversary Book PDF exports")
                featureRow("Couple theme skins + paper textures")
            }
        }
        .frame(maxWidth: .infinity)
        .cozyCard()
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.sage)
            Text(text)
                .font(.subheadline)
        }
    }

    private func planCard(product: Product, badge: String?, highlight: Bool, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.displayPrice + (product.subscription?.subscriptionPeriod.unit == .year ? " / year" : " / month"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let badge {
                    Text(badge)
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.sage)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            Button(action: action) {
                Text(highlight ? "Start free trial" : "Subscribe")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(18)
        .background(highlight ? Theme.coral.opacity(0.08) : Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            if highlight {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Theme.coral, lineWidth: 1.5)
            }
        }
    }

    private func byoCard(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName)
                        .font(.headline)
                    Text("\(product.displayPrice) once — bring your own API key")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            Text("All Plus features, forever, with unlimited deep AI through your own key (configured in Settings).")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button {
                purchase(product)
            } label: {
                Text("Buy once, keep forever")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(18)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func themesCard(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName)
                        .font(.headline)
                    Text("\(product.displayPrice) once")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            Text("Valentine, holiday and pride envelope skins — all current and future seasons.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button {
                purchase(product)
            } label: {
                Text("Unlock themes")
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.sage)
        }
        .padding(18)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var legalLinks: some View {
        HStack(spacing: 16) {
            Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/Pillownote/privacy.html")!)
                .font(.caption2)
            Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/Pillownote/terms.html")!)
                .font(.caption2)
        }
    }

    private var autoRenewalText: some View {
        Text("Pillownote Plus subscriptions automatically renew unless canceled at least 24 hours before the end of the current period. Manage or cancel anytime in your App Store account settings. Payment is charged to your Apple ID.")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }

    private func purchase(_ product: Product) {
        isPurchasing = true
        Task {
            let success = await purchaseManager.purchase(product)
            await MainActor.run {
                isPurchasing = false
                if success {
                    withAnimation {
                        successMessage = "Unlocked — enjoy! 💛"
                    }
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        await MainActor.run {
                            successMessage = nil
                        }
                    }
                }
            }
        }
    }
}
