import SwiftUI

// MARK: - Full-screen gradient

struct GradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    var palette: (ColorScheme) -> [Color]

    var body: some View {
        LinearGradient(
            colors: palette(colorScheme),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Glass / neumorphic-style panel

struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = AppTheme.Corner.card
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(AppTheme.Spacing.l)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.06)
                                    : Color.white.opacity(0.45)
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(colorScheme == .dark ? 0.25 : 0.7),
                                        Color.white.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.12), radius: 24, y: 12)
            }
    }
}

// MARK: - Score HUD

struct ScoreHUD: View {
    @Environment(\.colorScheme) private var colorScheme
    let seconds: Int
    let emojiScore: Int
    let allTimeHighScore: Int

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                hudStatBlock(
                    icon: "timer",
                    label: "Time",
                    value: "\(seconds)",
                    suffix: "s"
                )

                Rectangle()
                    .fill(Color.primary.opacity(0.12))
                    .frame(width: 1, height: 36)
                    .padding(.horizontal, AppTheme.Spacing.s)

                hudStatBlock(
                    icon: "star.circle.fill",
                    label: "Score",
                    value: "\(emojiScore)",
                    suffix: nil
                )
            }
            .padding(.horizontal, AppTheme.Spacing.m)
            .padding(.vertical, AppTheme.Spacing.s + 2)
            .background {
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    }
                    .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
            }

            HStack(spacing: 6) {
                Image(systemName: "trophy.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.hudAccent(for: colorScheme))
                Text("All-time best")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Text("\(allTimeHighScore)")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.m)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Time \(seconds) seconds, score \(emojiScore), all-time best \(allTimeHighScore)")
    }

    private func hudStatBlock(icon: String, label: String, value: String, suffix: String?) -> some View {
        HStack(spacing: AppTheme.Spacing.s) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.hudAccent(for: colorScheme))
                .frame(width: 22, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(.title3, design: .rounded).weight(.bold).monospacedDigit())
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                    if let suffix {
                        Text(suffix)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Game navigation (custom back)

struct GameNavBackButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let action: () -> Void

    var body: some View {
        Button {
            HapticFeedback.light()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.subheadline.weight(.bold))
                Text("Home")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(colorScheme == .dark ? 0.22 : 0.55),
                                        Color.primary.opacity(0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.1), radius: 10, y: 4)
            }
        }
        .buttonStyle(PressScaleButtonStyle(pressedScale: 0.94))
        .accessibilityLabel("Back to home")
    }
}

// MARK: - Player emoji (home customization)

struct PlayerPilotPicker: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.s) {
            Text("Your pilot")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Tap an emoji to use in the next game.")
                .font(.caption)
                .foregroundStyle(.tertiary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.s) {
                    ForEach(PlayerCustomization.pickerEmojis, id: \.self) { em in
                        Button {
                            selection = em
                            HapticFeedback.light()
                        } label: {
                            Text(em)
                                .font(.system(size: 36))
                                .frame(width: 58, height: 58)
                                .background {
                                    Circle()
                                        .fill(
                                            selection == em
                                                ? AppTheme.hudAccent(for: colorScheme).opacity(0.2)
                                                : Color.primary.opacity(0.05)
                                        )
                                }
                                .overlay {
                                    Circle()
                                        .strokeBorder(
                                            selection == em
                                                ? AppTheme.hudAccent(for: colorScheme)
                                                : Color.primary.opacity(0.12),
                                            lineWidth: selection == em ? 2.5 : 1
                                        )
                                }
                        }
                        .buttonStyle(PressScaleButtonStyle(pressedScale: 0.92))
                        .accessibilityLabel("Pilot \(em)")
                        .accessibilityHint(selection == em ? "Currently selected" : "Select this pilot")
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Primary / secondary actions

struct PrimaryGradientButtonLabel: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: 10) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
                .font(.headline.weight(.semibold))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.m)
        .background {
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: AppTheme.primaryButtonGradient(for: colorScheme),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.2), radius: 18, y: 10)
        }
    }
}

struct SecondaryOutlineButtonLabel: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String

    var body: some View {
        Text(title)
            .font(.headline.weight(.medium))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.m)
            .background {
                Capsule(style: .continuous)
                    .strokeBorder(AppTheme.secondaryButtonStroke(for: colorScheme), lineWidth: 1.5)
                    .background {
                        Capsule(style: .continuous)
                            .fill(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.04))
                    }
            }
    }
}

// MARK: - Game over card

struct GameOverPanel: View {
    @Environment(\.colorScheme) private var colorScheme
    let scoreSeconds: Int
    let emojiScore: Int
    let allTimeHighScore: Int
    let isNewHighScoreThisRun: Bool
    var onPlayAgain: () -> Void
    var onHome: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.l) {
            Text("Game Over")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(.primary)

            VStack(spacing: AppTheme.Spacing.m) {
                Text("Results")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.l) {
                    gameOverStat(title: "Time", value: "\(scoreSeconds)", unit: "s")
                    gameOverStat(title: "Score", value: "\(emojiScore)", unit: nil)
                }

                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(AppTheme.hudAccent(for: colorScheme))
                        Text("All-time best: \(allTimeHighScore)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    if isNewHighScoreThisRun {
                        Text("New record!")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.hudAccent(for: colorScheme))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(AppTheme.hudAccent(for: colorScheme).opacity(0.18))
                            )
                    }
                }
            }

            VStack(spacing: AppTheme.Spacing.s) {
                Button {
                    HapticFeedback.medium()
                    onPlayAgain()
                } label: {
                    PrimaryGradientButtonLabel(title: "Play Again", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    HapticFeedback.light()
                    onHome()
                } label: {
                    SecondaryOutlineButtonLabel(title: "Back to Home")
                }
                .buttonStyle(PressScaleButtonStyle(pressedScale: 0.98))
            }
        }
        .scaleEffect(appeared ? 1 : 0.88)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.48, dampingFraction: 0.76)) {
                appeared = true
            }
        }
    }

    private func gameOverStat(title: String, value: String, unit: String?) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(
                        LinearGradient(
                            colors: AppTheme.primaryButtonGradient(for: colorScheme),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                if let unit {
                    Text(unit)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title + " " + value + (unit.map { " \($0)" } ?? ""))
    }
}

// MARK: - Home hero decoration

struct HomeFloatingEmojis: View {
    private let emojis = ["🎮", "⭐️", "🚀"]

    @State private var bob = false

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xl) {
            ForEach(Array(emojis.enumerated()), id: \.offset) { index, symbol in
                Text(symbol)
                    .font(.system(size: 44))
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 4)
                    .offset(y: bob ? CGFloat([-6, 0, -4][index % 3]) : CGFloat([4, -5, 6][index % 3]))
                    .animation(
                        .easeInOut(duration: 2.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.18),
                        value: bob
                    )
            }
        }
        .onAppear { bob = true }
    }
}
