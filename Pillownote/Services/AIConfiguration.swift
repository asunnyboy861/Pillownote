import Foundation

struct AIProviderProfile: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var endpoint: String
    var model: String

    static let presets: [AIProviderProfile] = [
        AIProviderProfile(name: "Z.ai (GLM)", endpoint: "https://api.z.ai/api/paas/v4/chat/completions", model: "glm-5.3-flash"),
        AIProviderProfile(name: "BigModel (GLM)", endpoint: "https://open.bigmodel.cn/api/paas/v4/chat/completions", model: "glm-5.3-flash"),
        AIProviderProfile(name: "GPT-4o", endpoint: "https://api.openai.com/v1/chat/completions", model: "gpt-4o-mini")
    ]
}

enum AIConfiguration {
    static let keychainService = "com.zzoutuo.Pillownote.ai"

    static func saveAPIKey(_ key: String) {
        KeychainHelper.saveString(key, service: keychainService, account: "byo-api-key")
    }

    static func apiKey() -> String? {
        let key = KeychainHelper.readString(service: keychainService, account: "byo-api-key")
        return (key?.isEmpty == false) ? key : nil
    }

    static func deleteAPIKey() {
        KeychainHelper.delete(service: keychainService, account: "byo-api-key")
    }

    static func saveProfile(_ profile: AIProviderProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: "ai.provider.profile")
        }
    }

    static func profile() -> AIProviderProfile {
        if let data = UserDefaults.standard.data(forKey: "ai.provider.profile"),
           let profile = try? JSONDecoder().decode(AIProviderProfile.self, from: data) {
            return profile
        }
        return AIProviderProfile.presets[0]
    }

    static var hasAPIKey: Bool { apiKey() != nil }
}
