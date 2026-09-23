import SwiftUI
import SwiftData

struct UsView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [CoupleProfile]
    @Query(sort: \PillowNote.createdUTC, order: .reverse) private var notes: [PillowNote]
    @Query(sort: \Question.assignedUTC, order: .reverse) private var questions: [Question]
    @State private var showEdit = false

    struct MoodEntry: Identifiable {
        let id: UUID
        let date: Date
        let emoji: String
    }

    private var profile: CoupleProfile? { profiles.first }
    private var daysTogether: Int? {
        profile?.anniversaryDate.map { Calendar.current.dateComponents([.day], from: $0, to: Date()).day ?? 0 }
    }
    private var reunionDays: Int? {
        profile?.reunionDate.flatMap { date in
            date > Date() ? Calendar.current.dateComponents([.day], from: Date(), to: date).day : nil
        }
    }
    private var moods: [MoodEntry] {
        notes.compactMap { note in
            note.reaction.map { MoodEntry(id: note.id, date: note.createdUTC, emoji: $0) }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    daysCard
                    if reunionDays != nil {
                        reunionCard
                    }
                    moodTimelineCard
                    answersStatsCard
                }
                .padding(16)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.cream)
            .navigationTitle("Us")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEdit = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showEdit) {
                UsEditView()
            }
        }
    }

    private var daysCard: some View {
        VStack(spacing: 8) {
            if let days = daysTogether {
                Text("\(days)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.coral)
                Text("days of us")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "heart.circle")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.coral)
                Text("Add your anniversary to start counting")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .cozyCard()
    }

    private var reunionCard: some View {
        VStack(spacing: 6) {
            Text("\(reunionDays!)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.sage)
            Text("days until you see each other")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .cozyCard()
    }

    private var moodTimelineCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Their moods on your notes", systemImage: "face.smiling")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.coral)
            if moods.isEmpty {
                Text("Reactions to your pillow notes will appear here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(moods.prefix(12)) { mood in
                    HStack {
                        Text(mood.emoji)
                            .font(.title3)
                        Text(mood.date.formatted(.dateTime.month(.abbreviated).day()))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
        }
        .cozyCard()
    }

    private var answersStatsCard: some View {
        let answered = questions.filter { $0.isAnsweredByMe }.count
        let revealed = questions.filter { $0.isRevealed }.count
        return VStack(alignment: .leading, spacing: 14) {
            Label("Your story so far", systemImage: "book.closed.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.coral)
            HStack(spacing: 24) {
                stat(number: answered, label: "answers")
                stat(number: revealed, label: "reveals")
                stat(number: notes.filter { !$0.isIncoming }.count, label: "notes")
            }
        }
        .cozyCard()
    }

    private func stat(number: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(number)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct UsEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var profiles: [CoupleProfile]
    @State private var anniversary: Date = Date()
    @State private var hasAnniversary = false
    @State private var reunion: Date = Date()
    @State private var hasReunion = false
    @State private var partnerName = "My Love"

    var body: some View {
        NavigationStack {
            Form {
                Section("Partner") {
                    TextField("Partner name", text: $partnerName)
                }
                Section("Anniversary") {
                    Toggle("We count from a date", isOn: $hasAnniversary)
                    if hasAnniversary {
                        DatePicker("Anniversary", selection: $anniversary, displayedComponents: .date)
                    }
                }
                Section("Reunion countdown") {
                    Toggle("We're counting down to a visit", isOn: $hasReunion)
                    if hasReunion {
                        DatePicker("Reunion day", selection: $reunion, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Our details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let profile = profiles.first else { return }
                        profile.anniversaryDate = hasAnniversary ? anniversary : nil
                        profile.reunionDate = hasReunion ? reunion : nil
                        profile.partnerName = partnerName
                        try? context.save()
                        WidgetUpdater.update(context: context)
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let profile = profiles.first {
                    partnerName = profile.partnerName
                    if let date = profile.anniversaryDate {
                        anniversary = date
                        hasAnniversary = true
                    }
                    if let date = profile.reunionDate {
                        reunion = date
                        hasReunion = true
                    }
                }
            }
        }
    }
}
