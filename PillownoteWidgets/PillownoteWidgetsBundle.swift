import WidgetKit
import SwiftUI

private func coral() -> Color { Color(red: 1.0, green: 0.478, blue: 0.42) }
private func sage() -> Color { Color(red: 0.659, green: 0.765, blue: 0.627) }

private func snapshot() -> WidgetSnapshot {
    WidgetSharedStore.load() ?? WidgetSnapshot()
}

struct DaysTogetherEntry: TimelineEntry {
    let date: Date
    let days: Int
    let reunionDays: Int?
}

struct DaysTogetherProvider: TimelineProvider {
    func placeholder(in context: Context) -> DaysTogetherEntry { DaysTogetherEntry(date: .now, days: 128, reunionDays: 12) }
    func getSnapshot(in context: Context, completion: @escaping (DaysTogetherEntry) -> Void) {
        let s = snapshot()
        completion(DaysTogetherEntry(date: .now, days: s.daysTogether, reunionDays: s.reunionDays))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<DaysTogetherEntry>) -> Void) {
        let s = snapshot()
        let entry = DaysTogetherEntry(date: .now, days: s.daysTogether, reunionDays: s.reunionDays)
        completion(Timeline(entries: [entry], policy: .atEnd))
    }
}

struct DaysTogetherWidgetView: View {
    var entry: DaysTogetherEntry

    var body: some View {
        VStack(spacing: 2) {
            Text("\(entry.days)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(coral())
            Text("days of us")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let ldr = entry.reunionDays {
                Text("\(ldr) days to see you")
                    .font(.caption2)
                    .foregroundStyle(sage())
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct DaysTogetherWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DaysTogether", provider: DaysTogetherProvider()) { entry in
            DaysTogetherWidgetView(entry: entry)
        }
        .configurationDisplayName("Days of Us")
        .description("Together days & reunion countdown — free forever.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TodayQuestionEntry: TimelineEntry {
    let date: Date
    let question: String
}

struct TodayQuestionProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayQuestionEntry { TodayQuestionEntry(date: .now, question: "What's a memory of us you replay?") }
    func getSnapshot(in context: Context, completion: @escaping (TodayQuestionEntry) -> Void) {
        completion(TodayQuestionEntry(date: .now, question: snapshot().todayQuestion))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayQuestionEntry>) -> Void) {
        completion(Timeline(entries: [TodayQuestionEntry(date: .now, question: snapshot().todayQuestion)], policy: .atEnd))
    }
}

struct TodayQuestionWidgetView: View {
    var entry: TodayQuestionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Daily Spark", systemImage: "sparkles")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(coral())
            Text(entry.question.isEmpty ? "Tonight's question is on its way" : entry.question)
                .font(.footnote.weight(.medium))
                .lineLimit(4)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct TodayQuestionWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TodayQuestion", provider: TodayQuestionProvider()) { entry in
            TodayQuestionWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's Question")
        .description("Tonight's Daily Spark at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PartnerMoodEntry: TimelineEntry {
    let date: Date
    let mood: String?
    let partnerName: String
}

struct PartnerMoodProvider: TimelineProvider {
    func placeholder(in context: Context) -> PartnerMoodEntry { PartnerMoodEntry(date: .now, mood: "❤️", partnerName: "My Love") }
    func getSnapshot(in context: Context, completion: @escaping (PartnerMoodEntry) -> Void) {
        let s = snapshot()
        completion(PartnerMoodEntry(date: .now, mood: s.partnerMood, partnerName: s.partnerName))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<PartnerMoodEntry>) -> Void) {
        let s = snapshot()
        completion(Timeline(entries: [PartnerMoodEntry(date: .now, mood: s.partnerMood, partnerName: s.partnerName)], policy: .atEnd))
    }
}

struct PartnerMoodWidgetView: View {
    var entry: PartnerMoodEntry

    var body: some View {
        VStack(spacing: 6) {
            if let mood = entry.mood {
                Text(mood).font(.system(size: 36))
                Text("loved your note")
            } else {
                Image(systemName: "envelope.fill")
                    .foregroundStyle(coral())
                Text("No reaction yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .font(.footnote)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct PartnerMoodWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PartnerMood", provider: PartnerMoodProvider()) { entry in
            PartnerMoodWidgetView(entry: entry)
        }
        .configurationDisplayName("Partner's Mood")
        .description("How they reacted to your last note.")
        .supportedFamilies([.systemSmall])
    }
}

struct ReunionEntry: TimelineEntry {
    let date: Date
    let days: Int?
}

struct ReunionProvider: TimelineProvider {
    func placeholder(in context: Context) -> ReunionEntry { ReunionEntry(date: .now, days: 12) }
    func getSnapshot(in context: Context, completion: @escaping (ReunionEntry) -> Void) {
        completion(ReunionEntry(date: .now, days: snapshot().reunionDays))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ReunionEntry>) -> Void) {
        completion(Timeline(entries: [ReunionEntry(date: .now, days: snapshot().reunionDays)], policy: .atEnd))
    }
}

struct ReunionWidgetView: View {
    var entry: ReunionEntry

    var body: some View {
        VStack(spacing: 4) {
            if let days = entry.days {
                Text("\(days)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(sage())
                Text("days to see you")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "airplane")
                    .foregroundStyle(sage())
                Text("Set a reunion day")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct ReunionCountdownWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ReunionCountdown", provider: ReunionProvider()) { entry in
            ReunionWidgetView(entry: entry)
        }
        .configurationDisplayName("Reunion Countdown")
        .description("Counting down to your next visit.")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct PillownoteWidgetsBundle: WidgetBundle {
    var body: some Widget {
        DaysTogetherWidget()
        TodayQuestionWidget()
        PartnerMoodWidget()
        ReunionCountdownWidget()
    }
}
