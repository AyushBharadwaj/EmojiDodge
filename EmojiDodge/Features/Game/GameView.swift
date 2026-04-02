import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(PlayerCustomization.appStorageKey) private var storedPlayerEmoji = PlayerCustomization.defaultEmoji

    @GestureState private var isDraggingPlayfield = false
    @State private var screenEntered = false
    @State private var impactFlashOpacity: CGFloat = 0
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                GradientBackground(palette: AppTheme.playfieldBackgroundGradient(for:))

                playfieldStack(size: geo.size)
                    .contentShape(Rectangle())
                    .gesture(dragGesture)
                    .offset(x: shakeOffset)

                impactFlashLayer

                VStack {
                    ScoreHUD(
                        seconds: viewModel.scoreSeconds,
                        emojiScore: viewModel.emojiScore,
                        allTimeHighScore: viewModel.allTimeHighScore
                    )
                        .padding(.top, AppTheme.Spacing.s)
                    Spacer()
                }
                .allowsHitTesting(false)

                if viewModel.phase == .gameOver {
                    gameOverLayer
                        .transition(.opacity.combined(with: .scale(scale: 0.94)))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear {
                viewModel.updatePlayfieldSize(geo.size)
                viewModel.onAppear()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                    screenEntered = true
                }
            }
            .onChange(of: geo.size) { _, new in
                viewModel.updatePlayfieldSize(new)
            }
            .scaleEffect(screenEntered ? 1 : 0.97)
            .opacity(screenEntered ? 1 : 0)
        }
        .ignoresSafeArea(edges: .bottom)
        .onDisappear {
            viewModel.onDisappear()
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: viewModel.phase)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                GameNavBackButton { dismiss() }
            }
        }
        .onChange(of: viewModel.phase) { _, phase in
            guard phase == .gameOver else {
                shakeOffset = 0
                return
            }
            HapticFeedback.medium()
            var flashIn = Transaction()
            flashIn.disablesAnimations = true
            withTransaction(flashIn) {
                impactFlashOpacity = 0.62
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeOut(duration: 0.3)) {
                    impactFlashOpacity = 0
                }
            }
            withAnimation(.easeInOut(duration: 0.055).repeatCount(9, autoreverses: true)) {
                shakeOffset = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.52) {
                var t = Transaction()
                t.disablesAnimations = true
                withTransaction(t) {
                    shakeOffset = 0
                }
            }
        }
    }

    private var impactFlashLayer: some View {
        AppTheme.impactFlashColor(for: colorScheme)
            .opacity(impactFlashOpacity)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }

    private func playfieldStack(size: CGSize) -> some View {
        let emojiChar = PlayerCustomization.displayEmoji(stored: storedPlayerEmoji)
        return ZStack {
            ForEach(viewModel.fallingEmojis) { emoji in
                FallingEmojiSprite(emoji: emoji)
                    .position(x: emoji.centerX, y: emoji.centerY)
            }

            Text(emojiChar)
                .font(.system(size: GameConfig.playerSize * GameConfig.playerGlyphFontScale))
                .shadow(color: AppTheme.hudAccent(for: colorScheme).opacity(0.5), radius: 10, y: 3)
                .scaleEffect(isDraggingPlayfield ? 1.08 : 1)
                .animation(.spring(response: 0.22, dampingFraction: 0.55), value: isDraggingPlayfield)
                .position(x: viewModel.playerCenterX, y: viewModel.playerCenterY)
                .animation(.interactiveSpring(response: 0.12, dampingFraction: 0.72), value: viewModel.playerCenterX)
                .animation(.interactiveSpring(response: 0.12, dampingFraction: 0.72), value: viewModel.playerCenterY)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($isDraggingPlayfield) { _, state, _ in
                state = true
            }
            .onChanged { value in
                viewModel.dragChanged(
                    translationWidth: value.translation.width,
                    translationHeight: value.translation.height
                )
            }
            .onEnded { _ in
                viewModel.dragEnded()
            }
    }

    private var gameOverLayer: some View {
        ZStack {
            Color.black.opacity(colorScheme == .dark ? 0.5 : 0.28)
                .ignoresSafeArea()

            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .opacity(0.92)

            GlassCard(cornerRadius: AppTheme.Corner.card) {
                GameOverPanel(
                    scoreSeconds: viewModel.scoreSeconds,
                    emojiScore: viewModel.emojiScore,
                    allTimeHighScore: viewModel.allTimeHighScore,
                    isNewHighScoreThisRun: viewModel.isNewHighScoreThisRun,
                    onPlayAgain: { viewModel.restart() },
                    onHome: { dismiss() }
                )
            }
            .padding(.horizontal, AppTheme.Spacing.l)
        }
    }
}

// MARK: - Falling emoji (visual-only motion; hit testing unchanged in ViewModel)

private struct FallingEmojiSprite: View {
    let emoji: FallingEmoji

    @State private var spawnPop = false

    /// Visual-only spin derived from position; font scale matches `GameConfig.fallingEmojiGlyphFontScale` for collision.
    private var spin: Double {
        Double(emoji.centerX) * 0.12 + Double(emoji.centerY) * 0.35
    }

    private var depthShadow: CGFloat {
        min(emoji.size * 0.08, 6)
    }

    var body: some View {
        Text(emoji.character)
            .font(.system(size: emoji.size * GameConfig.fallingEmojiGlyphFontScale))
            .rotationEffect(.degrees(spin.truncatingRemainder(dividingBy: 360.0)))
            .shadow(color: .black.opacity(0.22), radius: depthShadow, y: depthShadow * 0.6)
            .scaleEffect(spawnPop ? 1 : 0.15)
            .opacity(spawnPop ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.62)) {
                    spawnPop = true
                }
            }
    }
}

#Preview {
    NavigationStack {
        GameView()
    }
}
