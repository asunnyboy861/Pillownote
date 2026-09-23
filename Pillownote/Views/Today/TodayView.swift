import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Question.assignedUTC, order: .reverse) private var questions: [Question]
    @Query(sort: \PillowNote.createdUTC, order: .reverse) private var notes: [PillowNote]
    @Query private var profiles: [CoupleProfile]
    @State private var showComposer = false
    @State private var showRevealFor: Question?

    private var profile: CoupleProfile? { profiles.first }
    private var todayQuestion: Question? {
        let calendar = Calendar.current
        return questions.first { calendar.isDateInToday($0.assignedUTC) }
    }
    private var incomingNotes: [PillowNote] { notes.filter { $0.isIncoming && $0.isUnlocked && $0.openedAt == nil } }
    private var sealedUnlockedCount: Int { incomingNotes.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let question = todayQuestion {
                        DailySparkCard(question: question) {
                            showRevealFor = question
                        }
                    } else {
                        EmptySparkCard()
                    }
                    if !incomingNotes.isEmpty {
                        ForEach(incomingNotes) { note in
                            NavigationLink {
                                EnvelopeOpenView(note: note)
                            } label: {
                                IncomingEnvelopeCard(note: note)
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        IncomingEmptyCard()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.cream)
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showComposer = true
                    } label: {
                        Image(systemName: "pencil.line")
                            .accessibilityLabel("Write a pillow note")
                    }
                }
            }
            .sheet(isPresented: $showComposer) {
                NoteComposerView()
            }
            .sheet(item: $showRevealFor) { question in
                RevealView(question: question)
            }
        }
    }
}

private struct DailySparkCard: View {
    @Environment(\.modelContext) private var context
    @StateObject var purchaseManager = PurchaseManager.shared
    @ObservedObject var demoPartner = DemoPartner.shared
    let question: Question
    let onReveal: () -> Void
    @State private var answer = ""
    @State private var isGenerating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Daily Spark", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.coral)
                Spacer()
                if question.sourceRaw == QuestionSource.staticBank.rawValue {
                    Text("from our deck")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Text(question.text)
                .font(.system(.title3, design: .rounded).weight(.semibold))
            if question.isAnsweredByMe {
                HStack(spacing: 10) {
                    Image(systemName: question.isAnsweredByPartner ? "envelope.open.fill" : "hourglass")
                        .foregroundStyle(Theme.sage)
                    Text(question.isAnsweredByPartner ? "You're both in — time to reveal" : "Sealed. Their answer is on its way…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if question.isAnsweredByPartner {
                        Button("Reveal") { onReveal() }
                            .buttonStyle(.borderedProminent)
                    }
                }
                .padding(12)
                .background(Theme.sage.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Blind answer: write yours before you can see theirs.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Your answer…", text: $answer, axis: .vertical)
                        .lineLimit(2...5)
                        .padding(12)
                        .background(Color(uiColor: .tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    Button {
                        submit()
                    } label: {
                        Label("Seal my answer", systemImage: "lock.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityHint("Seals your answer. Your partner cannot see it until they answer too.")
                }
            }
        }
        .cozyCard()
        .task(id: question.id) {
            if question.isAnsweredByMe, !question.isAnsweredByPartner, profileAllowsDemo {
                demoPartner.schedulePartnerAnswer(for: question, context: context)
            }
        }
    }

    private var profileAllowsDemo: Bool { true }

    private func submit() {
        question.myAnswerText = answer
        question.myTZ = TimeZone.current.identifier
        answer = ""
        try? context.save()
        let digests = (try? context.fetch(FetchDescriptor<MemoryDigest>())) ?? []
        let digest = MemoryService.extractDigest(from: question.myAnswerText ?? "", existing: digests)
        context.insert(digest)
        try? context.save()
        HapticService.heartbeat()
        WidgetUpdater.update(context: context)
        if !question.isAnsweredByPartner {
            demoPartner.schedulePartnerAnswer(for: question, context: context)
        }
    }
}

private struct EmptySparkCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Daily Spark", systemImage: "sparkles")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.coral)
            Text("Tonight's question arrives at 8 PM — a fresh one, made just for you two.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .cozyCard()
    }
}

private struct IncomingEnvelopeCard: View {
    let note: PillowNote

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Pillow Note", systemImage: "envelope.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text(note.kind == .voice ? "Voice" : (note.kind == .photo ? "Photo" : "Letter"))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }
            Text("Swipe up to tear it open 💌")
                .font(.headline)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(LinearGradient(colors: [Theme.coral, Theme.coral.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct IncomingEmptyCard: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "moon.zzz.fill")
                .foregroundStyle(.secondary)
            Text("No sealed notes right now. Write one for tonight — it lands on their pillow at 7 AM.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .cozyCard()
    }
}
