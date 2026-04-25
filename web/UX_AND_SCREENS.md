# A Piece of Whole — UX & Screen Specifications

**Design system:** Calm editorial — clean typography, generous whitespace, muted natural palette, no dark patterns.
**Primary font:** System serif (Georgia fallback) for headings; system sans-serif for body.
**Color palette:** Off-white background (#F9F7F4), warm charcoal text (#2C2A28), sage accent (#7A9E7E), warm stone secondary (#C4A882), soft red for error/crisis (#C0392B).
**No icons required** for MVP — text labels preferred over ambiguous icons.

---

## Information Architecture

```
Public (unauthenticated)
├── / — Landing
├── /about — About
├── /how-it-works — How It Works
├── /cohorts — Browse Open Cohorts
├── /cohorts/[slug] — Cohort Detail
├── /apply — Application Form
├── /faq — FAQ
├── /contact — Contact
├── /terms — Terms of Service (placeholder)
├── /privacy — Privacy Policy (placeholder)
├── /crisis — Crisis Resources
└── /disclaimer — Not Therapy Disclaimer

Auth
├── /auth/login — Magic link login
├── /auth/verify — Check your email
└── /auth/callback — Supabase auth callback

Participant (authenticated, enrolled)
├── /home — Spiral dashboard
├── /practices — Practice library
├── /practices/[id] — Single practice
├── /journal — Journal home (list of entries)
├── /journal/new — New entry
├── /journal/[id] — View/edit entry
├── /circle — Cohort circle
├── /circle/share — New intentional share
├── /check-in — Weekly check-in
├── /civic — Civic modules
├── /civic/[id] — Single lesson
├── /my-piece — Personal progress
└── /settings — Account settings

Facilitator (authenticated, facilitator role)
├── /facilitator/cohorts — My cohorts
├── /facilitator/cohorts/[id] — Cohort overview
├── /facilitator/cohorts/[id]/circle — Circle view
├── /facilitator/cohorts/[id]/prompts — Manage weekly prompts
└── /facilitator/reports — Moderation queue

Admin (authenticated, admin role)
├── /admin — Dashboard
├── /admin/applications — Application queue
├── /admin/applications/[id] — Review application
├── /admin/cohorts — Manage cohorts
├── /admin/cohorts/new — Create cohort
├── /admin/cohorts/[id] — Edit cohort + curriculum
├── /admin/members — Member management
├── /admin/members/[id] — Member detail
├── /admin/content — Content CMS
├── /admin/content/practices — Manage practices
├── /admin/content/practices/new — Create practice
├── /admin/content/practices/[id] — Edit practice
├── /admin/content/civic — Manage civic lessons
├── /admin/content/civic/new — Create lesson
├── /admin/content/civic/[id] — Edit lesson
├── /admin/reports — All reports
└── /admin/reports/[id] — Report detail
```

---

## Public Funnel

### `/` — Landing

**Goal:** Communicate the essence of the app and drive applications.

**Sections (top to bottom):**
1. **Hero:** Full-width, calm. Headline: "From self to each other." Sub: 1–2 lines describing the journey. CTA button: "Apply to Join"
2. **What it is:** 3 short paragraphs — the inner work, the community, the civic grounding. No bullet lists.
3. **How it works (3 steps):** Apply → Get approved → Join your cohort. Simple numbered steps.
4. **Who it's for:** 3–4 sentences. Honest about who should not apply (not in crisis, 18+).
5. **Current cohorts:** Card row showing 1–3 open cohorts with name, dates, spots remaining. CTA: "See all cohorts"
6. **Footer:** Links to About, FAQ, Contact, Terms, Privacy, Crisis Resources. "A Piece of Whole is not therapy."

### `/about` — About

**Sections:**
1. The origin story (1–2 paragraphs — authentic, personal, brand voice)
2. The approach (somatic + psychological + civic — each explained simply)
3. The team / facilitation philosophy (can be minimal at launch)
4. CTA: Apply

### `/how-it-works` — How It Works

**Sections:**
1. The 8-week journey (week-by-week overview — themes, not full curriculum)
2. Your circle (what it is, privacy model explained plainly)
3. Practices (audio + text, self-paced within the week)
4. Civic modules (optional, non-partisan, why they're here)
5. FAQ teaser (top 3 questions with link to full FAQ)
6. CTA: Apply

### `/cohorts` — Browse Cohorts

**Layout:** Card grid. Each card shows:
- Cohort name
- Facilitator name
- Start date / end date
- Capacity (e.g., "8 of 12 spots filled")
- Status badge: Open / Waitlist / Closed
- CTA: "Learn more" → cohort detail

**Empty state:** "No cohorts open right now. Join the interest list." → email capture form.

### `/cohorts/[slug]` — Cohort Detail

**Sections:**
1. Cohort name + dates + facilitator
2. What this cohort focuses on (description)
3. Week-by-week overview (theme titles only — no spoilers)
4. Facilitator bio
5. Pricing (flat one-time fee, displayed clearly)
6. What's included
7. Apply CTA (links to /apply with cohort pre-selected)

### `/apply` — Application Form

**Fields:**
- Full name (required)
- Email (required)
- Which cohort? (dropdown of open cohorts, pre-selected from query param)
- Why are you applying? (textarea, min 100 chars — read by a human)
- Are you currently in active mental health crisis? (radio: Yes / No — if Yes: show crisis resources and block submission)
- I confirm I am 18 or older (checkbox — required)
- I understand this is not therapy or medical treatment (checkbox — required)
- How did you hear about us? (optional text)
- Submit

**On submit:**
- Show: "Thank you. Your application has been received. A human will review it and you'll hear from us within 48 hours."
- Email sent to admin (new application notification)
- Email sent to applicant (application received confirmation)

**Crisis block:** If user selects "Yes" to crisis question, replace form with: "We're glad you reached out. Right now, the most important thing is your safety. [Link to crisis resources page] We hope you'll apply when you're in a more stable place."

---

## Auth Screens

### `/auth/login`

- Email field + "Send magic link" button
- Brief explainer: "We'll email you a sign-in link — no password needed."
- Back to home link

### `/auth/verify`

- "Check your email. We sent a link to [email]. It expires in 1 hour."
- Option to resend

### `/auth/callback`

- Supabase handles token exchange; redirect to `/home` on success or `/auth/login?error=expired` on failure.

---

## Onboarding (new participant, first login)

**Step 1 — Welcome**
Full-screen, personal. "You made it. Welcome to [Cohort Name]." Short paragraph about what the next 8 weeks look like. Button: "Let's begin"

**Step 2 — Values agreement**
Scrollable list of community agreements (respect, confidentiality, non-advice, etc.). Checkbox: "I agree to practice these with my circle." Button: "I agree"

**Step 3 — How circles work**
Explains: what a circle is (your cohort), what intentional sharing means, that private journals are only yours. Button: "Got it"

**Step 4 — Privacy primer**
"Your check-ins and journal are completely private. Even your facilitator cannot see them. Only what you intentionally share reaches your circle." Button: "Understood"

**Step 5 — Ready**
"Your circle is waiting." Button: "Go to my home" → `/home`

Store `onboarding_completed_at` in `user_profiles` on step 5.

---

## Participant Screens

### `/home` — Spiral Dashboard

**Layout:** Single-column, generous spacing.

**Sections:**
1. **Greeting:** "Good morning, [first name]." Current date.
2. **This week:** Card with current week number, theme title, and circle prompt. Link to practice for this week.
3. **Check-in:** If not done this week: "How are you this week?" button → `/check-in`. If done: check mark + "Check-in complete."
4. **Your circle:** Preview of 2 most recent circle shares (truncated). Link to full circle.
5. **Practices:** "Explore this week's practice" → link to the week's practice.
6. **Civic:** "This week's civic moment" → link to the current civic lesson (optional, soft CTA).

### `/check-in` — Weekly Check-In

**Form (always private):**
- Mood score: 5-point visual scale (1 = very difficult, 5 = very good) — use words not emoji
- Body sensation: short text field ("Where do you feel this week in your body?")
- One word: single word field ("One word for this week")
- Optional note: textarea ("Anything you want to remember about this week?")
- Submit

**On submit:** "Check-in saved. Only you can see this." → redirect to `/home`

### `/practices` — Practice Library

**Layout:** Filterable list/grid.

**Filters:** Type (audio / text / both), Category (grounding / somatic / reflection / civic), Duration (under 5 min / 5–15 min / 15+ min)

**Practice card:** Title, category, duration, type badge (audio/text). Click → `/practices/[id]`

### `/practices/[id]` — Single Practice

**Sections:**
1. Title + category + duration
2. If audio: audio player (HTML5 `<audio>` with play/pause/scrub, signed Supabase Storage URL)
3. Text content (below or instead of audio)
4. "Mark as complete" button (tracked in a `practice_completions` table — optional for MVP)

### `/journal` — Journal Home

**Layout:** Reverse-chronological list of entries.
**Entry preview:** Date, first 100 chars of content, optional week number badge.
**"New entry" button** → `/journal/new`
**Empty state:** "Your journal is waiting. Write anything — it's only for you."

### `/journal/new` — New Journal Entry

**Fields:**
- Optional prompt shown at top (from current week's curriculum)
- Textarea (large, minimal chrome)
- "Save" button

**On save:** "Saved. Only you can read this." → return to journal list.

### `/journal/[id]` — View/Edit Entry

Read mode by default. Edit button → inline edit. Delete button with confirm.

### `/circle` — Cohort Circle

**Layout:** Reverse-chronological feed of intentional shares from cohort members.

**Share card:**
- Author name (or "Anonymous" if opted in)
- Week badge
- Content (full text — no truncation, this is intentional reading)
- Supportive comment count
- "Respond with support" button → expands inline comment field
- Report link (small, bottom right)

**Top of page:** Current circle prompt (from facilitator). "What do you want to share this week?" button → `/circle/share`

**Comment form (inline):**
- Textarea with guidance: "Respond with support — not advice, not fixes, just presence."
- Submit button

**Empty state:** "Your circle hasn't shared yet this week. You could go first."

### `/circle/share` — New Intentional Share

**Fields:**
- Content: textarea with prompt shown at top ("This week's prompt: [prompt text]")
- Post anonymously: toggle (default off)
- Warning: "This will be visible to everyone in your cohort and your facilitator. Your private journal is separate."
- "Share with my circle" button

**On submit:** Redirect to `/circle`

### `/civic` — Civic Modules

**Layout:** Card grid of available lessons.

**Civic lesson card:** Title, category, short description. Status badge: "New" / "Read"

**Intro block at top:** "Civic engagement is an optional, nonpartisan part of the practice. These lessons are here when you're ready — never required."

### `/civic/[id]` — Single Civic Lesson

Full markdown content rendered. Estimated reading time. Back link.

### `/my-piece` — Personal Progress

**Sections:**
1. **Journey:** Week X of 8. Progress bar.
2. **Practices:** [N] practices explored.
3. **Check-ins:** [N]-week streak. Calendar heatmap of check-in weeks.
4. **Circle:** [N] shares, [N] comments left.
5. **Civic:** [N] of 4 lessons read.

All data is personal — no peer comparison.

### `/settings` — Account Settings

- Display name (editable)
- Email (read-only)
- Notification preferences (email on: new comment, weekly prompt)
- Delete account (confirm modal — soft delete: deactivate, anonymize circle posts)

---

## Facilitator Screens

### `/facilitator/cohorts/[id]` — Cohort Overview

**Sections:**
1. Cohort name, dates, current week
2. Enrollment count (e.g., "9 of 12 enrolled")
3. This week's circle prompt + facilitator note
4. Recent circle activity (last 5 shares — links to full circle)
5. Check-in completion rate for this week (count only — not who, not content)
6. Links: Manage prompts | View circle | Report queue

### `/facilitator/cohorts/[id]/circle` — Facilitator Circle View

Same as participant circle view, but:
- Can see all shares including anonymous (anonymous still shown as "Anonymous")
- Can soft-delete posts/comments from moderation button (confirm modal)
- "Report to admin" button on any post

### `/facilitator/cohorts/[id]/prompts` — Manage Weekly Prompts

Table of weeks 1–8. Each row: week number, theme title, current circle prompt (editable), facilitator note (editable). Save button per row.

### `/facilitator/reports` — Moderation Queue

List of open reports assigned to this facilitator's cohorts. Each report: content preview, reason, reporter (anonymous), action buttons (Remove / Warn / Dismiss / Escalate to Admin).

---

## Admin Screens

### `/admin` — Dashboard

**At-a-glance cards:**
- Pending applications (count + link)
- Open cohorts (count + link)
- Members (total enrolled)
- Open reports (count + link)

### `/admin/applications` — Application Queue

**Tabs:** Pending | Approved | Rejected | Waitlisted

**Table columns:** Name, Email, Cohort, Applied date, Status, Actions

**Row actions:** View | Approve | Reject | Waitlist

### `/admin/applications/[id]` — Review Application

Full application details. Cohort info. Admin notes field. Action buttons: Approve / Reject / Waitlist. On approve → trigger payment email to applicant.

### `/admin/cohorts` — Manage Cohorts

Table of all cohorts. Create new button. Columns: Name, Facilitator, Dates, Enrolled/Capacity, Status, Actions.

### `/admin/cohorts/new` + `/admin/cohorts/[id]` — Create/Edit Cohort

**Fields:** Name, Description, Facilitator (user search), Capacity, Start date, End date, Is open (toggle), Is active (toggle).

**Curriculum tab:** 8-week table. Each row: week number, title, theme, practice (select from library), circle prompt, facilitator note. "Load starter curriculum" button → pre-fills from default 8-week curriculum.

### `/admin/members/[id]` — Member Detail

Profile info. Enrollment history. Role selector (participant / facilitator / admin). Active toggle. Suspension note. "Send email" button (opens draft in Resend or mailto).

### `/admin/content/practices` — Manage Practices

Table of all practices. Published/draft toggle inline. Create, edit, delete actions.

### `/admin/content/practices/new` + `/[id]` — Create/Edit Practice

**Fields:** Title, Description, Type (audio/text/both), Duration (minutes), Category, Tags, Audio upload (Supabase Storage), Text content (markdown editor), Published toggle.

### `/admin/content/civic` — Manage Civic Lessons

Same pattern as practices but without audio. Fields: Title, Description, Category, Tags, Content (markdown editor), Published toggle.

### `/admin/reports` — All Reports

All reports across all cohorts. Same columns as facilitator reports view + Cohort column. Full action set.

---

## Global Components

### Navigation (authenticated)

**Mobile:** Bottom tab bar — Home, Practices, Circle, Journal, More (→ slide-up sheet with: My Piece, Civic, Settings, Sign out)

**Desktop:** Left sidebar — same items as tabs + cohort name displayed.

**Role-based additions:**
- Facilitator: "Facilitator" link in More / sidebar
- Admin: "Admin" link in More / sidebar (separate from participant experience)

### Crisis Banner

Persistent, subtle banner in footer of all pages (public and authenticated): "If you're in crisis, please reach out. [Crisis Resources →]"

### Error States

- 404: Calm, on-brand. "This page doesn't exist. [Go home →]"
- 403: "You don't have access to this. [Contact us]"
- 500: "Something went wrong on our end. We've been notified. [Try again]"

### Loading States

Skeleton loaders for content lists. Spinner for form submissions. Never block UI unnecessarily.

### Toast Notifications

Minimal, top-right toasts for: save confirmation, error, share posted, comment posted. Auto-dismiss 4 seconds.
