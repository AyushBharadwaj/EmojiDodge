import CoreGraphics
import Foundation

// MARK: - Phase

enum GamePhase: Equatable {
    case idle
    case playing
    case gameOver
}

// MARK: - Entities

struct FallingEmoji: Identifiable, Equatable {
    let id: UUID
    var character: String
    /// Horizontal center in playfield coordinates.
    var centerX: CGFloat
    /// Vertical center in playfield coordinates (origin top-left).
    var centerY: CGFloat
    var size: CGFloat
    var velocityY: CGFloat
}

// MARK: - Config

enum GameConfig {
    /// Layout / clamp radius for the player (center stays inside playfield with this half-extent).
    static let playerSize: CGFloat = 72
    /// Player emoji font scale; **collision AABB uses this** so hits match the drawn glyph, not the full layout square.
    static let playerGlyphFontScale: CGFloat = 0.82
    /// Falling emoji font scale in `FallingEmojiSprite`; **collision AABB uses this** vs raw `emoji.size`.
    static let fallingEmojiGlyphFontScale: CGFloat = 0.88
    /// Default vertical position: player center distance from bottom when a round starts.
    static let playerBottomInset: CGFloat = 110
    /// Minimum space from top of playfield to player center (stay below HUD area).
    static let playerTopSafeMargin: CGFloat = 96
    /// Minimum space from bottom edge to player center.
    static let playerBottomSafeMargin: CGFloat = 36
    static let spawnInterval: TimeInterval = 0.55
    static let baseFallSpeed: CGFloat = 220
    static let speedRampPerSecond: CGFloat = 8
    static let horizontalPadding: CGFloat = 12
    static let emojiStrings = ["😀", "😎", "🎉", "⭐️", "🔥", "💥", "🍎", "🚀"]
}

// MARK: - All-time high score (emoji dodge count per run)

enum HighScorePersistence {
    static let userDefaultsKey = "emojiDodge.allTimeHighEmojiScore"

    static func load() -> Int {
        UserDefaults.standard.integer(forKey: userDefaultsKey)
    }

    /// Persists if `score` beats the saved best. Returns `true` when this run is a new record.
    @discardableResult
    static func recordEndOfRun(score: Int) -> Bool {
        let best = load()
        guard score > best else { return false }
        UserDefaults.standard.set(score, forKey: userDefaultsKey)
        return true
    }
}

// MARK: - Player appearance (persisted)

enum PlayerCustomization {
    static let appStorageKey = "emojiDodge.playerEmoji"
    static let defaultEmoji = "🛡️"
    /// Presets shown on the home screen; first is default.
    static let pickerEmojis = ["🛡️", "🦸‍♀️", "🚀", "🐱", "🦄", "⭐️", "💎", "🔮", "🤖", "🐸", "🦊", "👾"]

    static func displayEmoji(stored: String) -> String {
        let t = stored.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? defaultEmoji : t
    }
}

// MARK: - System sound IDs (AudioServicesPlaySystemSound)

/// Apple documents many IDs informally; values are tunable per device feel.
enum SystemSounds: UInt32 {
    /// Soft periodic tick during gameplay.
    case gameplayTick = 1104
    /// Distinct hit / game over cue.
    case collision = 1052
}
