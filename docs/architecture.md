# Architecture

## Overview

```
┌─────────────────────┐     ┌─────────────────────┐
│      iOS (Swift)    │     │   Android (Kotlin)   │
│   SwiftUI + @Obs.   │     │  Compose + ViewModel │
└────────┬────────────┘     └──────────┬───────────┘
         │                             │
         └──────────┬──────────────────┘
                    │
         ┌──────────▼──────────┐
         │   shared (KMP)      │
         │  commonMain/kotlin  │
         │  models / repo /    │
         │  domain / utils     │
         └──────────┬──────────┘
                    │
         ┌──────────▼──────────┐
         │  External Services  │
         │  Ktor (HTTP)        │
         │  SQLDelight (DB)    │
         │  OpenAI API         │
         │  Claude API         │
         └─────────────────────┘
```

## Tech Stack

| Layer | iOS | Android | Shared |
|-------|-----|---------|--------|
| Language | Swift 6.2+ | Kotlin 2.x | Kotlin (KMP) |
| UI | SwiftUI | Jetpack Compose | — |
| State | @Observable | ViewModel + StateFlow | — |
| Navigation | NavigationStack | NavHost | — |
| Networking | Ktor (via KMP) | Ktor (via KMP) | Ktor Client |
| Persistence | SQLDelight (via KMP) | SQLDelight (via KMP) | SQLDelight |
| Serialization | — | — | Kotlin Serialization |
| DI | Manual / Swift | Hilt or manual | — |
| AI | — | — | OpenAI + Claude APIs |

## State Management

### iOS (@Observable pattern — matches DharmaGit)
```swift
@Observable
final class HomeViewModel {
    var items: [Item] = []
    private let repository: ItemRepository

    func load() async { ... }
}
```

### Android (ViewModel + StateFlow)
```kotlin
class HomeViewModel(private val repository: ItemRepository) : ViewModel() {
    val uiState: StateFlow<HomeUiState> = ...
}
```

## Data Flow

```
User Action
    → ViewModel (iOS @Observable / Android ViewModel)
    → Domain UseCase (KMP commonMain)
    → Repository interface (KMP commonMain)
    → Repository impl (platform-specific or KMP)
    → Data source (SQLDelight / Ktor)
```

## KMP Module Layout

```
shared/src/
├── commonMain/kotlin/com/hackathon/
│   ├── models/         # Data classes, enums (no platform deps)
│   ├── repository/     # Interfaces only
│   ├── domain/         # Use cases — pure business logic
│   └── utils/          # Extensions, helpers
├── androidMain/        # Android-specific implementations
└── iosMain/            # iOS-specific implementations
```

## iOS Xcframework
The KMP shared module compiles to `shared.xcframework` for iOS consumption.
Build: `./gradlew :shared:assembleXCFramework`

## AI Integration
- `OPENAI_API_KEY` — ChatGPT (GPT-4o) for user-facing AI features
- `ANTHROPIC_API_KEY` — Claude for internal tooling / content generation
- Both keys are environment variables — never hardcoded
