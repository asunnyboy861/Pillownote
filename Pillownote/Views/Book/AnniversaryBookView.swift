import SwiftUI
import SwiftData
import PDFKit

struct AnniversaryBookView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Question.assignedUTC) private var questions: [Question]
    @Query(sort: \PillowNote.createdUTC) private var notes: [PillowNote]
    @Query(sort: \MemoryDigest.day, order: .reverse) private var digests: [MemoryDigest]
    @Query private var profiles: [CoupleProfile]
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showLimit = false

    private var daysTogether: Int {
        profiles.first?.anniversaryDate.flatMap { Calendar.current.dateComponents([.day], from: $0, to: Date()).day } ?? 0
    }
    private var exportsThisMonth: Int {
        let monthStart = GlowService.startOfMonth()
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: "book.exports.\(monthStart.timeIntervalSince1970)")
        return count
    }
    private var canExport: Bool {
        purchaseManager.isPremium ? exportsThisMonth < 3 : false
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroCard
                if purchaseManager.isPremium {
                    Button {
                        export()
                    } label: {
                        if isExporting {
                            ProgressView().tint(.white)
                        } else {
                            Label("Export PDF", systemImage: "book.pages")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isExporting || !canExport)
                    Text("\(3 - exportsThisMonth) exports left this month")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    upsellCard
                }
                if let url = exportURL {
                    Link(destination: url) {
                        Label("Open exported book", systemImage: "arrow.up.forward.app")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(16)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.cream)
        .navigationTitle("Anniversary Book")
    }

    private var heroCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.coral)
            Text("\(daysTogether) days of us")
                .font(.system(.title2, design: .rounded).weight(.bold))
            Text("A keepsake of every question you sealed together, every note under the pillow — ready to print.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 20) {
                miniStat(questions.filter { $0.isRevealed }.count, "reveals")
                miniStat(notes.filter { !$0.isIncoming }.count, "notes")
                miniStat(digests.count, "moments")
            }
        }
        .frame(maxWidth: .infinity)
        .cozyCard()
    }

    private var upsellCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Part of Plus", systemImage: "lock.fill")
                .font(.subheadline.weight(.semibold))
            Text("Turn your year of questions into a beautifully formatted PDF memory book. Plus includes 3 exports every month.")
                .font(.caption)
                .foregroundStyle(.secondary)
            NavigationLink {
                PaywallView()
            } label: {
                Text("See Plus")
            }
            .buttonStyle(.bordered)
        }
        .cozyCard()
    }

    private func miniStat(_ number: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(number)").font(.system(.title3, design: .rounded).weight(.bold))
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func export() {
        isExporting = true
        Task {
            let preface = await ExportService.generatePreface(daysTogether: daysTogether, topTags: digests.flatMap(\.tags).uniqued())
            let url = await MainActor.run {
                let result = ExportService.renderAnniversaryPDF(questions: questions, notes: notes, preface: preface, daysTogether: daysTogether)
                if result != nil {
                    let key = "book.exports.\(GlowService.startOfMonth().timeIntervalSince1970)"
                    UserDefaults.standard.set(exportsThisMonth + 1, forKey: key)
                }
                return result
            }
            await MainActor.run {
                exportURL = url
                isExporting = false
                showLimit = false
            }
        }
    }
}
