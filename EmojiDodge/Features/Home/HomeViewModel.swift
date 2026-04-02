import SwiftUI

final class HomeViewModel: ObservableObject {
    let title = "Emoji Dodge"
    let subtitle = "Avoid the falling emojis!"
    let instructions = """
Drag anywhere to move your pilot in any direction. \
Your time shows how long you survived; your score goes up for each falling emoji you dodge past the bottom. \
If an emoji hits you, it is game over.
"""
}
