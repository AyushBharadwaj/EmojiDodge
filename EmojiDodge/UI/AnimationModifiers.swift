import SwiftUI

// MARK: - Press scale (buttons / links)

struct PressScaleButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.62), value: configuration.isPressed)
    }
}

// MARK: - Horizontal shake (game over impact)

struct ShakeEffect: GeometryEffect {
    var travel: CGFloat

    var animatableData: CGFloat {
        get { travel }
        set { travel = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: travel * sin(travel * .pi * 4), y: 0))
    }
}

extension View {
    func shake(amount: CGFloat) -> some View {
        modifier(ShakeEffect(travel: amount))
    }
}

// MARK: - Staggered appear

struct StaggeredAppearModifier: ViewModifier {
    let index: Int
    @Binding var isVisible: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 14)
            .animation(
                .spring(response: 0.55, dampingFraction: 0.82)
                    .delay(Double(index) * 0.06),
                value: isVisible
            )
    }
}

extension View {
    func staggeredAppear(index: Int, isVisible: Binding<Bool>) -> some View {
        modifier(StaggeredAppearModifier(index: index, isVisible: isVisible))
    }
}
