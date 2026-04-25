# A Piece of Whole (POW)

> 8-week somatic wellness + civic engagement program — iOS app with Supabase backend

## App Store
| Field | Value |
|-------|-------|
| Name | A Piece of Whole |
| Bundle ID | com.traddifftech.apieceofwhole |
| Version | 1.0 (build 1) |
| Platform | iOS 18+ |
| Categories | Health & Fitness / Education |
| SKU | APIECEOFWHOLE2025 |

## Tech Stack
| Layer | Technology |
|-------|-----------|
| iOS | Swift 6.2+, SwiftUI, @Observable |
| Backend | Supabase (Postgres + Auth + Edge Functions) |
| Payments | StoreKit 2 (product: `apow.cohort.8week`) |
| Android | Kotlin + Jetpack Compose (scaffold) |
| Shared | Kotlin Multiplatform (scaffold) |

## Project Structure
```
Piece of Whole/
├── ios/APieceOfWhole/      — Native SwiftUI app (primary development)
├── android/                — Compose scaffold
├── shared/                 — KMP scaffold
├── supabase/
│   ├── migrations/         — DB schema (push with: supabase db push --linked)
│   └── functions/          — verify-purchase, record-entitlement
├── marketing/ios/          — App Store metadata + screenshots
├── scripts/                — ExportOptions.plist, build/release scripts
└── docs/                   — Architecture, design system, API contracts, ADRs
```

## Quick Start — iOS

### Prerequisites
- Xcode 26.2 (`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`)
- Copy `ios/APieceOfWhole/APieceOfWhole/Config/Secrets.xcconfig.example` → `Secrets.xcconfig` and fill in Supabase credentials

### Build
```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild -project "ios/APieceOfWhole/APieceOfWhole.xcodeproj" \
  -scheme APieceOfWhole \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

### Supabase
```bash
# Push migrations to remote
supabase db push --linked

# Deploy edge functions
supabase functions deploy verify-purchase
supabase functions deploy record-entitlement

# Run SQL on remote
supabase db query --linked "SELECT count(*) FROM practices"
```

## New Developer Setup
1. Clone repo
2. Copy + fill `Secrets.xcconfig` (get values from Rory)
3. Open `ios/APieceOfWhole/APieceOfWhole.xcodeproj` in Xcode 26.2
4. Select `APieceOfWhole` scheme → iPhone simulator → Build

## Docs
- [CLAUDE.md](CLAUDE.md) — Claude-specific instructions, build commands, Supabase schema reference
- [Architecture](docs/architecture.md)
- [Design System](docs/design-system.md)
- [Parity Checklist](docs/parity-checklist.md)
- [API Contracts](docs/api-contracts.md)
- [ADRs](docs/adr/)
- [App Store Metadata](marketing/ios/metadata/)
