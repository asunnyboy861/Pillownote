import Foundation
import SwiftUI

enum GlowService {
    static func generateWeekly(digests: [MemoryDigest]) -> GlowReport {
        let summary = MemoryService.weeklySummary(digests: digests)
        let insight = weeklyInsight(summary: summary)
        return GlowReport(periodStart: startOfWeek(), isMonthly: false, resonanceCount: summary.resonance, topTags: summary.topTags, sweetestQuote: summary.sweetest, insight: insight, valenceAvg: summary.valenceAvg)
    }

    static func generateMonthly(digests: [MemoryDigest], deep: Bool) async -> GlowReport {
        let monthDigests = digests.filter { $0.day > Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date() }
        let tags = monthDigests.flatMap(\.tags).uniqued()
        let valenceAvg = monthDigests.isEmpty ? 0 : monthDigests.map(\.valence).reduce(0, +) / Double(monthDigests.count)
        let sweetest = monthDigests.max(by: { $0.highlight.count < $1.highlight.count })?.highlight ?? ""
        var insight = monthlyInsight(digests: monthDigests)
        if deep, let key = AIConfiguration.apiKey() {
            let payload = monthDigests.suffix(30).map { "\($0.day.formatted(date: .abbreviated, time: .omitted)): tags=\($0.tags.joined(separator: "/")) valence=\(String(format: "%.1f", $0.valence))" }.joined(separator: "\n")
            let system = """
                You write 'Monthly Glow' — a 150-word relationship report for a couple. \
                Sections woven into prose: Tone, What changed, One thing to try. \
                Warm, specific, never clinical. Base it ONLY on the provided digest. US English.
                """
            if let text = await CloudAIService.chat(systemPrompt: system, userPrompt: payload, apiKey: key) {
                insight = text
            }
        }
        return GlowReport(periodStart: startOfMonth(), isMonthly: true, resonanceCount: monthDigests.count, topTags: Array(tags.prefix(6)), sweetestQuote: sweetest, insight: insight, valenceAvg: valenceAvg)
    }

    static func radarData(digests: [MemoryDigest]) -> [(category: String, value: Double)] {
        let categories = ["fun", "deep", "future", "intimacy", "gratitude"]
        return categories.map { category in
            let relevant = digests.filter { $0.tags.contains(category) }
            let value = relevant.isEmpty ? 0.2 : min(1, 0.4 + abs(relevant.map(\.valence).reduce(0, +) / Double(relevant.count)) * 0.6)
            return (category, value)
        }
    }

    private static func weeklyInsight(summary: (resonance: Int, topTags: [String], sweetest: String, valenceAvg: Double)) -> String {
        let tone = summary.valenceAvg > 0.2 ? "light and warm" : (summary.valenceAvg < -0.2 ? "thoughtful and tender" : "steady")
        let tagLine = summary.topTags.isEmpty ? "" : " You kept returning to: \(summary.topTags.prefix(3).joined(separator: ", "))."
        return "This week felt \(tone). You shared \(summary.resonance) answered moments.\(tagLine)"
    }

    private static func monthlyInsight(digests: [MemoryDigest]) -> String {
        guard !digests.isEmpty else {
            return "Your first month of answers is just beginning. Each one becomes part of your story."
        }
        let first = digests.prefix(5).flatMap(\.tags).uniqued().prefix(3)
        let last = digests.suffix(5).flatMap(\.tags).uniqued().prefix(3)
        let trend = Set(last).subtracting(first)
        if !trend.isEmpty {
            return "You started talking more about \(trend.prefix(2).joined(separator: " and ")) — a new thread this month."
        }
        return "Your rhythm held steady this month. The themes you two share run deep: \(last.joined(separator: ", "))."
    }

    static func startOfWeek() -> Date {
        Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
    }

    static func startOfMonth() -> Date {
        Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
    }

    @MainActor
    static func renderShareImage(report: GlowReport, daysTogether: Int) -> UIImage? {
        let view = ShareCardView(report: report, daysTogether: daysTogether)
        let renderer = ImageRenderer(content: view.frame(width: 1080, height: 1350))
        renderer.scale = 1
        return renderer.uiImage
    }
}

struct ShareCardView: View {
    let report: GlowReport
    let daysTogether: Int

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.coral, Theme.coral.opacity(0.6), Theme.sage.opacity(0.5)], startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    Image(systemName: "envelope.open.fill")
                    Text("Pillownote")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                Text(report.isMonthly ? "Monthly Glow" : "Weekly Glow")
                    .font(.system(size: 72, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                HStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(daysTogether)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                        Text("days of us")
                            .font(.system(size: 24))
                    }
                    .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(report.resonanceCount)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                        Text("shared moments")
                            .font(.system(size: 24))
                    }
                    .foregroundStyle(.white)
                }
                if !report.sweetestQuote.isEmpty {
                    Text("“\(report.sweetestQuote)”")
                        .font(.system(size: 30, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.95))
                        .lineLimit(4)
                }
                Spacer()
                Text("made with Pillownote — daily questions for couples")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(64)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
