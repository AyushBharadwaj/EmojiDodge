import AudioToolbox
import Foundation

protocol AudioService: AnyObject {
    func startGameplayAmbience()
    func stopGameplayAmbience()
    func playCollision()
}

/// Uses iOS system sounds — short one-shots. "Ambience" is a low-rate periodic tick.
final class SystemSoundAudioService: AudioService {
    /// Seconds between subtle ticks while playing.
    private let tickInterval: TimeInterval = 2.2
    private var ambienceTimer: Timer?

    func startGameplayAmbience() {
        stopGameplayAmbience()
        let timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            AudioServicesPlaySystemSound(SystemSounds.gameplayTick.rawValue)
        }
        RunLoop.main.add(timer, forMode: .common)
        ambienceTimer = timer
    }

    func stopGameplayAmbience() {
        ambienceTimer?.invalidate()
        ambienceTimer = nil
    }

    func playCollision() {
        AudioServicesPlaySystemSound(SystemSounds.collision.rawValue)
    }

    deinit {
        stopGameplayAmbience()
    }
}
