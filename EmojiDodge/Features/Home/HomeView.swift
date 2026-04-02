import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(PlayerCustomization.appStorageKey) private var playerEmoji = PlayerCustomization.defaultEmoji
    @AppStorage(HighScorePersistence.userDefaultsKey) private var allTimeHighScoreStored = 0

    @State private var heroVisible = false
    @State private var contentVisible = false

    var body: some View {
        ZStack {
            GradientBackground(palette: AppTheme.homeBackgroundGradient(for:))

            VStack(spacing: 0) {
                Spacer(minLength: AppTheme.Spacing.xxl)

                HomeFloatingEmojis()
                    .opacity(heroVisible ? 1 : 0)
                    .offset(y: heroVisible ? 0 : 12)
                    .padding(.bottom, AppTheme.Spacing.xl)

                VStack(spacing: AppTheme.Spacing.s) {
                    Text(viewModel.title)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.35 : 0.08), radius: 8, y: 4)

                    Text(viewModel.subtitle)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.hudAccent(for: colorScheme))
                        Text("All-time best score: \(allTimeHighScoreStored)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    .padding(.top, 6)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("All-time best score \(allTimeHighScoreStored)")
                }
                .scaleEffect(heroVisible ? 1 : 0.9)
                .opacity(heroVisible ? 1 : 0)

                Spacer(minLength: AppTheme.Spacing.xl)

                GlassCard {
                    Text(viewModel.instructions)
                        .font(.body)
                        .foregroundStyle(.primary.opacity(0.92))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, AppTheme.Spacing.m)
                .opacity(contentVisible ? 1 : 0)
                .offset(y: contentVisible ? 0 : 20)

                GlassCard {
                    PlayerPilotPicker(selection: $playerEmoji)
                }
                .padding(.horizontal, AppTheme.Spacing.m)
                .padding(.top, AppTheme.Spacing.s)
                .opacity(contentVisible ? 1 : 0)
                .offset(y: contentVisible ? 0 : 20)

                Spacer()

                NavigationLink(value: AppRoute.game) {
                    PrimaryGradientButtonLabel(title: "Start Game", systemImage: "play.fill")
                }
                .buttonStyle(PressScaleButtonStyle())
                .simultaneousGesture(TapGesture().onEnded { HapticFeedback.medium() })
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.bottom, AppTheme.Spacing.xxl)
                .opacity(contentVisible ? 1 : 0)
                .offset(y: contentVisible ? 0 : 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .game:
                GameView()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                heroVisible = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.12)) {
                contentVisible = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
