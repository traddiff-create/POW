# Hackathon — Claude Instructions

**Location:** `/Applications/Apps/Hackathon/` | **Owner:** Rory Stone

## Stack
| Layer | Technology |
|-------|-----------|
| iOS UI | Swift 6.2+, SwiftUI, @Observable, NavigationStack |
| Android UI | Kotlin, Jetpack Compose, Material 3 Expressive |
| Shared | Kotlin Multiplatform (KMP), Ktor, SQLDelight, Kotlin Serialization |
| AI | OpenAI API (`$OPENAI_API_KEY`) + Claude API (`$ANTHROPIC_API_KEY`) |

## Bundle IDs
- iOS: `com.traddifftech.hackathon` *(placeholder — update before first build)*
- Android: `com.hackathon.app` *(placeholder)*

## Key Directories
```
shared/src/commonMain/kotlin/com/hackathon/
  models/       — Data models (source of truth — KMP)
  repository/   — Data access interfaces
  domain/       — Business logic, use cases
  utils/        — Shared utilities

ios/Hackathon/
  App/          — @main entry point
  Features/     — One folder per screen/feature
  Core/Design/  — Colors, Typography, Tokens
  Core/Components/ — Reusable SwiftUI views

android/src/main/kotlin/com/hackathon/
  ui/           — Compose screens and ViewModels
  core/         — DI, navigation, theme
```

## Conventions
- **KMP first:** all data models live in `shared/commonMain` — never duplicate in iOS or Android
- **Swift:** strict concurrency (`-strict-concurrency=complete`), @Observable for state
- **Compose:** state hoisting, no business logic in composables
- **Parity rule:** any change to a KMP model requires updating BOTH platform UIs
- **Commits:** conventional commits (`feat/fix/refactor/docs/chore`)

## Build Commands (fill in as project is created)
```bash
# iOS — build
xcodebuild -project ios/Hackathon/Hackathon.xcodeproj ...

# Android — build
cd android && ./gradlew assembleDebug

# KMP shared — build
./gradlew :shared:build
```

## Related Skills
`/pipeline` `/release` `/dharma-release` (reference for cross-platform release flow)
