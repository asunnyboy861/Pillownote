import Foundation
import SwiftData

enum QuestionSource: String, Codable {
    case onDeviceAI, cloudAI, staticBank
}

enum NoteKind: String, Codable {
    case text, voice, photo
}

@Model
final class Question {
    var id: UUID = UUID()
    var text: String = ""
    var category: String = "fun"
    var sourceRaw: String = QuestionSource.staticBank.rawValue
    var myAnswerText: String?
    var myAnswerAudioPath: String?
    var partnerAnswerText: String?
    var partnerAnswerEncrypted: Data?
    var assignedUTC: Date = Date()
    var myTZ: String = ""
    var partnerTZ: String = ""
    var revealedAt: Date?

    var isAnsweredByMe: Bool { myAnswerText != nil || myAnswerAudioPath != nil }
    var isAnsweredByPartner: Bool { partnerAnswerText != nil || partnerAnswerEncrypted != nil }
    var bothAnswered: Bool { isAnsweredByMe && isAnsweredByPartner }
    var isRevealed: Bool { revealedAt != nil }

    init(text: String, category: String, source: QuestionSource = .staticBank, assignedUTC: Date = Date()) {
        self.id = UUID()
        self.text = text
        self.category = category
        self.sourceRaw = source.rawValue
        self.assignedUTC = assignedUTC
        self.myTZ = TimeZone.current.identifier
    }
}

@Model
final class PillowNote {
    var id: UUID = UUID()
    var kindRaw: String = NoteKind.text.rawValue
    var bodyText: String = ""
    var bodyEncrypted: Data?
    var transcript: String?
    var photoData: Data?
    var voicePath: String?
    var voiceDuration: TimeInterval = 0
    var createdInTZ: String = ""
    var createdUTC: Date = Date()
    var unlockAtUTC: Date = Date()
    var openedAt: Date?
    var reaction: String?

    var kind: NoteKind { NoteKind(rawValue: kindRaw) ?? .text }
    var isIncoming: Bool = false
    var isMine: Bool { !isIncoming }
    var isUnlocked: Bool { Date() >= unlockAtUTC }

    init(kind: NoteKind, bodyText: String = "", transcript: String? = nil, photoData: Data? = nil, voicePath: String? = nil, voiceDuration: TimeInterval = 0, unlockAt: Date, isIncoming: Bool = false) {
        self.id = UUID()
        self.kindRaw = kind.rawValue
        self.bodyText = bodyText
        self.transcript = transcript
        self.photoData = photoData
        self.voicePath = voicePath
        self.voiceDuration = voiceDuration
        self.createdInTZ = TimeZone.current.identifier
        self.createdUTC = Date()
        self.unlockAtUTC = unlockAt
        self.isIncoming = isIncoming
    }
}

@Model
final class MemoryDigest {
    var day: Date = Date()
    var tags: [String] = []
    var valence: Double = 0
    var highlight: String = ""
    var uploadedConsent: Bool = false

    init(day: Date = Date(), tags: [String], valence: Double, highlight: String) {
        self.day = day
        self.tags = tags
        self.valence = valence
        self.highlight = highlight
    }
}

@Model
final class GlowReport {
    var id: UUID = UUID()
    var periodStart: Date = Date()
    var isMonthly: Bool = false
    var resonanceCount: Int = 0
    var topTags: [String] = []
    var sweetestQuote: String = ""
    var insight: String = ""
    var valenceAvg: Double = 0
    var createdAt: Date = Date()

    init(periodStart: Date, isMonthly: Bool, resonanceCount: Int, topTags: [String], sweetestQuote: String, insight: String, valenceAvg: Double) {
        self.id = UUID()
        self.periodStart = periodStart
        self.isMonthly = isMonthly
        self.resonanceCount = resonanceCount
        self.topTags = topTags
        self.sweetestQuote = sweetestQuote
        self.insight = insight
        self.valenceAvg = valenceAvg
        self.createdAt = Date()
    }
}

@Model
final class CoachMessage {
    var id: UUID = UUID()
    var roleRaw: String = "user"
    var text: String = ""
    var createdAt: Date = Date()
    var usedDeep: Bool = false

    var isUser: Bool { roleRaw == "user" }

    init(role: String, text: String, usedDeep: Bool = false) {
        self.id = UUID()
        self.roleRaw = role
        self.text = text
        self.usedDeep = usedDeep
        self.createdAt = Date()
    }
}

@Model
final class CoupleProfile {
    var id: UUID = UUID()
    var pairingCode: String?
    var partnerName: String = "My Love"
    var anniversaryDate: Date?
    var reunionDate: Date?
    var relationshipStage: String = "same-city"
    var partnerTZ: String = ""
    var isPartnerA: Bool = true
    var demoPartnerEnabled: Bool = false
    var onboarded: Bool = false
    var digestUploadConsent: Bool = false
    var createdAt: Date = Date()

    init() {}
}
