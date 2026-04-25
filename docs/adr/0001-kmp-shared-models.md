# ADR 0001 — KMP for Shared Models and Business Logic

**Status:** Accepted
**Date:** 2026-04-24

---

## Context

This app targets iOS and Android simultaneously. The core risk with dual-platform development is model drift — the iOS and Android codebases define the same data structures independently and diverge over time, causing bugs and parity failures.

Existing projects (DharmaGit, BTYBD) have proven this is a real problem when managed manually.

## Decision

Use **Kotlin Multiplatform (KMP)** for all data models, repository interfaces, domain use cases, and utility functions.

- `shared/src/commonMain/` — all shared Kotlin code
- `shared/src/androidMain/` — Android-specific implementations (Room, Retrofit, etc. if needed)
- `shared/src/iosMain/` — iOS-specific implementations (if needed)
- Native UI on each platform: SwiftUI (iOS) and Jetpack Compose (Android)
- KMP compiles to `shared.xcframework` for iOS consumption

## Rationale

- **Single source of truth** — models defined once in Kotlin, consumed by both platforms
- **Type safety** — no JSON mapping divergence between platforms
- **Proven pattern** — DharmaGit and BTYBD already use this successfully
- **AI layer** — Ktor (KMP-compatible) allows a single HTTP client for OpenAI/Claude calls

## Consequences

**Positive:**
- Zero model drift by construction
- Business logic tested once (commonMain unit tests)
- New features added to KMP automatically available on both platforms

**Negative:**
- KMP build setup adds initial complexity (Gradle, XCFramework linking)
- iOS engineers must understand the Kotlin interface surface
- Kotlin suspend functions require a coroutines bridge for Swift async/await

## Alternatives Considered

| Option | Rejected Because |
|--------|-----------------|
| Separate native codebases | Model drift guaranteed over time |
| React Native / Flutter | Not in the established stack; native perf preferred |
| Swift Package for sharing | Swift doesn't compile to Android |
