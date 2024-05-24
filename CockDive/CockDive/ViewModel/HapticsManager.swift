import SwiftUI
import CoreHaptics

class HapticsManager: ObservableObject {
    private var engine: CHHapticEngine?

    // 初期化時にハプティクスの準備と通知のセットアップを行う
    init() {
        prepareHaptics()
        setupObservers()
    }

    // ハプティクスエンジンを準備するメソッド
    private func prepareHaptics() {
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics not available on device: \(error.localizedDescription)")
        }
    }

    // ハプティクスエンジンを再起動するメソッド
    private func restartHaptics() {
        do {
            try engine?.start()
        } catch {
            print("Failed to restart haptic engine: \(error.localizedDescription)")
        }
    }

    // アプリのライフサイクルイベントを監視するための通知をセットアップ
    private func setupObservers() {
        // フォアグラウンドに入るときに通知を受け取る
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        // バックグラウンドに入るときに通知を受け取る
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    // アプリがフォアグラウンドに戻るときに呼ばれるメソッド
    @objc private func willEnterForeground() {
        restartHaptics()
    }

    // アプリがバックグラウンドに入るときに呼ばれるメソッド
    @objc private func didEnterBackground() {
        engine?.stop()
    }

    // ハプティクスパターンを再生するメソッド
    func playHapticPattern() {
        // デバイスがハプティクスをサポートしているか確認
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        // ハプティクスイベントのパラメータを設定
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)

        // ハプティクスイベントを作成
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)

        do {
            // ハプティクスパターンを作成
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            // パターンを再生するプレーヤーを作成
            let player = try engine?.makePlayer(with: pattern)
            // ハプティクスを再生
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error.localizedDescription)")
        }
    }
}
