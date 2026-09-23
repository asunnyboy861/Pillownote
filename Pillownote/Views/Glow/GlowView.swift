import SwiftUI
import SwiftData

struct GlowView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \GlowReport.createdAt, order: .reverse) private var reports: [GlowReport]
    @Query(sort: \MemoryDigest.day, order: .reverse) private var digests: [MemoryDigest]
    @Query private var profiles: [CoupleProfile]
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var isGenerating = false
    @State private var shareImage: UIImage?
    @State private var sharingReport: GlowReport?

    private var daysTogether: Int {
        profiles.first?.anniversaryDate.flatMap { Calendar.current.dateComponents([.day], from: $0, to: Date()).day } ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    radarCard
                    generateCard
                    ForEach(reports) { report in
                        ReportCard(report: report) {
                            sharingReport = report
                        }
                    }
                    if reports.isEmpty {
                        Text("Your first Glow arrives after a few answered questions.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.cream)
            .navigationTitle("Glow")
            .sheet(item: $sharingReport) { report in
                ShareSheet(items: shareItems(for: report))
            }
        }
    }

    private var radarCard: some View {
        VStack(spacing: 14) {
            Label("Your themes", systemImage: "circle.hexagongrid.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.coral)
            RadarChartView(data: GlowService.radarData(digests: digests))
                .frame(height: 220)
        }
        .cozyCard()
    }

    private var generateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("This week", systemImage: "calendar")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.coral)
            Text("Generate your Weekly Glow — resonance, new discoveries, and the sweetest line of the week.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button {
                generateWeekly()
            } label: {
                Label("Generate Weekly Glow", systemImage: "sparkles")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isGenerating)
            Label("This month", systemImage: "calendar.badge.clock")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.coral)
                .padding(.top, 8)
            Text("Monthly Glow maps your communication patterns and what changed. Plus deepens it with AI insights.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button {
                generateMonthly()
            } label: {
                if purchaseManager.isPremium {
                    Label("Generate Monthly Glow", systemImage: "moon.stars.fill")
                } else {
                    Label("Generate simplified Monthly Glow", systemImage: "moon.stars")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isGenerating)
        }
        .cozyCard()
    }

    private func generateMonthly() {
        isGenerating = true
        Task {
            let deep = purchaseManager.isPremium || AIConfiguration.hasAPIKey
            let report = await GlowService.generateMonthly(digests: digests, deep: deep)
            context.insert(report)
            try? context.save()
            await MainActor.run {
                isGenerating = false
            }
        }
    }

    private func generateWeekly() {
        isGenerating = true
        Task {
            let report = GlowService.generateWeekly(digests: digests)
            context.insert(report)
            try? context.save()
            await MainActor.run {
                isGenerating = false
            }
        }
    }

    private func shareItems(for report: GlowReport) -> [Any] {
        if let image = GlowService.renderShareImage(report: report, daysTogether: daysTogether) {
            return [image]
        }
        return [report.insight]
    }
}

struct ReportCard: View {
    let report: GlowReport
    let onShare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(report.isMonthly ? "Monthly Glow" : "Weekly Glow", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.coral)
                Spacer()
                Text(report.createdAt.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            if report.isMonthly {
                RadarChartView(data: report.radarData)
                    .frame(height: 180)
            }
            Text(report.insight)
                .font(.subheadline)
            if !report.sweetestQuote.isEmpty {
                Text("“\(report.sweetestQuote)”")
                    .font(.system(.subheadline, design: .serif).italic())
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("\(report.resonanceCount) shared moments")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    onShare()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            }
        }
        .cozyCard()
    }
}

extension GlowReport {
    var radarData: [(category: String, value: Double)] {
        let categories = ["fun", "deep", "future", "intimacy", "gratitude"]
        return categories.map { category in
            let included = topTags.contains(category)
            return (category, included ? 0.85 : 0.25)
        }
    }
}

struct RadarChartView: View {
    let data: [(category: String, value: Double)]

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2 - 34
            ZStack {
                ForEach(0..<3, id: \.self) { ring in
                    PolygonShape(points: polygonPoints(radius * (0.35 + Double(ring) * 0.32), center: center))
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                }
                PolygonShape(points: dataPoints(center: center, radius: radius))
                    .fill(Theme.coral.opacity(0.28))
                PolygonShape(points: dataPoints(center: center, radius: radius))
                    .stroke(Theme.coral, lineWidth: 2)
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    let angle = angleFor(index: index)
                    Text(capitalized(item.category))
                        .font(.caption2.weight(.medium))
                        .position(x: center.x + cos(angle) * (radius + 20), y: center.y + sin(angle) * (radius + 18))
                }
            }
        }
    }

    private func angleFor(index: Int) -> Double {
        let slice = (Double.pi * 2) / Double(max(1, data.count))
        return -Double.pi / 2 + slice * Double(index)
    }

    private func polygonPoints(_ radius: Double, center: CGPoint) -> [CGPoint] {
        (0..<data.count).map { index in
            let angle = angleFor(index: index)
            return CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
        }
    }

    private func dataPoints(center: CGPoint, radius: Double) -> [CGPoint] {
        data.enumerated().map { index, item in
            let angle = angleFor(index: index)
            let r = radius * max(0.12, min(1, item.value))
            return CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
        }
    }

    private func capitalized(_ s: String) -> String { s.prefix(1).uppercased() + s.dropFirst() }
}

struct PolygonShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        points.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
