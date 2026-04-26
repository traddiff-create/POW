# API Contracts — Supabase

All data access goes through `Core/Supabase/SupabaseService.swift`.
Tables are accessed via Supabase REST API (PostgREST) with RLS enforced server-side.

---

## Auth

```swift
// AuthService.swift
func signUp(email: String, password: String) async throws -> User
func signIn(email: String, password: String) async throws -> Session
func signOut() async throws
var currentSession: Session? { get }
```

---

## user_profiles

```swift
func fetchProfile(userID: String) async throws -> Profile
func updateOnboardingAgeConfirm(userID: String, timestamp: String) async throws
func updateOnboardingAgreements(userID: String, timestamp: String) async throws
func updateOnboardingProfile(userID: String, displayName: String, timestamp: String) async throws
func updateMyPiece(userID: String, values: String?, giftsSkills: String?,
                   currentCapacity: String?, boundaries: String?,
                   currentContribution: String?, smallAction: String?) async throws
```

**Profile model** (maps to `user_profiles`):
```swift
struct Profile: Codable {
    let id: String
    var displayName: String?
    var role: String           // "participant" | "facilitator" | "admin"
    var onboardingStep: String
    var onboardingCompletedAt: String?
    var adultConfirmedAt: String?
    var agreementsAcceptedAt: String?
    var values: String?
    var giftsSkills: String?
    var currentCapacity: String?
    var boundaries: String?
    var currentContribution: String?
    var smallAction: String?
}
```

---

## check_ins

```swift
func submitCheckIn(_ checkIn: CheckInSubmission) async throws
func fetchCheckIns(userID: String) async throws -> [CheckIn]
func fetchTodayCheckIn(userID: String) async throws -> CheckIn?
```

**CheckInSubmission** — must include `user_id` (RLS enforces `user_id = auth.uid()`):
```swift
struct CheckInSubmission: Encodable {
    let userID: String          // required — maps to "user_id"
    let weekNumber: Int
    let moodScore: Int?         // 1–5
    let bodySensation: String?
    let oneWord: String?
    let freeNote: String?
    let mood: Int?              // 1–5
    let stressLevel: Int?       // 1–5
    let capacityLevel: Int?     // 1–5
}
```

---

## practices

```swift
func fetchPractices(weekNumber: Int? = nil) async throws -> [Practice]
```

RLS: `published = true` required. Returns all published practices, optionally filtered by week.

---

## civic_lessons

```swift
func fetchCivicLessons() async throws -> [CivicLesson]
```

RLS: `published = true` required. Ordered by `order_index`.

---

## cohorts & enrollments

```swift
func fetchOpenCohorts() async throws -> [Cohort]
func fetchCohort(id: String) async throws -> Cohort
func fetchMembership(userID: String) async throws -> CohortMembership?
```

---

## circle_shares

```swift
func fetchCirclePosts(cohortID: String, weekNumber: Int?) async throws -> [CirclePost]
func submitCirclePost(userID: String, cohortID: String, weekNumber: Int?,
                      content: String, isAnonymous: Bool) async throws -> CirclePost
func fetchComments(postID: String) async throws -> [CircleComment]
func submitComment(postID: String, userID: String, content: String) async throws
```

---

## journal_entries

```swift
func fetchJournalEntries(userID: String) async throws -> [JournalEntry]
func upsertJournalEntry(id: String?, userID: String, weekNumber: Int?,
                        title: String?, body: String?) async throws -> JournalEntry
func shareJournalEntry(entryID: String, userID: String, cohortID: String,
                       circleID: String, body: String) async throws
```

---

## Edge Functions

### POST /functions/v1/verify-purchase
Validates a StoreKit 2 signed transaction and records the entitlement with the service role.

```json
// Request
{
  "transactionId": "...",
  "originalTransactionId": "...",
  "userId": "...",
  "cohortId": "...",
  "productId": "apow.cohort.8week",
  "appAccountToken": "...",
  "purchaseDate": "2026-04-25T00:00:00Z",
  "expiresDate": null,
  "signedTransactionInfo": "..."
}

// Response 200
{ "success": true, "valid": true, "enrolled": true, "enrollmentId": "..." }
```

### POST /functions/v1/record-entitlement
Disabled legacy endpoint. It returns HTTP 410 and must not be used for purchase or enrollment creation.
