import SwiftUI
import SwiftData

struct CoachView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CoachMessage.createdAt) private var messages: [CoachMessage]
    @Query(sort: \MemoryDigest.day, order: .reverse) private var digests: [MemoryDigest]
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var input = ""
    @State private var isThinking = false
    @State private var deepEnabled = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            if messages.isEmpty {
                                emptyState
                            }
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            if isThinking {
                                HStack {
                                    ProgressView()
                                    Text("Thinking about you two…")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: 720)
                        .frame(maxWidth: .infinity)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                inputBar
            }
            .background(Theme.cream)
            .navigationTitle("Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle(isOn: $deepEnabled) {
                            Label(deepEnabled ? "Deep reasoning on" : "Deep reasoning off", systemImage: "brain")
                        }
                    } label: {
                        Image(systemName: deepEnabled ? "brain.head.profile" : "slider.horizontal.3")
                    }
                    .disabled(!purchaseManager.isPremium && !AIConfiguration.hasAPIKey)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.coral)
            Text("Ask anything about us")
                .font(.title3.weight(.semibold))
            Text("Your coach remembers your themes from every answer you've sealed.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask anything about us…", text: $input, axis: .vertical)
                .lineLimit(1...4)
                .padding(10)
                .background(Color(uiColor: .tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            Button {
                send()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
            }
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isThinking)
            .accessibilityLabel("Send message")
        }
        .padding(12)
        .background(.bar)
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""
        let userMessage = CoachMessage(role: "user", text: text)
        context.insert(userMessage)
        try? context.save()
        isThinking = true
        let history = messages.map { $0 }
        Task {
            let reply = await CoachService.reply(to: history, digests: digests, deep: deepEnabled)
            await MainActor.run {
                let coachMessage = CoachMessage(role: "coach", text: reply.text, usedDeep: reply.usedCloud)
                context.insert(coachMessage)
                try? context.save()
                isThinking = false
            }
        }
    }
}

struct MessageBubble: View {
    let message: CoachMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            VStack(alignment: .leading, spacing: 6) {
                Text(message.text)
                    .font(.subheadline)
                if !message.isUser && message.usedDeep {
                    Label("deep", systemImage: "brain")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .background(message.isUser ? Theme.coral : Theme.cardBackground)
            .foregroundStyle(message.isUser ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            if !message.isUser { Spacer() }
        }
        .accessibilityElement(children: .combine)
    }
}
