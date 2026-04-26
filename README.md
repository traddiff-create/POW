# A Piece of Whole (POW)

> 8-week somatic wellness + civic engagement program — iOS app with Supabase backend

## Working Philosophy

A Piece of Whole starts from a simple premise: the health of the self, relationships, and communities is the same work at different scales. The app is organized as a five-layer spiral: self-regulation, co-regulation, community, agency, and civic engagement.

Core product decisions should preserve connection as the foundation, make the method match the message, support deep change without destabilization, treat care as intelligence, allow plurality, and keep civic participation nonpartisan, local, and grounded in care rather than ideology.

## App Store
| Field | Value |
|-------|-------|
| Name | A Piece of Whole |
| Bundle ID | com.traddifftech.apieceofwhole |
| Version | 1.0 (build 2) |
| Platform | iOS 17+ |
| Categories | Health & Fitness / Education |
| SKU | APIECEOFWHOLE2025 |

## Tech Stack
| Layer | Technology |
|-------|-----------|
| iOS | Swift 6.0, SwiftUI, @Observable |
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
│   └── functions/          — verify-purchase; record-entitlement is disabled legacy code
├── marketing/ios/          — App Store metadata + screenshots
├── scripts/                — ExportOptions.plist, build/release scripts
└── docs/                   — Architecture, design system, API contracts, ADRs
```

Key iOS philosophy integration points:
- `Core/Content/POWPhilosophy.swift` contains shared static philosophy copy.
- `Features/Philosophy/PhilosophyView.swift` renders the full working philosophy in app.
- Welcome, onboarding, Learn, Practice, Spiral, My Piece, Civic, Settings, and Community Guidelines surface distilled app-facing language.

## Quick Start — iOS

### Prerequisites
- Xcode 26.4.1 (`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`)
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
