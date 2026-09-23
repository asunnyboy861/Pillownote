import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [CoupleProfile]
    @State private var page = 0
    @State private var stage: Stage = .status
    @State private var relationshipStage = "same-city"
    @State private var anniversary = Date()
    @State private var hasAnniversary = false
    @State private var pairingCode = PairingService.generateCode()
    @State private var enteredCode = ""
    @State private var partnerName = "My Love"
    @State private var useDemoPartner = false
    @State private var pairingService = PairingService.shared
    @State private var published = false

    enum Stage { case status, ritual, pairing }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    statusCard.tag(0)
                    ritualCard.tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(maxHeight: stage == .pairing ? 0 : nil)
                .opacity(stage == .pairing ? 0 : 1)

                if stage == .pairing {
                    pairingCard
                        .transition(.move(edge: .trailing))
                }

                HStack(spacing: 12) {
                    if stage != .status {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if stage == .pairing { stage = .ritual } else if page > 0 { page -= 1 }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    Button(stage == .status && page == 0 ? "Continue" : (stage == .pairing ? "Start our story" : "Continue")) {
                        advance()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: 260)
                }
                .padding(24)
            }
            .background(Theme.cream)
            .onAppear {
                Task { await pairingService.checkCloudAvailability() }
            }
        }
    }

    private var statusCard: some View {
        VStack(spacing: 24) {
            Image(systemName: "envelope.open.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.coral)
                .padding(.top, 40)
            Text("Welcome to Pillownote")
                .font(.system(size: 30, weight: .bold, design: .rounded))
            Text("Leave a note on their pillow, from anywhere.")
                .font(.body)
                .foregroundStyle(.secondary)
            VStack(spacing: 12) {
                stageOption("house.fill", title: "Same city", subtitle: "We see each other in person", value: "same-city")
                stageOption("airplane", title: "Long distance", subtitle: "Miles apart, close at heart", value: "long-distance")
                stageOption("heart.circle.fill", title: "Newly together", subtitle: "Just getting started", value: "newly-together")
            }
            Spacer()
        }
        .padding(24)
    }

    private var ritualCard: some View {
        VStack(spacing: 24) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.sage)
                .padding(.top, 40)
            Text("Choose your ritual")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Toggle(isOn: $hasAnniversary) {
                Text("We have an anniversary date")
            }
            .padding(.horizontal, 8)
            if hasAnniversary {
                DatePicker("Anniversary", selection: $anniversary, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(.horizontal, 8)
            }
            VStack(spacing: 12) {
                ritualRow("envelope.fill", "Pillow Notes", "Sealed notes they open at 7 AM")
                ritualRow("questionmark.bubble.fill", "Daily Spark", "One question, blind answers, then reveal")
                ritualRow("sparkles", "Glow reports", "See how your story unfolds")
            }
            Spacer()
        }
        .padding(24)
    }

    private var pairingCard: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "link.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.coral)
                    .padding(.top, 24)
                Text("Pair with your person")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                VStack(spacing: 8) {
                    Text("Your pairing code")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(pairingCode)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .kerning(6)
                    Button {
                        shareInvite()
                    } label: {
                        Label("Share invite", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                }
                .cozyCard()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Have their code? Enter it")
                        .font(.subheadline.weight(.semibold))
                    TextField("6-digit code", text: $enteredCode)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Text("You can pair later in Settings — everything works solo too.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .cozyCard()
                Toggle(isOn: $useDemoPartner) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Try with a demo partner")
                        Text("See how the reveal works before pairing")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .cozyCard()
            }
            .padding(24)
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }

    private func stageOption(_ icon: String, title: String, subtitle: String, value: String) -> some View {
        Button {
            relationshipStage = value
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(relationshipStage == value ? .white : Theme.coral)
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(relationshipStage == value ? .white.opacity(0.85) : .secondary)
                }
                Spacer()
                if relationshipStage == value {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                }
            }
            .padding(16)
            .background(relationshipStage == value ? Theme.coral : Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(subtitle)")
    }

    private func ritualRow(_ icon: String, _ title: String, _ subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.coral)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func advance() {
        switch stage {
        case .status where page == 0:
            withAnimation(.easeInOut(duration: 0.35)) { page = 1 }
        case .ritual, .status:
            withAnimation(.easeInOut(duration: 0.35)) { stage = .pairing }
        case .pairing:
            finish()
        }
    }

    private func shareInvite() {
        let text = "Join me on Pillownote! 💛 Our pairing code is \(pairingCode). Leave a note on my pillow, from anywhere."
        if let url = URL(string: "https://apps.apple.com/app/pillownote") {
            let controller = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
               let root = scene.keyWindow?.rootViewController {
                var top = root
                while let presented = top.presentedViewController { top = presented }
                top.present(controller, animated: true)
            }
        }
    }

    private func finish() {
        guard let profile = profiles.first else { return }
        profile.relationshipStage = relationshipStage
        profile.onboarded = true
        profile.demoPartnerEnabled = useDemoPartner
        profile.pairingCode = pairingCode
        if hasAnniversary {
            profile.anniversaryDate = anniversary
        }
        if enteredCode.count == 6 {
            profile.pairingCode = enteredCode
        }
        try? context.save()
        Task {
            let granted = await NotificationService.requestAuthorization()
            if granted {
                NotificationService.scheduleDailyReminder()
            }
            _ = await pairingService.publishCode(pairingCode, partnerName: partnerName)
        }
    }
}
