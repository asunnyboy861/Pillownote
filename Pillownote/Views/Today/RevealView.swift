import SwiftUI
import SwiftData

struct RevealView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    var question: Question
    @State private var opened = false
    @State private var resonance = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if opened {
                    sideBySide
                        .transition(.opacity)
                } else {
                    sealedPreview
                        .transition(.opacity)
                }
            }
            .padding(24)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.cream)
            .navigationTitle("The Reveal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                if question.bothAnswered && !question.isRevealed {
                    question.revealedAt = Date()
                    try? context.save()
                    HapticService.reveal()
                }
                generateResonance()
            }
        }
    }

    private var sealedPreview: some View {
        VStack(spacing: 20) {
            Image(systemName: "envelope.open.badge.clock")
                .font(.system(size: 64))
                .foregroundStyle(Theme.coral)
            Text("Both answers are sealed in.")
                .font(.title3.weight(.semibold))
            Button {
                withAnimation(.easeInOut(duration: 0.45)) {
                    opened = true
                    HapticService.tearOpen()
                }
            } label: {
                Label("Open together", systemImage: "envelope.open.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: 280)
        }
    }

    private var sideBySide: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(alignment: .top, spacing: 16) {
                    answerCard(title: "You", text: question.myAnswerText ?? "—", tint: Theme.coral)
                    answerCard(title: "Them", text: question.partnerAnswerText ?? "—", tint: Theme.sage)
                }
                if !resonance.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Your resonance this week", systemImage: "sparkle")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.coral)
                        Text(resonance)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cozyCard()
                }
                NavigationLink {
                    NoteComposerView(replyingTo: question)
                } label: {
                    Label("Leave them a pillow note", systemImage: "envelope.badge.fill")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.vertical, 8)
        }
    }

    private func answerCard(title: String, text: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
            Text(text)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
        .background(tint.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func generateResonance() {
        Task {
            let digests = (try? context.fetch(FetchDescriptor<MemoryDigest>(sortBy: [SortDescriptor(\.day, order: .reverse)]))) ?? []
            let recent = digests.prefix(7)
            let tags = recent.flatMap(\.tags).uniqued().prefix(3)
            if tags.isEmpty {
                resonance = "Your answers are already building a shared story — keep going."
            } else {
                resonance = "This week you two keep circling: \(tags.joined(separator: ", ")). That's your resonance point."
            }
        }
    }
}
