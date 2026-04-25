# iOS / Android Parity Checklist

Track feature parity between platforms. Update status as features are built.

**Status values:** `[ ]` Not started | `[~]` In progress | `[x]` Complete | `[N/A]` Platform-only

---

## Core Features

| Feature | iOS | Android | KMP Shared | Notes |
|---------|-----|---------|-----------|-------|
| Onboarding flow | [ ] | [ ] | [ ] | |
| Home screen | [ ] | [ ] | [ ] | |
| Detail screen | [ ] | [ ] | [ ] | |
| Settings screen | [ ] | [ ] | [ ] | |
| Push notifications | [ ] | [ ] | N/A | Platform-specific setup |
| Deep linking | [ ] | [ ] | N/A | |
| Dark mode | [ ] | [ ] | N/A | |
| Accessibility (VoiceOver / TalkBack) | [ ] | [ ] | N/A | |

## Data Layer (KMP)

| Model / Repo | commonMain | iOS binding | Android binding | Notes |
|-------------|-----------|-------------|-----------------|-------|
| Item model | [ ] | [ ] | [ ] | |
| ItemRepository | [ ] | [ ] | [ ] | |
| Main use case | [ ] | [ ] | [ ] | |

## AI Features

| Feature | iOS | Android | Notes |
|---------|-----|---------|-------|
| OpenAI integration | [ ] | [ ] | Via KMP Ktor |
| Claude integration | [ ] | [ ] | Via KMP Ktor |

## Release Readiness

| Item | iOS | Android |
|------|-----|---------|
| App icon (all sizes) | [ ] | [ ] |
| Launch screen | [ ] | [ ] |
| Privacy manifest / policy | [ ] | [ ] |
| App Store metadata | [ ] | [ ] |
| Screenshots | [ ] | [ ] |
| In-app purchases (if any) | N/A | N/A |

---

## Drift Detection Rule
Any change to a model in `shared/commonMain` must be reflected in both platforms before the PR merges. Run `scripts/check-parity.sh` to scan for mismatches.
