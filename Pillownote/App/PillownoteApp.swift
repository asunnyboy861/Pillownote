import SwiftUI
import SwiftData

@main
struct PillownoteApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([Question.self, PillowNote.self, MemoryDigest.self, GlowReport.self, CoachMessage.self, CoupleProfile.self])
        let configuration = ModelConfiguration(schema: schema)
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        HapticService.prepare()
    }

    var body: some Scene {
        WindowGroup {
            RootGateView()
                .modelContainer(container)
                .tint(Theme.coral)
        }
    }
}

struct RootGateView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [CoupleProfile]
    @State private var showOnboarding = false

    var body: some View {
        Group {
            if profiles.first?.onboarded == true {
                RootTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            if profiles.isEmpty {
                context.insert(CoupleProfile())
            }
        }
    }
}

struct RootTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "envelope.open.fill") }
            UsView()
                .tabItem { Label("Us", systemImage: "heart.text.square.fill") }
            CoachView()
                .tabItem { Label("Coach", systemImage: "bubble.left.and.bubble.right.fill") }
            GlowView()
                .tabItem { Label("Glow", systemImage: "sparkles") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}
