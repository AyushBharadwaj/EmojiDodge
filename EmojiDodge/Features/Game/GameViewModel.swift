import CoreGraphics
import SwiftUI

final class GameViewModel: ObservableObject {
    @Published private(set) var phase: GamePhase = .idle
    @Published private(set) var fallingEmojis: [FallingEmoji] = []
    @Published private(set) var playerCenterX: CGFloat = 0
    @Published private(set) var playerCenterY: CGFloat = 0
    @Published private(set) var scoreSeconds: Int = 0
    /// Run score: emojis that exited the bottom without colliding (shown as "Score" in UI).
    @Published private(set) var emojiScore: Int = 0
    /// Best `emojiScore` from any completed run (UserDefaults).
    @Published private(set) var allTimeHighScore: Int = HighScorePersistence.load()
    /// Whether the last game over set a new all-time best.
    @Published private(set) var isNewHighScoreThisRun: Bool = false

    private var playfieldSize: CGSize = .zero
    private var gameStartDate: Date?
    private var spawnAccumulator: TimeInterval = 0
    private var isDragging = false
    private var dragStartPlayerX: CGFloat = 0
    private var dragStartPlayerY: CGFloat = 0

    private let loop = GameLoopController()
    private let audio: AudioService

    init(audio: AudioService = SystemSoundAudioService()) {
        self.audio = audio
    }

    func updatePlayfieldSize(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let wasEmpty = playfieldSize == .zero
        playfieldSize = size
        if wasEmpty {
            playerCenterX = size.width / 2
            playerCenterY = defaultPlayerCenterY(inHeight: size.height)
        } else {
            clampPlayerToPlayfield()
        }
    }

    func onAppear() {
        if phase == .idle {
            startRound()
        }
    }

    func onDisappear() {
        pauseSession()
    }

    func startRound() {
        pauseSession()
        phase = .playing
        gameStartDate = Date()
        fallingEmojis = []
        spawnAccumulator = 0
        scoreSeconds = 0
        emojiScore = 0
        isNewHighScoreThisRun = false
        allTimeHighScore = HighScorePersistence.load()
        if playfieldSize.width > 0, playfieldSize.height > 0 {
            playerCenterX = playfieldSize.width / 2
            playerCenterY = defaultPlayerCenterY(inHeight: playfieldSize.height)
            clampPlayerToPlayfield()
        }
        loop.onTick = { [weak self] dt in self?.tick(dt: dt) }
        loop.start()
        audio.startGameplayAmbience()
    }

    func restart() {
        startRound()
    }

    private func pauseSession() {
        loop.stop()
        loop.onTick = nil
        audio.stopGameplayAmbience()
    }

    func dragChanged(translationWidth: CGFloat, translationHeight: CGFloat) {
        guard phase == .playing else { return }
        if !isDragging {
            dragStartPlayerX = playerCenterX
            dragStartPlayerY = playerCenterY
            isDragging = true
        }
        let h = playfieldSize.height
        let w = playfieldSize.width
        guard w > 0, h > 0 else { return }

        let half = GameConfig.playerSize / 2
        let minX = half + GameConfig.horizontalPadding
        let maxX = max(minX, w - half - GameConfig.horizontalPadding)
        let (minY, maxY) = verticalCenterYBounds(playfieldHeight: h)

        playerCenterX = min(max(dragStartPlayerX + translationWidth, minX), maxX)
        playerCenterY = min(max(dragStartPlayerY + translationHeight, minY), maxY)
    }

    func dragEnded() {
        isDragging = false
    }

    private func defaultPlayerCenterY(inHeight h: CGFloat) -> CGFloat {
        h - GameConfig.playerBottomInset
    }

    /// Valid range for player **center** Y (playfield coordinates).
    private func verticalCenterYBounds(playfieldHeight h: CGFloat) -> (CGFloat, CGFloat) {
        let half = GameConfig.playerSize / 2
        var minY = half + GameConfig.playerTopSafeMargin
        var maxY = h - half - GameConfig.playerBottomSafeMargin
        if minY > maxY {
            let mid = h / 2
            return (mid, mid)
        }
        return (minY, maxY)
    }

    private func clampPlayerToPlayfield() {
        let w = playfieldSize.width
        let h = playfieldSize.height
        guard w > 0, h > 0 else { return }
        let half = GameConfig.playerSize / 2
        let minX = half + GameConfig.horizontalPadding
        let maxX = max(minX, w - half - GameConfig.horizontalPadding)
        let (minY, maxY) = verticalCenterYBounds(playfieldHeight: h)
        playerCenterX = min(max(playerCenterX, minX), maxX)
        playerCenterY = min(max(playerCenterY, minY), maxY)
    }

    private func tick(dt: TimeInterval) {
        guard phase == .playing, let start = gameStartDate else { return }

        scoreSeconds = Int(floor(Date().timeIntervalSince(start)))

        let w = playfieldSize.width
        let h = playfieldSize.height
        guard w > 0, h > 0 else { return }

        let ramp = CGFloat(scoreSeconds) * GameConfig.speedRampPerSecond

        var emojis = fallingEmojis
        for i in emojis.indices {
            let speed = emojis[i].velocityY + ramp
            emojis[i].centerY += speed * CGFloat(dt)
        }
        let beforeCount = emojis.count
        emojis.removeAll { $0.centerY - $0.size / 2 > h + 40 }
        let cleared = beforeCount - emojis.count
        if cleared > 0 {
            emojiScore += cleared
        }

        spawnAccumulator += dt
        while spawnAccumulator >= GameConfig.spawnInterval {
            spawnAccumulator -= GameConfig.spawnInterval
            emojis.append(makeSpawnedEmoji(width: w))
        }

        fallingEmojis = emojis

        if checkCollision() {
            triggerGameOver()
        }
    }

    private func makeSpawnedEmoji(width: CGFloat) -> FallingEmoji {
        let size = CGFloat.random(in: 36 ... 52)
        let half = size / 2
        let minX = half + GameConfig.horizontalPadding
        let maxX = width - half - GameConfig.horizontalPadding
        let x = CGFloat.random(in: minX ... maxX)
        let y = -half
        let char = GameConfig.emojiStrings.randomElement() ?? "😀"
        let base = GameConfig.baseFallSpeed + CGFloat.random(in: -20 ... 80)
        return FallingEmoji(
            id: UUID(),
            character: char,
            centerX: x,
            centerY: y,
            size: size,
            velocityY: base
        )
    }

    /// Axis-aligned bounds that match the **rendered** player emoji (edge-to-edge with falling emoji bounds below).
    private func playerCollisionBounds() -> CGRect {
        let side = GameConfig.playerSize * GameConfig.playerGlyphFontScale
        return CGRect(
            x: playerCenterX - side / 2,
            y: playerCenterY - side / 2,
            width: side,
            height: side
        )
    }

    /// Axis-aligned bounds that match the **rendered** falling emoji glyph (same center as the view).
    private func fallingEmojiCollisionBounds(_ emoji: FallingEmoji) -> CGRect {
        let side = emoji.size * GameConfig.fallingEmojiGlyphFontScale
        return CGRect(
            x: emoji.centerX - side / 2,
            y: emoji.centerY - side / 2,
            width: side,
            height: side
        )
    }

    private func checkCollision() -> Bool {
        let playerRect = playerCollisionBounds()
        return fallingEmojis.contains { fallingEmojiCollisionBounds($0).intersects(playerRect) }
    }

    private func triggerGameOver() {
        guard phase == .playing else { return }
        isNewHighScoreThisRun = HighScorePersistence.recordEndOfRun(score: emojiScore)
        allTimeHighScore = HighScorePersistence.load()
        phase = .gameOver
        loop.stop()
        loop.onTick = nil
        audio.stopGameplayAmbience()
        audio.playCollision()
    }
}
