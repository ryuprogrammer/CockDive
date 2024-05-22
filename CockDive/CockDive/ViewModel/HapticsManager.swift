import SwiftUI
import CoreHaptics

class HapticsManager: ObservableObject {
    private var engine: CHHapticEngine?

    init() {
        prepareHaptics()
    }

    private func prepareHaptics() {
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics not available on device: \(error.localizedDescription)")
        }
    }

    func playHapticPattern() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)

        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error.localizedDescription)")
        }
    }
}
