# A Piece of Whole (POW) — Codex Instructions

**Location:** `/Applications/Apps/Piece of Whole/` | **GitHub:** traddiff-create/POW | **Owner:** Rory Stone

## Stack

| Layer | Technology |
|-------|-----------|
| iOS | Swift 6.2+, SwiftUI, @Observable, NavigationStack |
| Backend | Supabase (Postgres + Auth + Edge Functions + Storage) |
| Android | Kotlin, Jetpack Compose, Material 3 (scaffold only) |
| Shared | Kotlin Multiplatform (KMP) scaffold — not wired to iOS yet |
| AI | OpenAI API + Codex API |

## Product Philosophy

A Piece of Whole is built from the inside out: self-regulation, co-regulation, community, agency, and civic engagement are one connected spiral, not separate features.

Use this working philosophy as a decision filter:
- Connection is the foundation; optimize for embodied, relational practice over passive consumption.
- The method is the message; do not use domination, shame, manipulation, or fear to create participation.
- Change should be deep without destabilizing people or communities; respect nervous-system and community windows of tolerance.
- Care is intelligence, not weakness; make safety, consent, privacy, and repair visible in product choices.
- No single framework owns the truth; hold plurality, lived experience, humility, and the unknown.
- Reciprocity matters; connect inward practice to relationships, civic life, and the living world.
- Civic engagement is nonpartisan, values-based, local, and grounded in care rather than ideology.

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
      Content/      — Static product philosophy and shared app copy
      Supabase/     — SupabaseClient, SupabaseService
      Models/       — All data models (CheckIn, Practice, Profile, etc.)
      Design/       — Colors, Typography, POW* components
      StoreKit/     — PurchaseService
    Features/
      Auth/         — CreateAccountView, SignInView
      Onboarding/   — Age confirm, agreements, profile setup
      Philosophy/   — Working Philosophy screen
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
- Edge function `verify-purchase` validates the StoreKit signed transaction and creates the purchase + enrollment
- Required Supabase function secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `APPLE_BUNDLE_ID=com.traddifftech.apieceofwhole`
- `record-entitlement` is intentionally disabled; undeploy any old remote copy instead of using an internal shared secret purchase writer

## Related Skills
`/pipeline` `/release` `/dharma-release` (reference for cross-platform release flow)
