import SwiftUI

struct AIConfigurationView: View {
    @State private var apiKey = ""
    @State private var profile = AIConfiguration.profile()
    @State private var saved = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: AppleIntelligenceStatus.isAvailable ? "checkmark.seal.fill" : "cpu")
                        .foregroundStyle(AppleIntelligenceStatus.isAvailable ? Theme.sage : .secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Apple Intelligence")
                            .font(.subheadline.weight(.semibold))
                        Text(AppleIntelligenceStatus.isAvailable ? "Active — your coach runs on-device, free and private." : "Requires iPhone 15 Pro or newer with iOS 26+.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Default engine")
            } footer: {
                Text("No key needed when Apple Intelligence is available.")
            }

            Section {
                SecureField("Your API key", text: $apiKey)
                Picker("Provider", selection: $profile) {
                    ForEach(AIProviderProfile.presets, id: \.self) { preset in
                        Text(preset.name).tag(preset)
                    }
                }
                if !profile.endpoint.isEmpty && !AIProviderProfile.presets.contains(profile) {
                    Text(profile.endpoint)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Button("Save key") {
                        AIConfiguration.saveAPIKey(apiKey)
                        AIConfiguration.saveProfile(profile)
                        saved = true
                        apiKey = ""
                    }
                    .disabled(apiKey.trimmingCharacters(in: .whitespaces).isEmpty)
                    Spacer()
                    if AIConfiguration.hasAPIKey {
                        Button("Remove", role: .destructive) {
                            AIConfiguration.deleteAPIKey()
                        }
                    }
                }
                if saved {
                    Label("Saved to your Keychain", systemImage: "lock.checkmark")
                        .font(.caption)
                        .foregroundStyle(Theme.sage)
                }
            } header: {
                Text("Bring your own key")
            } footer: {
                Text("Your key is stored only in your device Keychain and sent only to the provider you choose. Get a key at z.ai or bigmodel.cn, or use any compatible API endpoint.")
            }
        }
        .navigationTitle("AI Configuration")
        .navigationBarTitleDisplayMode(.inline)
    }
}
