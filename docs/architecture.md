# Architecture

## Overview

```
┌─────────────────────────────────────┐
│         iOS — SwiftUI               │
│  @Observable AppState               │
│  Feature views + POW components     │
└──────────────┬──────────────────────┘
               │
               │  Supabase Swift SDK
               │
┌──────────────▼──────────────────────┐
│         Supabase                    │
│  Auth  │  Postgres + RLS            │
│  Edge Functions (Deno/TypeScript)   │
│  Storage (practice audio)           │
└─────────────────────────────────────┘

[KMP scaffold exists at shared/ — not yet wired to iOS]
```

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| iOS language | Swift 6.2+ | Strict concurrency |
| iOS UI | SwiftUI | @Observable state, NavigationStack |
| iOS state | @Observable + AppState | Single root state object |
| Backend | Supabase | Auth, Postgres, Edge Functions, Storage |
| Payments | StoreKit 2 | Product: `apow.cohort.8week` |
| Android | Kotlin + Jetpack Compose | Scaffold only — not feature-complete |
| Shared | Kotlin Multiplatform | Scaffold only — iOS uses Supabase SDK directly |

## iOS State Management

```swift
// AppState — single @Observable root, injected via .environment(appState)
@Observable final class AppState {
    var session: Session?           // Supabase auth session
    var profile: Profile?           // user_profiles row
    var activeMembership: CohortMembership?
    var phase: AppPhase = .loading  // loading | auth | onboarding | main
}

// Views observe via @Environment(AppState.self)
// No ViewModels — state lives in AppState or local @State
```

## Data Flow

```
User Action
    → SwiftUI view (local @State or @Environment(AppState.self))
    → SupabaseService.shared.<method>()
    → Supabase REST API / Realtime
    → Postgres (RLS enforced)
    → Decoded into model struct (Codable)
    → AppState updated → view re-renders
```

## Supabase Auth Flow

```
App launch
    → SupabaseClient.shared.auth.session
    → nil → show Auth screens
    → session → check user_profiles.onboarding_step
        → not complete → Onboarding flow
        → complete → MainTabView
```

## Feature Structure (iOS)

```
Features/
├── Auth/           CreateAccountView, SignInView
├── Onboarding/     AgeConfirmView, AgreementsView, ProfileSetupView
├── Public/         PublicNavigationView (pre-auth landing)
├── Tabs/
│   ├── Today/      TodayView, CheckInFormView
│   ├── Practices/  PracticeLibraryView, PracticeDetailView
│   ├── Circle/     CircleView, CirclePostView
│   ├── Journal/    JournalView, JournalEntryView
│   └── MyPiece/    MyPieceView
├── Settings/       SettingsView, Safety, Legal, Support, DeleteAccount
└── Manage/         AdminDashboardView, FacilitatorDashboardView
```

## Supabase Schema Summary

| Table | Access | Notes |
|-------|--------|-------|
| `user_profiles` | Own row only | Created by trigger on auth.users insert |
| `practices` | `published = true` | Admin can write |
| `civic_lessons` | `published = true` | Admin can write |
| `check_ins` | Own rows | INSERT must include `user_id` |
| `cohorts` | `is_open = true` | Admin can write |
| `enrollments` | Own row | Created by edge function post-purchase |
| `circle_shares` | Cohort members | `hidden_at IS NULL` filter |
| `circle_comments` | Same as shares | — |
| `purchases` | Own rows | Created by StoreKit flow |

## Edge Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `verify-purchase` | Client POST after StoreKit | Validates Apple receipt |
| `record-entitlement` | Called by verify-purchase | Creates enrollment row |

## Secrets

| Secret | Location | Used by |
|--------|----------|---------|
| `SUPABASE_URL` | Secrets.xcconfig (gitignored) | iOS via Info.plist |
| `SUPABASE_ANON_KEY` | Secrets.xcconfig (gitignored) | iOS via Info.plist |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase secrets store | Edge functions only |
