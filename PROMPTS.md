# Emoji Dodge — project prompts

Structured record of prompts used to build and evolve the app.

---

## Prompt 1 — Plan mode

Build a complete SwiftUI iOS game called "Emoji Dodge" following clean architecture and MVVM.

**Requirements:**

- Architecture: MVVM
- Language: Swift
- UI: SwiftUI
- Clean, modular, production-level code

**App structure:**

- Two screens:
  1. Home Screen
  2. Game Screen

**Home screen:**

- Title: "Emoji Dodge"
- Subtitle: "Avoid the falling emojis!"
- Instructions (short how-to-play)
- Start Game button

**Game screen:**

- Player at bottom (simple shape or emoji)
- Falling emojis from top (random positions)
- Continuous spawning
- **Movement:** Player moves horizontally via drag gesture
- **Collision detection:** If emoji hits player → Game Over
- **Score:** Based on survival time; live score display at top
- **Sound:** Background gameplay sound; collision sound (game over)
- **Game over:** Show overlay/modal; final score; Restart button; Back to Home button

**Technical expectations:**

- Proper MVVM separation: View, ViewModel, Model
- Use Timer or CADisplayLink for game loop
- Use Combine if needed
- Keep logic out of Views
- Use structs and clean state management
- Smooth animation using SwiftUI

**UI expectations:**

- Minimal but polished UI
- Smooth animations
- Good spacing and layout

**Deliverables:**

1. Full project structure  
2. All Swift files  
3. ViewModels with logic  
4. Sound handling  
5. Collision logic  
6. README.md  
7. PROMPTS.md  
8. TOOLS.md  

**Also:**

- Keep code concise but readable  
- Add comments where needed  
- Ensure it runs without external dependencies  

---

## Prompt 2 — Agent mode

Improve the UI and UX of an existing SwiftUI arcade game called **"Emoji Dodge"**.

**Focus ONLY on UI/UX, visual design, and animations. Do NOT change core game logic.**

**Goals:**

- Create a modern, premium-quality UI
- Ensure smooth, delightful user experience
- Support both Dark Mode and Light Mode
- Add subtle but engaging animations

**Design requirements:**

1. **Overall theme:** Modern, minimal design system; glassmorphism or soft neumorphism where appropriate; gradients for backgrounds (dynamic light/dark); high contrast and readability.

2. **Home screen:** Centered layout, strong hierarchy; animated title (subtle scale or fade-in); stylish Start Game button (rounded corners, gradient, tap scale + haptic); small icon/emoji animation.

3. **Game screen:** Clean HUD (score at top, modern typography, capsule/card); smooth player movement; slight bounce while moving; falling emojis with rotation/variation; random size variation for depth.

4. **Animations:** SwiftUI (`easeInOut`, `spring`, `interactiveSpring`); entry transitions; smooth spawn for emojis; collision feedback (shake, flash, burst); game over fade + scale modal + background blur.

5. **Game over UI:** Card-style modal; large bold score; **Play Again** (primary); **Back to Home** (secondary); subtle appear animation.

6. **Dark / light mode:** Dynamic colors; separate gradient palettes (light: soft/vibrant; dark: deep/neon); accessibility contrast.

7. **Microinteractions:** Button tap animations; haptics; smooth state transitions.

8. **Code:** Reusable components; Theme / design system (colors, fonts, spacing); UI logic separate from ViewModel; clean scalable structure.

9. **Deliverables:** Updated views; reusable UI (buttons, cards, HUD); theme for dark/light; animation modifiers/helpers.

Make the app feel like a polished App Store–quality game, not a prototype.

---

## Prompt 3 — Agent mode

**Improvements required**

On the game screen, the score is currently based on a timer. Enhance this by displaying both:

- The elapsed time (timer-based), and  
- The run score (count of emojis successfully dodged past the bottom)  

Replace the default navigation back button with a custom-designed back button to better match the game’s UI/UX.

---

## Prompt 4 — Agent mode

**Enhancements required**

Currently, the player can only move left and right. Enhance the movement controls to allow **vertical movement** as well (up and down), enabling full directional navigation.

Increase the size of the player emoji and provide the ability to **change or customize** the emoji used for the player.

## Prompt 5 — Agent mode

**Improvement Required**

The current collision detection area is too large. Refine it to be more precise by adjusting it to edge-to-edge detection, ensuring collisions are only triggered when the actual boundaries of the player and emojis intersect.

---

## Prompt 6 — Agent mode

**Enhancement Added** 

Introduce a feature to track and display the all-time high score within the game.
Update the terminology by replacing “avoided” with “score” throughout the UI for better clarity and consistency.
