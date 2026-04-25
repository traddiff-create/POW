# A Piece of Whole — Product Specification

**Version:** 1.0 MVP | **Updated:** 2026-04-24 | **Legal entity:** Trad Diff LLC | **Brand:** A Piece of Whole (standalone)

---

## Vision

A Piece of Whole is a structured online community for adults 18+ who are ready to move from surviving to participating — from self-regulation to co-regulation, from isolation to agency, from overwhelm to grounded civic presence.

The app guides participants through facilitated cohort experiences that combine somatic and psychological practices, peer circles, and accessible civic education. The goal is not therapy, not activism, and not self-help — it is a practice community that holds space for both the inner life and the outer world as inseparable.

---

## Audience

**Primary:** Adults 18+ in the United States who:
- Are in a stable phase of personal growth (not in active crisis)
- Want community but need structure to feel safe in it
- Feel disconnected from civic life or overwhelmed by it
- Are drawn to somatic, mindfulness, or IFS-adjacent approaches
- Have done some personal work but feel isolated in it

**Not for:**
- People in acute mental health crisis (explicit disclaimer at apply step)
- Children or minors (hard gate: 18+ confirmation at signup)
- Clinical treatment or therapy (clearly stated in legal copy)

---

## MVP Scope

### In Scope

**Public funnel**
- Landing, About, How It Works, Cohorts, Pricing, FAQ, Contact pages
- Apply CTA on every public page
- Legal placeholder pages: Terms of Service, Privacy Policy, Crisis Resources, Disclaimer

**Enrollment**
- Application form (name, email, motivation, safety screen, age confirmation)
- Admin review queue (approve / reject / waitlist)
- Approval email → Stripe one-time payment link
- Stripe webhook → cohort access granted

**Participant experience**
- Email magic-link auth (Supabase)
- Onboarding: welcome, values agreement, how circles work, privacy primer
- Home: spiral dashboard (weekly module, current practice, check-in prompt)
- Weekly check-in (mood, body sensation, one word, optional note — always private)
- Practice library: audio + text practices, filterable by type and duration
- Personal journal: private entries with prompts, never shared unless participant chooses
- Intentional share: participant shares a reflection to their cohort circle
- Circle: feed of intentional shares from cohort members; supportive comments
- My Piece: personal progress view (weeks completed, practices done, check-in streak)
- Civic modules: 4 static U.S. local civics lessons (non-partisan, values-based)

**Facilitator tools**
- Cohort overview: member list, circle activity, week progress
- Weekly prompt management (set or edit the week's circle prompt)
- Facilitator guidance notes per week (read-only for participants)
- Report queue: review flagged circle posts/comments, take action (remove / warn / escalate)

**Admin panel**
- Application review: view, approve, reject, waitlist, email applicant
- Cohort management: create, name, set dates, assign facilitator, set capacity
- Content CMS: practices (audio/text), prompts, civic lessons, circle guides, cohort curriculum
- Member management: view users, change roles, suspend accounts
- Reporting: cohort enrollment counts, application status summary, basic usage metrics

**Email notifications (via Resend)**
- Application received (to admin)
- Application approved — includes payment link (to applicant)
- Application rejected (to applicant)
- Payment confirmed — includes cohort access link (to participant)
- Weekly cohort prompt (to all cohort participants)
- New circle share comment (to author of share)
- Report action taken (to facilitator/admin)

**PWA**
- Installable on iOS and Android home screen
- Offline: landing page and cached practice content accessible without network
- Push notification placeholder (infrastructure only, not full implementation)

---

### Non-Goals (v1)

| Item | Reason |
|------|--------|
| In-app AI features | Excluded for v1 — content is human-curated |
| Live civic API integrations | Static content only — no Cicero, Google Civic, etc. |
| Video calls or live sessions | Out of scope — async community only |
| Stripe subscriptions | One-time cohort purchase only |
| Mobile native apps (iOS/Android) | PWA first; native planned in parallel repo |
| Social login (Google, Apple) | Email magic link only |
| Community DMs or private messaging | Circle is shared space only; no 1:1 messaging |
| Gamification or points | Not aligned with tone |
| Third-party analytics beyond basic metrics | Privacy-first; no GA, no Mixpanel |

---

## Success Criteria (MVP Launch)

| Metric | Target |
|--------|--------|
| First paid cohort enrollment | ≥ 8 participants |
| Application → payment conversion | ≥ 60% of approved applicants pay |
| Weekly check-in completion rate | ≥ 70% of enrolled participants per week |
| Circle share rate | ≥ 40% of participants share at least once per cohort |
| Admin application review time | < 48 hours from submission to decision |
| Zero privacy incidents | Private journals never visible to unauthorized users |
| PWA installability | Passes Lighthouse PWA audit (score ≥ 90) |

---

## Product Principles

1. **Privacy is structural, not a setting.** Private data must be architecturally impossible to leak — not just hidden behind a toggle.
2. **Calm by default.** No dark patterns, no urgency triggers, no red badges for anxiety-inducing counts.
3. **The facilitator holds the space; the app holds the structure.** The app never replaces human facilitation.
4. **Civic engagement is optional and never partisan.** Civic modules are available, not required, and are explicitly nonpartisan.
5. **Safety over growth.** We will turn away applicants who are not ready, even at the cost of revenue.
6. **Build trust before building features.** Ship a small, excellent, complete experience. No half-finished modules.

---

## Legal & Safety Notes

- All legal copy (Terms, Privacy Policy) is **placeholder text marked for attorney review** before launch.
- A crisis resources page links to 988 (Suicide & Crisis Lifeline), Crisis Text Line, and NAMI.
- The app includes a prominent disclaimer: this is not therapy, not medical advice, not a substitute for professional mental health treatment.
- Age gate: participants must confirm they are 18+ at application. No minors.
- The Trad Diff LLC entity holds legal responsibility; "A Piece of Whole" is the brand identity.
