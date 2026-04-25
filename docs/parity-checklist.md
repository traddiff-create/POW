# iOS / Android Parity Checklist

Track feature parity between platforms. Update status as features are built.

**Status values:** `[ ]` Not started | `[~]` In progress | `[x]` Complete | `[N/A]` Platform-only

---

## Auth & Onboarding

| Feature | iOS | Android | Notes |
|---------|-----|---------|-------|
| Create account | [x] | [ ] | |
| Sign in / sign out | [x] | [ ] | |
| Age confirmation step | [x] | [ ] | |
| Agreements step | [x] | [ ] | |
| Profile setup step | [x] | [ ] | |
| Onboarding completion → main tabs | [x] | [ ] | |

## Core Tabs

| Feature | iOS | Android | Notes |
|---------|-----|---------|-------|
| Today tab (home) | [x] | [ ] | |
| Daily check-in form | [x] | [ ] | mood, body, stress, capacity, note |
| Practice Library tab | [x] | [ ] | |
| Practice detail view | [x] | [ ] | |
| Circle tab | [x] | [ ] | |
| Circle post submission | [x] | [ ] | |
| Journal tab | [x] | [ ] | |
| Journal entry create/edit | [x] | [ ] | |
| My Piece tab | [x] | [ ] | values, gifts, capacity, contribution |

## Settings

| Feature | iOS | Android | Notes |
|---------|-----|---------|-------|
| Settings screen | [x] | [ ] | |
| Safety resources view | [x] | [ ] | |
| Legal / privacy view | [x] | [ ] | |
| Support contact | [x] | [ ] | |
| Delete account | [x] | [ ] | |

## Admin / Manage

| Feature | iOS | Android | Notes |
|---------|-----|---------|-------|
| Admin dashboard | [x] | [N/A] | iOS-only admin surface |
| Facilitator dashboard | [x] | [N/A] | |
| Admin applications review | [x] | [N/A] | |
| Admin content management | [x] | [N/A] | |
| Admin notifications | [x] | [N/A] | |

## Supabase / Backend

| Feature | iOS | Android | Notes |
|---------|-----|---------|-------|
| Auth (Supabase) | [x] | [ ] | |
| user_profiles read/write | [x] | [ ] | |
| check_ins CRUD | [x] | [ ] | |
| practices fetch | [x] | [ ] | |
| civic_lessons fetch | [x] | [ ] | |
| circle_shares CRUD | [x] | [ ] | |
| journal_entries CRUD | [x] | [ ] | |
| enrollments read | [x] | [ ] | |
| StoreKit purchase → enrollment | [x] | [ ] | Android uses Play Billing |

## Platform Features

| Feature | iOS | Android | Notes |
|---------|-----|---------|-------|
| Dark mode | [ ] | [ ] | Color tokens in place; system support TBD |
| Push notifications | [ ] | [ ] | |
| Deep linking | [ ] | [ ] | |
| Dynamic Type / accessibility | [ ] | [ ] | Font tokens in place |
| Offline / cached data | [ ] | [ ] | No SQLDelight wired yet |
