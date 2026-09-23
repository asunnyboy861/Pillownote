import Foundation
import UIKit
import PDFKit
#if canImport(FoundationModels)
import FoundationModels
#endif

enum ExportService {
    static func exportAllData(questions: [Question], notes: [PillowNote], digests: [MemoryDigest], reports: [GlowReport]) -> URL? {
        struct ExportBundle: Codable {
            var questions: [String]
            var myAnswers: [String]
            var partnerAnswers: [String]
            var notes: [String]
            var digests: [String]
            var reports: [String]
            var exportedAt: Date
        }
        let bundle = ExportBundle(
            questions: questions.map { "\($0.assignedUTC): \($0.text) [\($0.category)]" },
            myAnswers: questions.compactMap { q in q.myAnswerText.map { "Q: \(q.text)\nMe: \($0)" } },
            partnerAnswers: questions.compactMap { q in q.partnerAnswerText.map { "Q: \(q.text)\nPartner: \($0)" } },
            notes: notes.map { "\($0.createdUTC): \(String($0.bodyText.prefix(200)))" },
            digests: digests.map { "\($0.day): tags=\($0.tags.joined(separator: "/")) valence=\($0.valence)" },
            reports: reports.map { "\($0.createdAt): \(String($0.insight.prefix(200)))" },
            exportedAt: Date()
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(bundle) else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Pillownote-Export-\(Int(Date().timeIntervalSince1970)).json")
        try? data.write(to: url)
        return url
    }

    @MainActor
    static func renderAnniversaryPDF(questions: [Question], notes: [PillowNote], preface: String, daysTogether: Int) -> URL? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let titleFont = UIFont.systemFont(ofSize: 30, weight: .bold)
        let headerFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let bodyFont = UIFont.systemFont(ofSize: 12)
        let highlights = questions.filter { $0.bothAnswered }.suffix(60)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = 72
            "Our Anniversary Book".draw(at: CGPoint(x: 48, y: y), withAttributes: [.font: titleFont, .foregroundColor: UIColor(red: 1.0, green: 0.478, blue: 0.42, alpha: 1)])
            y += 44
            "\(daysTogether) days of us · \(Date().formatted(.dateTime.month(.wide).day().year()))".draw(at: CGPoint(x: 48, y: y), withAttributes: [.font: headerFont, .foregroundColor: UIColor.darkGray])
            y += 30
            drawWrapped(preface, in: pageRect, x: 48, width: pageRect.width - 96, font: .systemFont(ofSize: 13, weight: .light), color: .darkGray, y: &y)
            y += 24

            for (index, question) in highlights.enumerated() {
                if y > pageRect.height - 140 {
                    ctx.beginPage()
                    y = 64
                }
                "Q\(index + 1)".draw(at: CGPoint(x: 48, y: y), withAttributes: [.font: headerFont, .foregroundColor: UIColor(red: 1.0, green: 0.478, blue: 0.42, alpha: 1)])
                y += 20
                drawWrapped(question.text, in: pageRect, x: 48, width: pageRect.width - 96, font: headerFont, color: .black, y: &y)
                y += 6
                if let mine = question.myAnswerText {
                    drawWrapped("Me: \(mine)", in: pageRect, x: 48, width: pageRect.width - 96, font: bodyFont, color: .darkGray, y: &y)
                }
                if let theirs = question.partnerAnswerText {
                    drawWrapped("You: \(theirs)", in: pageRect, x: 48, width: pageRect.width - 96, font: bodyFont, color: .darkGray, y: &y)
                }
                y += 14
            }

            if y > pageRect.height - 120 {
                ctx.beginPage()
                y = 64
            }
            "Our pillow notes".draw(at: CGPoint(x: 48, y: y), withAttributes: [.font: titleFont, .foregroundColor: UIColor(red: 1.0, green: 0.478, blue: 0.42, alpha: 1)])
            y += 40
            for note in notes.filter({ !$0.bodyText.isEmpty }).suffix(40) {
                if y > pageRect.height - 80 {
                    ctx.beginPage()
                    y = 64
                }
                drawWrapped("\(note.createdUTC.formatted(date: .abbreviated, time: .omitted)) — \(note.bodyText)", in: pageRect, x: 48, width: pageRect.width - 96, font: bodyFont, color: .darkGray, y: &y)
                y += 10
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Pillownote-Anniversary-\(Int(Date().timeIntervalSince1970)).pdf")
        try? data.write(to: url)
        return url
    }

    private static func drawWrapped(_ text: String, in pageRect: CGRect, x: CGFloat, width: CGFloat, font: UIFont, color: UIColor, y: inout CGFloat) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: paragraph]
        let attributed = NSAttributedString(string: text, attributes: attributes)
        let framesetter = attributed.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        attributed.draw(with: CGRect(x: x, y: y, width: width, height: framesetter.height), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        y += framesetter.height + 4
    }

    @MainActor
    static func generatePreface(daysTogether: Int, topTags: [String]) async -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), SystemLanguageModel.default.availability == .available {
            do {
                let session = LanguageModelSession(instructions: """
                    Write a 90-word warm preface for a couple's anniversary memory book. \
                    They have been together \(daysTogether) days and their conversations \
                    often touch on: \(topTags.prefix(5).joined(separator: ", ")). \
                    US English, second person plural, tender not saccharine.
                    """)
                let reply = try await session.respond(to: "Write the preface.")
                return reply.content
            } catch {}
        }
        #endif
        if let key = AIConfiguration.apiKey() {
            let system = "Write a 90-word warm preface for a couple's anniversary memory book. US English, second person plural."
            let user = "Days together: \(daysTogether). Themes: \(topTags.prefix(5).joined(separator: ", "))."
            if let text = await CloudAIService.chat(systemPrompt: system, userPrompt: user, apiKey: key) {
                return text
            }
        }
        return "Every question you answered became a small keepsake. Together for \(daysTogether) days, you kept choosing curiosity about each other — and these pages hold what that curiosity found. This book is proof: love is not one grand gesture, it is a thousand small answers."
    }
}
