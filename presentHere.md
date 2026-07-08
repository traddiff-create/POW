# Here — Ignite RC Hackathon Presentation Pack

**Event:** Ignite Rapid City Hackathon | DLAB, 18 E Main St | Apr 24–26, 2026
**Judging:** Sunday Apr 26, 2:00–3:30 PM | 1–10 in four categories
**Team lead:** Rory Stone (Traditionally Different LLC), philosophy by Nicole Stone
**App:** **Here** — three-leg practice for nervous-system, relational, and civic regulation
**Status:** TestFlight build 5 of 1.0 uploaded today (2026-04-26 12:58 MDT) — live backend on Supabase
**App Store Connect ID:** 6763727066 | **Bundle:** com.traddifftech.apieceofwhole

---

## 1. The 60-second pitch (memorize this)

> The wellness industry has a fragmentation problem. Calm and Headspace will help you regulate alone. Civic apps will burn you out and sort you by team. Nothing connects the work of the self to the work of relationships to the work of community — even though anxiety, polarization, and civic disengagement are the same problem at three different scales.
>
> **Here** is a practice app built on a simple thesis: *the health of the self, our relationships, and our communities are the same work at different scales.* Three tabs — Self, Together, Community. One short daily prompt in each. A meditation timer to ground the body. An anonymous "Why We're Here" feed where people opt in to share why they came — civic transparency without surveillance.
>
> We pitched a cycling-community app on Friday. Over the weekend we realized the deeper opportunity: people in Rapid City don't just need better routes — they need a regulated, relational, locally-rooted way to show up. That's Here.

**Tagline:** *We are each a piece of something whole.*
**Thesis line:** *Self, Together, Community — the same work at different scales.*

---

## 2. Judging-criteria scorecard (the four boxes the panel checks)

### A. Technical execution (does the product work?) — target 9/10

**Evidence we hand the judges:**
- Live TestFlight build (1.0 build 5) uploaded **today, mid-presentation day**, signed and accepted by App Store Connect.
- Native iOS, Swift 6.2+, SwiftUI, `@Observable`, strict concurrency, Apple Sign-In wired end-to-end through Supabase Auth.
- Supabase backend with **9 production migrations applied**, full Row-Level Security on every table, a `SECURITY DEFINER` RPC for the public anonymous feed, and a verified StoreKit edge function (`verify-purchase`).
- 10/10 unit tests green: `HerePracticeTests`, `MeditationTimerModelTests`, `MeditationSessionStoreTests`.
- Today's migration `20260426000001_here_three_leg_practice.sql` shipped to production *before* the iOS build that depends on it — disciplined release order.
- Cross-platform foundation: Kotlin Multiplatform scaffold, Android Compose scaffold, shared content layer in `shared/content/`.
- Real auth (no demo-only): email/password, anonymous guest mode, Sign in with Apple (Services ID `com.traddifftech.apieceofwhole.web`, JWT-signed nonces).

**Live demo (90 seconds, screen-mirrored):**
1. Launch app — title "Here" appears on home screen, sage-on-cream theme, three-tab structure.
2. **Self tab** → tap *Return to yourself* → write one sentence ("Took three breaths before opening my email") → save → show it persists on reload.
3. **Together tab** → tap *Be a grounding presence* → save a reflection.
4. **Community tab** → *Step outward locally* → save a reflection.
5. **Practice tab → meditation timer** → 1-minute session → audio plays in background, completion notification fires.
6. **Why I'm Here / Why We're Here** → opt-in anonymous excerpt, public feed reads it back via the SECURITY DEFINER RPC. *This is the crowd-pleaser.*

**Backup plan if Wi-Fi flakes:** simulator running locally, screen-mirrored, with seeded data. Screenshots in `assets/judging/` as fall-back.

### B. Problem–solution fit (does it solve a real problem?) — target 9/10

**The problem (one slide):**
- US adult anxiety prevalence: ~19% (NIMH).
- Pew 2024: 65% of Americans say they "always or often feel exhausted" by political news.
- The wellness market is a $7T industry but its top apps are **single-scale**: regulate yourself, alone, with headphones in.
- Civic engagement apps optimize for outrage and turnout, not capacity. People burn out.

**The insight:** the *same dysregulation* that drives personal anxiety drives relational rupture and civic withdrawal. Treating one in isolation is why the others don't get better.

**The local angle (Rapid City):** SD Mines, Elevate RC, Wildfire Labs, IndigiGenius — every host of this hackathon is doing layered work. Here is built for people who already feel that the work is connected and want a tool that doesn't pretend it isn't.

**Who feels this acutely:**
- Healthcare workers, teachers, caregivers — high relational load, low recovery time.
- Young professionals who care about civic life but won't touch partisan apps.
- Practitioners (Nicole's clientele) running breathwork, MBSR, and somatic groups who need a between-session container.
- Native and rural communities historically excluded from "wellness" framings.

### C. Innovation & feasibility (creative and achievable?) — target 9/10

**What's genuinely new:**
- **Three-leg architecture** (Self → Together → Community) as the *primary* navigation, not a feature inside a wellness app. Most apps default to a single layer; Here makes the layered framework the product.
- **"Why I'm Here" / "Why We're Here"** — opt-in anonymous excerpts. You write yours privately. You can choose to share. You see the public feed of others. **No usernames, no reactions, no algorithmic ranking.** Civic-style transparency without the surveillance economics.
- **Co-regulation** (relational, between two nervous systems) is treated as a first-class practice, not a Calm-style add-on. Most wellness apps cannot ship co-regulation because they have no relational primitive.
- **Nonpartisan civic layer** — values-based local participation, not red/blue sorting. The Community leg is *land, neighbor, local intention* — not "call your senator."
- Built on a working philosophy authored by Nicole Stone (April 2026), grounded in Bateson's *"The human individual is in some degree a fiction"* and decades of nervous-system + somatic research.

**Why it's feasible (already done):**
- Backend: live on Supabase, 9 migrations applied, RLS audited.
- iOS: TestFlight build 5 today.
- Distribution path: ASC pipeline working, Apple-signed, exportable to public TestFlight in one click.
- Cost structure: Supabase free tier handles thousands of users; StoreKit handles monetization at the OS level.
- Monetization: 8-week cohort `apow.cohort.8week` already wired through `verify-purchase` edge function — revenue mechanic is live, not theoretical.
- Team: existing studio (Trad Diff) with Dharma Wellness as a sister business — practitioner network is already there.

### D. Demo & presentation quality (clear vision?) — target 10/10

**Three-act structure (5-minute slot):**

| Time | Beat | One-line script |
|------|------|----------------|
| 0:00–0:45 | Hook | *"Wellness apps fix you. Civic apps burn you out. Nothing connects them — even though they're the same problem."* |
| 0:45–1:30 | Thesis | *"The health of the self, our relationships, and our communities are the same work at different scales."* — show the three tabs. |
| 1:30–3:30 | Live demo | Walk through Self → Together → Community → Why We're Here → Practice timer. Real device. |
| 3:30–4:15 | What we built this weekend | Show today's commits: meditation timer + three-leg architecture + Why I'm Here / Why We're Here + Supabase migration. |
| 4:15–5:00 | Ask + close | *"We're shipping to TestFlight today. We want users in this room. Try it. Tell us what's true and what isn't."* |

**Visual aids (one slide each):**
1. Title — *Here · We are each a piece of something whole.*
2. The problem (3 stats above).
3. The thesis (one sentence, sage on cream).
4. The architecture (three-leg diagram: Self foundation, Together soul, Community invitation outward).
5. **Live demo — no slide.**
6. What's already real (TestFlight badge, Supabase logo, "9 migrations · RLS on every table · 10/10 tests").
7. The ask: *Try the build. Sign up to be in cohort 1.*

**Things that will NOT happen:**
- No reading slides aloud.
- No "we plan to" / "we will" — only "this works, here, now."
- No partisan framing of the Community leg.
- No mention of Codex/Claude as the *product* — they're the tools.

---

## 3. Team & attribution

| Role | Name | Contribution |
|------|------|-------------|
| Working philosophy | **Nicole Stone** | Author of the layered framework (Self / Together / Community / Agency / Civic), April 2026. Practitioner of breathwork and somatic work at Dharma Wellness Institute. |
| Engineering & design | **Rory Stone** | Founder, Traditionally Different LLC. iOS/Swift, Supabase, Apple developer accounts, App Store pipeline. |
| AI pair-programming | OpenAI Codex (Sonnet 4.6) + Claude Opus 4.7 (1M ctx) | Per the hackathon's "bring your own AI tools" rule. AI accelerates implementation; the philosophy and product decisions are human. |
| Studio | **Trad Diff** + **Dharma Wellness Institute** | Sister entities. Trad Diff ships product; Dharma supplies the practitioner network and content backbone. |

---

## 4. What we built this weekend (technical timeline)

**Friday evening — 6 PM pitch:** Pitched *Community Moments* (cycling app extension of StoneBC). Got constructive feedback that the deeper opportunity wasn't routing — it was the relational-civic layer underneath.

**Saturday — pivot to Here:**
- Three-leg architecture committed (`HereLeg` enum: Self / Together / Community).
- `HerePromptCatalog` — daily prompts authored from Nicole's working philosophy.
- `MainTabView` rebuilt around the three legs.
- Supabase migration drafted: `daily_practice_entries`, `shared_reflection_excerpts`, `public_shared_reflection_excerpts()` RPC.
- `WhyIHereView` + `WhyWereHereView` — private application reflections + opt-in public excerpts.

**Sunday morning — meditation timer + ship:**
- Meditation timer feature: 9 Swift files, AVFoundation audio in background mode, UNUserNotifications, UserDefaults session history.
- Accessibility audit on timer pause control.
- 10/10 unit tests passing.
- Migration `20260426000001_here_three_leg_practice.sql` pushed to **production** Supabase.
- `CURRENT_PROJECT_VERSION` bumped 4 → 5.
- Branch merged to `main`. Archived. Uploaded to App Store Connect at **12:58 MDT** — accepted.

**Sunday 13:20 MDT:** Scheduled remote agent confirmed TestFlight processing → Ready to Test.

**Sunday 14:00 MDT:** This presentation.

---

## 5. The architecture — one diagram, four bullets

```
                    ┌─────────────────────────────┐
                    │            HERE             │
                    │  We are each a piece of     │
                    │     something whole.        │
                    └──────────────┬──────────────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        ▼                          ▼                          ▼
   ┌─────────┐              ┌─────────────┐             ┌────────────┐
   │  SELF   │              │  TOGETHER   │             │ COMMUNITY  │
   │         │              │             │             │            │
   │ Body,   │              │ Co-reg,     │             │ Land,      │
   │ breath, │ ←──── ↔ ────→│ attune,     │←──── ↔ ────→│ neighbor,  │
   │ return  │              │ presence    │             │ local act  │
   └─────────┘              └─────────────┘             └────────────┘
   The foundation             The soul              The invitation outward
```

- **Self** (`figure.mind.and.body`) — daily prompt: *Return to yourself.*
- **Together** (`person.2`) — daily prompt: *Be a grounding presence.*
- **Community** (`leaf`) — daily prompt: *Step outward locally.*
- **Practice** — meditation timer with audio in background. The body comes first.

---

## 6. The "Why We're Here" feature (the wow moment)

This is the part judges will lean forward for.

- Every user fills out a one-time application — *what motivated me, what change I hoped for, how I heard about Here.*
- Their answers stay private by default.
- They can opt to share an **anonymous** excerpt (no name, no avatar, no social graph).
- The shared excerpts surface in **Why We're Here** — a public feed visible to everyone (including non-users via the public RPC).

**Why this matters as innovation:**
- It's transparency without surveillance. You see the *why* of a community without ever seeing *who*.
- It's civic-grade publication patterns (e.g., comment periods, public testimony) ported into a wellness primitive.
- It cannot be gamed for likes or virality because there is no like, follow, or share button.
- The default is private. The act of sharing is intentional. This inverts the social-media default.

**Live demo line:** *"This is what 'civic, but rooted in care' looks like in product form."*

---

## 7. What "real product" looks like (proof, not vibes)

| Concern | Evidence |
|---------|----------|
| Does it run? | TestFlight build 5 of 1.0 — uploaded **today** at 12:58 MDT. |
| Is the backend real? | Supabase project `gtpeyindgjhegldrdrrb`. 9 migrations applied. RLS on every table. SECURITY DEFINER RPC for public reads. |
| Tests? | 10/10 unit tests passing. `HerePracticeTests`, `MeditationTimerModelTests`, `MeditationSessionStoreTests`. |
| Auth? | Email + password, anonymous guest, Sign in with Apple (full nonce-signed flow). |
| Monetization? | StoreKit `apow.cohort.8week`. Edge function `verify-purchase` validates signed transactions and creates entitlements. Revenue mechanic is live, not theoretical. |
| Privacy posture? | Default-private daily reflections. Sharing is opt-in, anonymous, and revocable. ITSAppUsesNonExemptEncryption declared. |
| Accessibility? | VoiceOver labels and identifiers throughout. Specific accessibility commit on the timer pause control. WCAG AA contrast on sage primary (5.16:1). |
| Local hosts? | Built by a Rapid City founder, philosophy by a Rapid City practitioner, sponsored studios are SD-incorporated (SP854VZ979). |

---

## 8. The ask

> "If you're a judge, score it. If you're a builder, try the TestFlight build — we'll add you to the link tonight. If you're a practitioner, talk to Nicole about cohort 1. We're not asking for permission to start. We started. We're asking for the next forty people."

**Concrete contact:**
- TestFlight invite — email rory@traddiff.com
- Practitioner inquiries — nicole@dharmawellnessinstitute.com (Dharma Wellness Institute)
- Trad Diff — traddiff.com

---

## 9. Anticipated questions + answers

| Q | A |
|---|---|
| "How is this different from Calm/Headspace?" | They stop at Self. We don't. The Together and Community legs *cannot* exist inside a single-scale wellness app — they require a relational primitive and a public-without-surveillance primitive. |
| "How is this different from a civic engagement app?" | We don't sort by team. The Community leg is *land, neighbor, local intention.* No partisan framing. No outrage loops. |
| "What stops it from becoming another social feed?" | No likes. No follows. No usernames in the public feed. Default-private. The only public artifact is an anonymous excerpt the user chose to publish. |
| "Why three legs and not five?" (Nicole's full framework has Agency + Civic too) | Five legs is the philosophy. Three tabs is the product surface for cohort 1. Agency and Civic are layered into the existing tabs (e.g., Civic lives inside Community). Adding more tabs hurts cognitive load; the philosophy can fit inside fewer surfaces. |
| "What if someone shares something harmful in the public feed?" | Excerpts are 1–500 chars, opt-in, revocable. The RPC reads only `is_active = true`. Moderation tooling is on the roadmap; the rate of public sharing is intentionally low (one per source-type per user). |
| "How do you make money?" | 8-week guided cohorts via StoreKit. Cohort apply → enroll → curriculum + check-ins + circle shares. Edge function validates Apple-signed receipt and writes the entitlement. Already wired. |
| "Did AI write the app?" | AI wrote a lot of code, fast. Humans wrote the philosophy, the product decisions, the safety posture, and signed the App Store binary. Per the hackathon rule that says "bring your own AI tools" — we did. |
| "Is this just a Dharma Wellness app in disguise?" | Dharma Wellness is one practitioner network. Here is the surface. They're sister businesses. The architecture supports many practitioners and many cohorts; Dharma is cohort 1. |

---

## 10. One-liner cheat-sheet (memorize three of these)

- *We are each a piece of something whole.*
- *Self, Together, Community — the same work at different scales.*
- *Civic transparency without surveillance.*
- *Wellness apps regulate you alone. Here regulates you in relationship.*
- *Self is the foundation. Together is the soul. Community is the invitation outward.*
- *We didn't pitch a finished idea. We pitched a finished practice.*
- *The default is private. The act of sharing is intentional.*
- *Build by Friday's plan. Ship by Sunday's truth.*

---

## 11. Logistics — day-of presentation

| Item | Detail |
|------|--------|
| Time slot | Sunday Apr 26, 2:00–3:30 PM at DLAB. |
| Hardware | iPhone 17 Pro (`00008150-00115D391EC0401C`), Lightning/USB-C cable, MacBook for screen-mirror via QuickTime, 1080p HDMI adapter. |
| Backup demo | iPhone 17 Pro Max simulator running build 5 locally + screenshot deck in `assets/judging/`. |
| Connectivity | Local hotspot from iPhone if DLAB Wi-Fi misbehaves. Demo doesn't require internet for the timer or local reflection saves; only the public feed needs network. |
| Slides | One-page HTML deck under `presentation/here-pitch.html` (to be generated from this file via `/present`). |
| Handout | One-pager printable PDF — pull from this file (sections 1, 2, 5, 8). |

---

## 12. Post-event follow-up

| Action | When | Owner |
|--------|------|-------|
| Add new TestFlight testers from interest sheet | Sunday evening | Rory |
| Capture judge feedback verbatim | During Q&A | whoever is not demoing |
| Send thank-you note to Elevate RC + SD Mines + Wildfire Labs + IndigiGenius | Monday Apr 27 | Rory |
| Decide: ship to App Store as 1.0 build 5, or accumulate testers and ship 1.1? | Tuesday Apr 28 | Rory + Nicole |
| Update `MASTERPROJ.md` priority stack with hackathon outcome | Sunday night | Rory |

---

## Appendix A — Source file pointers (for the technical judge who wants to look)

| File | What's there |
|------|-------------|
| `ios/APieceOfWhole/APieceOfWhole/Core/Models/HerePractice.swift` | `HereLeg`, `HerePrompt`, `HerePromptCatalog`, `DailyPracticeEntry`, `SharedReflectionExcerpt` types. |
| `ios/APieceOfWhole/APieceOfWhole/Features/Tabs/Here/HereLegViews.swift` | `SelfView`, `TogetherView`, `CommunityView` — the three-leg surface. |
| `ios/APieceOfWhole/APieceOfWhole/Features/Tabs/Here/WhyHereView.swift` | `WhyIHereView` (private application + opt-in share) + `WhyWereHereView` (public anonymous feed). |
| `ios/APieceOfWhole/APieceOfWhole/Features/Tabs/Practice/Timer/MeditationTimerView.swift` | Meditation timer flow — countdown, audio, completion notification, exit alert. |
| `ios/APieceOfWhole/APieceOfWhole/Core/Supabase/SupabaseService.swift` | New: `fetchTodayDailyPracticeEntry`, `saveDailyPracticeEntry`, `fetchPublicSharedReflectionExcerpts`, etc. |
| `supabase/migrations/20260426000001_here_three_leg_practice.sql` | Production migration. RLS owner-only on writes. SECURITY DEFINER read RPC. |
| `ios/APieceOfWhole/APieceOfWhole/Core/Content/POWPhilosophy.swift` | The working-philosophy strings — Bateson quote, thesis, three-leg copy. |

## Appendix B — Bateson quote (for the open of the talk, optional)

> "The human individual is in some degree a fiction."
> — Gregory Bateson, Inaugural Eric Berne Lecture in Social Psychotherapy, March 1977.

Open with this if the room feels academic. Skip it if the room feels practical.
