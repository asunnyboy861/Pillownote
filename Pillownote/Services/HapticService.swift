import Foundation
import CoreHaptics
import UIKit

enum HapticService {
    private static var engine: CHHapticEngine?

    static func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        engine = try? CHHapticEngine()
        engine?.resetHandler = { try? engine?.start() }
        try? engine?.start()
    }

    static func heartbeat() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.7)
        }
    }

    static func tearOpen() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.6)
    }

    static func reveal() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
