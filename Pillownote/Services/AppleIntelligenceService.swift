import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

@available(iOS 26.0, *)
@Generable
struct DailySpark {
    @Guide(description: "A warm, specific question for a couple, max 120 characters, never yes/no")
    var question: String
    @Guide(description: "One of: fun, deep, future, intimacy, gratitude")
    var category: String
    @Guide(description: "Why this question fits this couple, max 80 chars, in second person")
    var reason: String
}

@available(iOS 26.0, *)
@Generable
struct CoachReply {
    @Guide(description: "A warm, specific reply to the couple, max 150 words, second person, never clinical")
    var reply: String
    @Guide(description: "Three theme tags describing the topic, lowercase, hyphenated")
    var tags: [String]
}

enum AppleIntelligenceStatus {
    static var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default.availability == .available
        }
        #endif
        return false
    }
}

struct SparkResult {
    let question: String
    let category: String
    let reason: String
    let source: QuestionSource
}

actor SparkGenerator {
    static let shared = SparkGenerator()
    private var history: [String] = []

    func todaySpark(daysTogether: Int, recentTags: [String], categoryHint: String?) async -> SparkResult {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), SystemLanguageModel.default.availability == .available {
            do {
                let session = LanguageModelSession(instructions: """
                    You are Pillownote's question designer. Create ONE fresh daily question \
                    for a couple. Use their recent themes to personalize. NEVER repeat any \
                    question in HISTORY. Tone: warm, curious, zero judgment. US English.
                    """)
                let hint = categoryHint.map { "Prefer the category: \($0). " } ?? ""
                let spark = try await session.respond(
                    to: """
                    \(hint)Recent shared themes: \(recentTags.joined(separator: ", ")).
                    Days together: \(daysTogether).
                    HISTORY (forbidden to repeat): \(history.suffix(200).joined(separator: " | "))
                    """,
                    generating: DailySpark.self
                )
                let content = spark.content
                history.append(content.question)
                return SparkResult(question: content.question, category: content.category, reason: content.reason, source: .onDeviceAI)
            } catch {
                return staticFallback(categoryHint: categoryHint)
            }
        }
        #endif
        return staticFallback(categoryHint: categoryHint)
    }

    private func staticFallback(categoryHint: String?) -> SparkResult {
        let bank: BankQuestion
        if let hint = categoryHint, let pick = StaticQuestionBank.byCategory(hint, excluding: history) {
            bank = pick
        } else {
            bank = StaticQuestionBank.nextUnasked(excluding: history)
        }
        history.append(bank.text)
        return SparkResult(question: bank.text, category: bank.category, reason: "From our curated deck — chosen for tonight.", source: .staticBank)
    }
}

struct DeepReply {
    let text: String
    let tags: [String]
    let usedCloud: Bool
}

enum CoachService {
    static func reply(to messages: [CoachMessage], digests: [MemoryDigest], deep: Bool) async -> DeepReply {
        let context = digestContext(digests)
        let transcript = messages.suffix(10).map { "\($0.isUser ? "User" : "Partner")+: \($0.text)" }.joined(separator: "\n")
        let systemPrompt = """
            You are Pillownote's relationship coach. Speak warmly, like a wise friend, US English, \
            second person plural ("you two"). Keep replies under 150 words. You know this couple's \
            recent shared themes: \(context). Never give medical advice.
            """

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), SystemLanguageModel.default.availability == .available, !deep {
            do {
                let session = LanguageModelSession(instructions: systemPrompt)
                let result = try await session.respond(to: transcript, generating: CoachReply.self)
                return DeepReply(text: result.content.reply, tags: result.content.tags, usedCloud: false)
            } catch {
                return DeepReply(text: onDeviceFallback(transcript: transcript), tags: [], usedCloud: false)
            }
        }
        #endif

        if deep, let key = AIConfiguration.apiKey() {
            if let text = await CloudAIService.chat(systemPrompt: systemPrompt, userPrompt: transcript, apiKey: key) {
                return DeepReply(text: text, tags: [], usedCloud: true)
            }
        }

        return DeepReply(text: onDeviceFallback(transcript: transcript), tags: [], usedCloud: false)
    }

    static func digestContext(_ digests: [MemoryDigest]) -> String {
        let recent = digests.suffix(30)
        let tags = recent.flatMap(\.tags).uniqued().prefix(12).joined(separator: ", ")
        return tags.isEmpty ? "no stored themes yet" : tags
    }

    private static func onDeviceFallback(transcript: String) -> String {
        let starters = [
            "Here's what stands out: the themes you two keep returning to are worth a real conversation tonight.",
            "A gentle nudge: pick one thing from this week that felt good and tell each other why.",
            "Every couple has rhythms. Naming yours out loud is already the hard part — you're doing it.",
            "Try this tonight: each name one moment from this week you'd relive. See what overlaps."
        ]
        return starters.randomElement() ?? starters[0]
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
