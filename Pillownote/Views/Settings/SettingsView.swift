import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [CoupleProfile]
    @Query private var questions: [Question]
    @Query private var notes: [PillowNote]
    @Query private var digests: [MemoryDigest]
    @Query private var reports: [GlowReport]
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    @State private var showSupport = false
    @State private var showPairing = false
    @State private var exportURL: URL?
    @State private var showShareSheet = false
    @State private var isExporting = false

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            Form {
                pairingSection
                subscriptionSection
                aiSection
                privacySection
                dataSection
                legalSection
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .sheet(isPresented: $showSupport) { ContactSupportView() }
            .sheet(isPresented: $showPairing) { PairingSettingsView() }
            .sheet(isPresented: $showShareSheet) { ShareSheet(items: [exportURL].compactMap { $0 }) }
        }
    }

    private var pairingSection: some View {
        Section {
            NavigationLink {
                PairingSettingsView()
            } label: {
                Label("Pairing & partner", systemImage: "link.circle.fill")
            }
        } footer: {
            Text(profiles.first?.pairingCode != nil ? "Paired with code \(profiles.first!.pairingCode!)" : "Pair with your partner or invite them anytime.")
        }
    }

    private var subscriptionSection: some View {
        Section {
            if purchaseManager.isPremium {
                HStack {
                    Label("Pillownote \(purchaseManager.entitlement == .byo ? "BYO Lifetime" : "Plus")", systemImage: "crown.fill")
                        .foregroundStyle(Theme.coral)
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Theme.sage)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    Label("Upgrade to Plus", systemImage: "crown.fill")
                        .foregroundStyle(Theme.coral)
                }
            }
            if purchaseManager.isPlus {
                NavigationLink {
                    AnniversaryBookView()
                } label: {
                    Label("Anniversary Book", systemImage: "book.closed.fill")
                }
            }
            Button {
                Task { await purchaseManager.restorePurchases() }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.clockwise.circle")
            }
        } header: {
            Text("Subscription")
        } footer: {
            Text("Free forever: daily questions, 1 note a day, and all widgets. Plus adds unlimited notes, reports and more.")
        }
    }

    private var aiSection: some View {
        Section {
            NavigationLink {
                AIConfigurationView()
            } label: {
                HStack {
                    Label("AI Configuration", systemImage: "cpu.fill")
                    Spacer()
                    if AppleIntelligenceStatus.isAvailable {
                        Text("Apple Intelligence")
                            .font(.caption)
                            .foregroundStyle(Theme.sage)
                    } else if AIConfiguration.hasAPIKey {
                        Text("API key set")
                            .font(.caption)
                            .foregroundStyle(Theme.sage)
                    }
                }
            }
        } header: {
            Text("AI")
        } footer: {
            Text("Apple Intelligence powers your coach on-device, free and private (iPhone 15 Pro or newer, iOS 26+). Or bring your own API key.")
        }
    }

    private var privacySection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { profiles.first?.digestUploadConsent ?? false },
                set: { profiles.first?.digestUploadConsent = $0; try? context.save() }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Share anonymized themes")
                    Text("Only tags and mood scores — never your words — improve deep reports.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Privacy")
        } footer: {
            Text("Your raw words never leave your devices and your iCloud. AI sees only on-device summaries unless you choose otherwise.")
        }
    }

    private var dataSection: some View {
        Section {
            Button {
                exportAll()
            } label: {
                if isExporting {
                    HStack { ProgressView(); Text("Exporting…") }
                } else {
                    Label("Export all my data", systemImage: "square.and.arrow.up.on.square")
                }
            }
            .disabled(isExporting)
            NavigationLink {
                AnniversaryBookView()
            } label: {
                Label("Anniversary Book", systemImage: "book.closed.fill")
            }
        } header: {
            Text("Your data")
        } footer: {
            Text("Export includes your questions, answers, notes and reports as JSON. Yours to keep, always.")
        }
    }

    private var legalSection: some View {
        Section {
            Link(destination: URL(string: "https://asunnyboy861.github.io/Pillownote/support.html")!) {
                Label("Support", systemImage: "questionmark.circle")
            }
            Link(destination: URL(string: "https://asunnyboy861.github.io/Pillownote/privacy.html")!) {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }
            Link(destination: URL(string: "https://asunnyboy861.github.io/Pillownote/terms.html")!) {
                Label("Terms of Use", systemImage: "doc.text")
            }
            Button {
                showSupport = true
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }
        } header: {
            Text("Legal & Support")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "envelope.open.fill")
                        .foregroundStyle(Theme.coral)
                    Text("Pillownote")
                        .font(.footnote.weight(.semibold))
                    Text(appVersion)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text("Leave a note on their pillow, from anywhere.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }

    private func exportAll() {
        isExporting = true
        let url = ExportService.exportAllData(questions: questions, notes: notes, digests: digests, reports: reports)
        exportURL = url
        isExporting = false
        if url != nil {
            showShareSheet = true
        }
    }
}

struct PairingSettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [CoupleProfile]
    @ObservedObject private var pairingService = PairingService.shared
    @State private var enteredCode = ""
    @State private var statusMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let code = profiles.first?.pairingCode {
                        Text(code)
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .kerning(4)
                    }
                } header: {
                    Text("Your pairing code")
                } footer: {
                    Text(pairingService.cloudAvailable ? "Share this code with your partner." : "Cloud sync isn't signed in — pairing works on one device for now.")
                }
                Section("Enter their code") {
                    TextField("6-digit code", text: $enteredCode)
                        .keyboardType(.numberPad)
                    Button("Pair") {
                        pair()
                    }
                    .disabled(enteredCode.count != 6)
                    if let statusMessage {
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Pairing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func pair() {
        guard let profile = profiles.first else { return }
        profile.pairingCode = enteredCode
        try? context.save()
        statusMessage = "Paired! You can explore together now."
        enteredCode = ""
    }
}
