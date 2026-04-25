# A Piece of Whole (POW) — Claude Instructions

**Location:** `/Applications/Apps/Piece of Whole/` | **GitHub:** traddiff-create/POW | **Owner:** Rory Stone

## Stack

| Layer | Technology |
|-------|-----------|
| iOS | Swift 6.2+, SwiftUI, @Observable, NavigationStack |
| Backend | Supabase (Postgres + Auth + Edge Functions + Storage) |
| Android | Kotlin, Jetpack Compose, Material 3 (scaffold only) |
| Shared | Kotlin Multiplatform (KMP) scaffold — not wired to iOS yet |
| AI | OpenAI API + Claude API |

## Bundle IDs & App IDs
- iOS Bundle: `com.traddifftech.apieceofwhole`
- Apple Bundle ID registered: `8NNC4RKNGT` (registered 2026-04-25)
- App Store Connect ID: `6763727066` ✅ (created 2026-04-25)
- SKU: `APIECEOFWHOLE2025`

## Supabase Project
- Project ref: `gtpeyindgjhegldrdrrb`
- URL: `https://gtpeyindgjhegldrdrrb.supabase.co`
- Credentials: `ios/APieceOfWhole/APieceOfWhole/Config/Secrets.xcconfig` (gitignored)
- Migrations: `supabase/migrations/` (push via `supabase db push --linked`)

## iOS Project (primary — all active development here)
```
ios/APieceOfWhole/
  APieceOfWhole.xcodeproj    — Xcode project
  APieceOfWhole/
    App/          — @main entry, AppState, RootView
    Config/       — Config.swift, Secrets.xcconfig (gitignored)
    Core/
      Auth/         — AuthService (Supabase auth)
      Supabase/     — SupabaseClient, SupabaseService
      Models/       — All data models (CheckIn, Practice, Profile, etc.)
      Design/       — Colors, Typography, POW* components
      StoreKit/     — PurchaseService
    Features/
      Auth/         — CreateAccountView, SignInView
      Onboarding/   — Age confirm, agreements, profile setup
      Tabs/         — MainTabView + Today, Practices, Circle, Journal, MyPiece tabs
      Settings/     — SettingsView, Safety, Legal, Support, DeleteAccount
      Manage/       — Admin + Facilitator dashboards
      Public/       — Pre-auth navigation
```

## Key Conventions
- **Supabase-first:** iOS uses Supabase Swift SDK directly — no KMP data layer yet
- **RLS:** every table has row-level security; `check_ins` policy requires `user_id` in INSERT payload
- **Secrets:** `Secrets.xcconfig` is gitignored; use xcconfig variable expansion for URLs (`_FS = /`)
- **Swift:** strict concurrency, @Observable for state, no singletons except SupabaseService
- **Commits:** conventional commits (`feat/fix/refactor/docs/chore`)

## Build Commands
```bash
# iOS — build (simulator)
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild -project "ios/APieceOfWhole/APieceOfWhole.xcodeproj" \
  -scheme APieceOfWhole \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build

# iOS — archive for App Store
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild -project "ios/APieceOfWhole/APieceOfWhole.xcodeproj" \
  -scheme APieceOfWhole \
  -destination generic/platform=iOS \
  -archivePath build/APieceOfWhole.xcarchive \
  archive

# Export + upload
xcodebuild -exportArchive \
  -archivePath build/APieceOfWhole.xcarchive \
  -exportOptionsPlist scripts/ExportOptions.plist \
  -exportPath build/export

# Supabase — push migrations
supabase db push --linked

# Supabase — deploy edge functions
supabase functions deploy verify-purchase
supabase functions deploy record-entitlement
```

## Supabase Schema Quick Reference
| Table | Notes |
|-------|-------|
| `user_profiles` | Created by trigger on auth.users insert |
| `practices` | RLS: `published = true` for read |
| `civic_lessons` | RLS: `published = true` for read |
| `check_ins` | INSERT requires `user_id` explicitly (RLS: `user_id = auth.uid()`) |
| `cohorts` | `is_open = true` for public listing |
| `enrollments` | Activated post-purchase by edge function |
| `circle_shares` | Scoped to cohort; `hidden_at IS NULL` for reads |

## StoreKit
- Product ID: `apow.cohort.8week`
- Edge function `verify-purchase` validates receipt → `record-entitlement` creates enrollment

## Related Skills
`/pipeline` `/release` `/dharma-release` (reference for cross-platform release flow)
