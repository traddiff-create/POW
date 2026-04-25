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

## Shared Content Resources

All platform-agnostic content lives in `shared/content/`. These are the source-of-truth knowledge assets extracted from Dharma Wellness and Alexandria.

| File | What it contains |
|------|-----------------|
| `shared/content/meditation-techniques.json` | 11 Dharma meditation techniques — layer tags, duration, tradition, evidence level, use-case tags. Source: `DharmaGit/ios/Y/MeditationGuides/guides.md` |
| `shared/content/audio-library.json` | 44 audio files (18 learn guides, 6 sleep, 16 med ambient, 4 tones) — layer assignments, type, use-case tags. Source: `DharmaGit/ios/Y/Audio/` |
| `shared/content/alexandria-integration.md` | How to query the Alexandria knowledge library (CLI, REST API on :8642, MCP server) — includes layer-to-subject mapping for Walter Russell, Neville Goddard, breathwork research, and co-regulation theory |

### Layer → Content Map

| Layer | Techniques | Audio | Alexandria |
|-------|-----------|-------|-----------|
| 1 — Self Regulation | All 11 techniques (focus, relaxation, movement) | All Learn/ + Sleep/ + Med/ files | "Health & Wellness", "Breathwork", "MBSR", "Somatic" subjects |
| 2 — Co-Regulation | Loving-Kindness (bridges L1+L2) | `co_regulation.m4a`, `synchronized_breathing.m4a` | "Co-Regulation", "Relational Health" subjects |
| 3 — Community | Walking Meditation (bridges L1+L3) | `med-walking`, `med-gong-session` | "Community", "Group Practice" subjects |
| 4 — Agency | Guided Visualization (bridges L1+L4) | `davidson_four_pillars.m4a`, `four_pillars_cycle.m4a` | Walter Russell (44 entries), Neville Goddard (165 files) |
| 5 — Civic | — | — | PoP SD: 100+ USCIS questions, 108 SD legislators, founding docs |

### Alexandria Access
- **Local CLI:** `alexandria search "query"` at `/Applications/Apps/Alexandria/`
- **REST API:** `http://localhost:8642/api/search?q=...` (run `alexandria dashboard`)
- **MCP:** `AlexandriaMCP` Swift target — 11 tools (`alexandria_search`, `alexandria_browse`, `alexandria_related`, etc.)

## Related Skills
`/pipeline` `/release` `/dharma-release` (reference for cross-platform release flow)
