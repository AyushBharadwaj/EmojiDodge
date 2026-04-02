# TOOLS.md

Tools and frameworks used to build **Emoji Dodge**.

## Workflow

| Tool | Role |
|------|------|
| **Xcode** | Apple’s **native IDE** for iOS: edit, build, run, Simulator, asset catalogs, and code signing. |
| **Cursor** | Editor / AI-assisted environment used to **create and iterate on** the app and project files. |
| **ChatGPT** | Used to turn **informal or manual-language prompts** into clearer, structured prompt text (e.g. for `prompt.md` / `PROMPTS.md`). |

## Apple platform stack

Build, run, and sign the app in **Xcode** (see **Workflow**).

| Tool / API | Use |
|------------|-----|
| **Swift** | Language (Swift 5). |
| **SwiftUI** | UI, navigation, gestures, animations. |
| **Combine** | `@Published` / `ObservableObject` (via SwiftUI). |
| **UIKit** (minimal) | `CADisplayLink` host run loop (`.main`, `.common`). |
| **QuartzCore** | `CADisplayLink` import. |
| **AudioToolbox** | `AudioServicesPlaySystemSound` for SFX. |
| **UIKit** | `UIImpactFeedbackGenerator` for UI haptics (`HapticFeedback`). |
| **Foundation** | `Timer`, dates, UUIDs. |

## Optional CLI

- **`xcodebuild`**: CI or headless builds; use `-derivedDataPath` inside the repo if the default `~/Library/Developer/Xcode/DerivedData` is not writable.

## Simulator vs device

System sound IDs can sound slightly different on Simulator vs hardware; tune `SystemSounds` on a real device for final polish.
