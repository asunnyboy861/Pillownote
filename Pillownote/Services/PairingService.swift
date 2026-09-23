import Foundation
import CloudKit
import SwiftData

@MainActor
final class PairingService: ObservableObject {
    static let shared = PairingService()

    @Published var cloudAvailable = false

    private let container = CKContainer(identifier: "iCloud.com.zzoutuo.Pillownote")
    private let recordType = "PairingCode"

    func checkCloudAvailability() async {
        let status = try? await container.accountStatus()
        cloudAvailable = status == .available
    }

    func publishCode(_ code: String, partnerName: String) async -> Bool {
        guard cloudAvailable else { return false }
        let db = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: "pairing-\(code)")
        let record = CKRecord(recordType: recordType, recordID: recordID)
        record["code"] = code as CKRecordValue
        record["partnerName"] = partnerName as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        do {
            _ = try await db.save(record)
            return true
        } catch {
            return false
        }
    }

    func lookupPartnerName(for code: String) async -> String? {
        guard cloudAvailable else { return nil }
        let db = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: "pairing-\(code)")
        do {
            let record = try await db.record(for: recordID)
            return record["partnerName"] as? String
        } catch {
            return nil
        }
    }

    static func generateCode() -> String {
        String(format: "%06d", Int.random(in: 0...999999))
    }
}

@MainActor
final class DemoPartner: ObservableObject {
    static let shared = DemoPartner()

    func schedulePartnerAnswer(for question: Question, context: ModelContext) {
        guard question.isAnsweredByMe, !question.isAnsweredByPartner else { return }
        let questionID = question.id
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(8))
            var descriptor = FetchDescriptor<Question>(predicate: #Predicate { $0.id == questionID })
            descriptor.fetchLimit = 1
            if let question = try? context.fetch(descriptor).first, !question.isAnsweredByPartner {
                let answers = [
                    "Okay this question got me — my answer is you, obviously.",
                    "I've been thinking about this all day. The answer is the beach, at sunset, with you.",
                    "Honestly? The moment you texted me good morning today.",
                    "I'd choose the same answer every time: wherever you are.",
                    "This one's easy — you make ordinary days feel like holidays."
                ]
                question.partnerAnswerText = answers.randomElement() ?? answers[0]
                question.partnerTZ = TimeZone.current.identifier
                try? context.save()
                WidgetUpdater.update(context: context)
            }
        }
    }
}

enum WidgetUpdater {
    static func update(context: ModelContext) {
        let profile = fetchProfile(context: context)
        var snapshot = WidgetSnapshot()
        if let anniversary = profile?.anniversaryDate {
            snapshot.daysTogether = Calendar.current.dateComponents([.day], from: anniversary, to: Date()).day ?? 0
        }
        if let reunion = profile?.reunionDate, reunion > Date() {
            snapshot.reunionDays = Calendar.current.dateComponents([.day], from: Date(), to: reunion).day
        }
        let questionDescriptor = FetchDescriptor<Question>(sortBy: [SortDescriptor(\.assignedUTC, order: .reverse)])
        if let latest = try? context.fetch(questionDescriptor).first {
            snapshot.todayQuestion = latest.text
            snapshot.partnerMood = latest.partnerAnswerText != nil ? "answered" : nil
        }
        if let profile {
            snapshot.partnerName = profile.partnerName
        }
        WidgetSharedStore.save(snapshot)
    }

    static func fetchProfile(context: ModelContext) -> CoupleProfile? {
        var descriptor = FetchDescriptor<CoupleProfile>()
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }
}
