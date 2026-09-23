import Foundation
import NaturalLanguage

enum MemoryService {
    private static let stopWords: Set<String> = [
        "the", "and", "you", "your", "with", "that", "this", "have", "what", "when", "would", "about",
        "just", "like", "really", "feel", "think", "because", "them", "they", "were", "from", "there",
        "some", "more", "very", "much", "been", "into", "will", "does", "did", "then", "than", "make"
    ]

    static func extractDigest(from answer: String, existing: [MemoryDigest]) -> MemoryDigest {
        let tags = tags(for: answer)
        let valence = valence(for: answer)
        let highlight = highlightSentence(from: answer)
        return MemoryDigest(day: Date(), tags: tags, valence: valence, highlight: highlight)
    }

    static func tags(for text: String) -> [String] {
        var words: [String] = []
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: [.omitPunctuation, .omitWhitespace]) { tag, range in
            if tag == .noun {
                let word = String(text[range]).lowercased()
                if word.count > 2 && !stopWords.contains(word) {
                    words.append(word)
                }
            }
            return true
        }
        var counts: [String: Int] = [:]
        words.forEach { counts[$0, default: 0] += 1 }
        return counts.sorted { $0.value > $1.value }.prefix(4).map(\.key)
    }

    static func valence(for text: String) -> Double {
        let positive = ["love", "happy", "great", "wonderful", "excited", "grateful", "joy", "sweet", "beautiful", "amazing", "good", "hope", "smile", "laugh"]
        let negative = ["sad", "tired", "angry", "stressed", "worried", "anxious", "hurt", "lonely", "afraid", "hard", "fight", "upset"]
        let lower = text.lowercased()
        var score = 0
        positive.forEach { if lower.contains($0) { score += 1 } }
        negative.forEach { if lower.contains($0) { score -= 1 } }
        return Double(max(-3, min(3, score))) / 3.0
    }

    static func highlightSentence(from text: String) -> String {
        let sentences = text.split(separator: ".").map { $0.trimmingCharacters(in: .whitespaces) }
        return sentences.max(by: { $0.count < $1.count }).map { String($0.prefix(140)) } ?? String(text.prefix(140))
    }

    static func weeklySummary(digests: [MemoryDigest]) -> (resonance: Int, topTags: [String], sweetest: String, valenceAvg: Double) {
        let week = digests.filter { $0.day > Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date() }
        var counts: [String: Int] = [:]
        week.forEach { d in d.tags.forEach { counts[$0, default: 0] += 1 } }
        let topTags = counts.sorted { $0.value > $1.value }.prefix(5).map(\.key)
        let sweetest = week.max(by: { $0.highlight.count < $1.highlight.count })?.highlight ?? ""
        let valenceAvg = week.isEmpty ? 0 : week.map(\.valence).reduce(0, +) / Double(week.count)
        return (week.count, Array(topTags), sweetest, valenceAvg)
    }
}
