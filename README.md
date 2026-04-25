# Hackathon

> iOS-first app with Android parity via Kotlin Multiplatform (KMP)

## Platforms
| Platform | UI Framework | Min OS |
|----------|-------------|--------|
| iOS | SwiftUI | iOS 18+ |
| Android | Jetpack Compose | Android 8.0 (API 26) |
| Shared | Kotlin Multiplatform | — |

## Project Structure
```
Hackathon/
├── shared/          # KMP — models, repositories, domain logic
├── ios/             # Native SwiftUI app
├── android/         # Native Compose app
├── docs/            # Architecture, design system, parity checklist
├── marketing/       # App Store + Play Store assets
└── scripts/         # Build and release automation
```

## Quick Start

### Prerequisites
- Xcode 26.2+ (`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`)
- Android Studio Meerkat+
- JDK 17+
- Kotlin 2.x

### iOS
```bash
# Open Xcode project
open ios/Hackathon/Hackathon.xcodeproj
```

### Android
```bash
cd android
./gradlew assembleDebug
```

### KMP Shared
```bash
./gradlew :shared:build
```

## Docs
- [Architecture](docs/architecture.md)
- [Design System](docs/design-system.md)
- [Parity Checklist](docs/parity-checklist.md)
- [API Contracts](docs/api-contracts.md)
- [ADRs](docs/adr/)
