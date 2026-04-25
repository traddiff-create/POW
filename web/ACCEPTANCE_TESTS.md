# A Piece of Whole — Acceptance Tests

**Format:** Scenario-based. Each scenario describes the actor, preconditions, steps, and expected outcome. These are end-to-end tests — they verify product behavior, not just unit behavior.

---

## Public Visitor Scenarios

### V-01: Visitor understands the app from the landing page

**Actor:** Unauthenticated visitor
**Steps:**
1. Navigate to `/`
2. Read the hero, "what it is", and "how it works" sections
3. Look at cohort cards
4. Click "Apply to Join"

**Expected:**
- Landing page loads in < 3 seconds
- No sign-in required to view any public page
- Cohort cards show name, dates, available spots
- "Apply to Join" navigates to `/apply`
- Footer shows crisis resources link on every public page

---

### V-02: Visitor views cohort detail

**Actor:** Unauthenticated visitor
**Steps:**
1. Navigate to `/cohorts`
2. Click a cohort card
3. Review cohort detail page

**Expected:**
- Cohort name, facilitator name, dates, capacity, description visible
- Week-by-week overview shows theme titles only (not prompts or practices)
- Apply CTA pre-populates cohort in application form (via query param)

---

### V-03: Visitor in crisis is blocked from applying and redirected to resources

**Actor:** Unauthenticated visitor
**Preconditions:** Crisis question is "Yes"
**Steps:**
1. Navigate to `/apply`
2. Fill out form fields
3. Select "Yes" to "Are you currently in active mental health crisis?"

**Expected:**
- Form is replaced with a compassionate message
- 988 Lifeline, Crisis Text Line, and NAMI links are displayed
- Submit button is hidden/disabled
- No application record is created in the database

---

### V-04: Visitor successfully submits an application

**Actor:** Unauthenticated visitor
**Steps:**
1. Navigate to `/apply`
2. Fill all required fields (name, email, cohort, motivation ≥ 100 chars, crisis = No, age checkbox, disclaimer checkbox)
3. Submit

**Expected:**
- Application record created with `status = 'pending'`
- Confirmation message shown: "Your application has been received. You'll hear from us within 48 hours."
- Email sent to admin with applicant details and link to review page
- Email sent to applicant confirming receipt

---

## Application Review Scenarios

### A-01: Admin reviews and approves an application

**Actor:** Admin
**Preconditions:** V-04 completed; admin is logged in
**Steps:**
1. Navigate to `/admin/applications`
2. Click pending application
3. Review application detail
4. Click "Approve"

**Expected:**
- Application `status` updated to `'approved'`
- `reviewed_by` and `reviewed_at` fields set
- Approval email sent to applicant with Stripe payment link
- Applicant disappears from Pending tab; appears in Approved tab

---

### A-02: Admin rejects an application

**Actor:** Admin
**Preconditions:** Pending application exists
**Steps:**
1. Navigate to `/admin/applications/[id]`
2. Optionally add admin note
3. Click "Reject"

**Expected:**
- Application `status = 'rejected'`
- Rejection email sent to applicant (with kind decline message)
- Admin note saved

---

### A-03: Admin waitlists an application

**Actor:** Admin
**Steps:** Navigate to application → click "Waitlist"

**Expected:**
- `status = 'waitlisted'`
- Waitlist email sent to applicant

---

## Payment Scenarios

### P-01: Approved applicant pays and gains cohort access

**Actor:** Applicant (approved)
**Preconditions:** A-01 completed; applicant receives approval email
**Steps:**
1. Open approval email
2. Click Stripe payment link
3. Complete payment on Stripe-hosted checkout
4. Return to app

**Expected:**
- Stripe sends `checkout.session.completed` webhook to `/api/webhooks/stripe`
- Webhook handler:
  - Verifies Stripe signature
  - Updates `payment.status = 'succeeded'`
  - Creates `enrollments` record
  - Creates `user_profiles` if user doesn't exist
  - Triggers Supabase magic link email to participant
  - Sends payment confirmation email via Resend
- Participant can sign in and access `/home` with cohort content visible

---

### P-02: Payment fails (card declined)

**Actor:** Applicant (approved)
**Steps:** Complete Stripe checkout with a declining test card

**Expected:**
- Stripe does not send `checkout.session.completed`
- No enrollment is created
- Applicant sees Stripe's standard payment failure screen
- `payment.status` remains `'pending'` or is updated to `'failed'` on `checkout.session.async_payment_failed`
- Applicant can retry via the same payment link (if not expired)

---

## Participant Scenarios

### PA-01: New participant completes onboarding

**Actor:** Participant (enrolled, first login)
**Steps:**
1. Click magic link from email
2. Complete 5-step onboarding flow (Welcome, Values, Circle, Privacy, Ready)

**Expected:**
- Each step advances on button click
- Cannot skip to step 5 directly
- On step 5 completion: `user_profiles.onboarding_completed_at` is set
- Redirected to `/home`
- Onboarding does not appear again on subsequent logins

---

### PA-02: Participant completes a weekly check-in

**Actor:** Participant (enrolled, onboarded)
**Steps:**
1. Navigate to `/home`
2. Click "How are you this week?"
3. Fill in mood (1–5), body sensation, one word, optional note
4. Submit

**Expected:**
- `check_ins` record created for current week
- `/home` shows check-in complete indicator
- Check-in does not appear on any other user's screen — ever
- Querying `check_ins` with a different user's auth token returns 0 rows (RLS test)

---

### PA-03: Participant writes a private journal entry

**Actor:** Participant
**Steps:**
1. Navigate to `/journal/new`
2. Write entry content
3. Save

**Expected:**
- `journal_entries` record created
- Entry visible only on participant's own journal page
- A different participant querying `journal_entries` with `user_id` of this participant returns 0 rows
- Facilitator querying `journal_entries` returns 0 rows
- Admin querying via app UI returns 0 rows (service-role bypasses RLS for technical ops only)

---

### PA-04: Participant completes a practice

**Actor:** Participant
**Steps:**
1. Navigate to `/practices`
2. Filter by category
3. Click a practice
4. Play audio (if audio practice) or read text
5. Mark as complete

**Expected:**
- Audio plays via signed URL (HTTPS, not raw S3)
- Text renders correctly (markdown → HTML)
- Practice visible to any enrolled participant (not just current cohort)

---

### PA-05: Participant intentionally shares a reflection to the circle

**Actor:** Participant
**Preconditions:** Enrolled in a cohort with other participants
**Steps:**
1. Navigate to `/circle/share`
2. Write reflection
3. Optionally toggle anonymous
4. Click "Share with my circle"

**Expected:**
- `circle_shares` record created
- Share visible on `/circle` to all cohort members (enrolled in same cohort)
- Share visible to facilitator
- If anonymous: author name shown as "Anonymous" (user_id still stored in DB for moderation)
- Share NOT visible to participants of other cohorts

---

### PA-06: Participant leaves a supportive comment on a circle share

**Actor:** Participant B (same cohort as share author)
**Steps:**
1. Navigate to `/circle`
2. Click "Respond with support" on a share
3. Write comment
4. Submit

**Expected:**
- `circle_comments` record created
- Comment visible to all cohort members
- Share author receives in-app notification ("Someone responded to your share")
- Comment NOT visible to members of other cohorts

---

### PA-07: Participant reads a civic lesson

**Actor:** Participant
**Steps:**
1. Navigate to `/civic`
2. Click a lesson

**Expected:**
- Lesson content renders (markdown → HTML)
- Estimated reading time displayed
- Intro block reminding user lessons are optional and nonpartisan is visible
- No prompt to share or complete — civic modules are fully self-paced

---

## Privacy Scenarios

### PR-01: Private journal is never visible to facilitator

**Actor:** Facilitator
**Preconditions:** Participant PA-03 has created a journal entry
**Steps:**
1. Facilitator navigates to cohort overview at `/facilitator/cohorts/[id]`
2. Clicks on member list
3. Clicks on a participant

**Expected:**
- No journal entries visible in facilitator UI
- Supabase direct query from facilitator session returns 0 rows from `journal_entries`

---

### PR-02: Private check-in is never visible to facilitator or peers

**Actor:** Facilitator + other participants
**Preconditions:** Participant PA-02 has completed check-in
**Steps:**
1. Facilitator views cohort check-in summary

**Expected:**
- Only aggregate count shown (e.g., "7 of 10 checked in this week")
- No individual check-in content (mood score, body sensation, note) visible
- Supabase query from facilitator session returns 0 rows from `check_ins`

---

### PR-03: Circle share from one cohort is invisible to another cohort

**Actor:** Participant from Cohort B
**Preconditions:** Participant from Cohort A has shared to Cohort A's circle
**Steps:**
1. Participant from Cohort B navigates to `/circle`

**Expected:**
- Only Cohort B's shares visible
- Cohort A's shares do not appear (RLS policy enforcement)

---

## Facilitator Scenarios

### F-01: Facilitator sets the weekly circle prompt

**Actor:** Facilitator
**Steps:**
1. Navigate to `/facilitator/cohorts/[id]/prompts`
2. Edit the prompt for the current week
3. Save

**Expected:**
- `cohort_curriculum.circle_prompt` updated
- New prompt appears at top of `/circle` for all cohort participants immediately

---

### F-02: Facilitator removes a harmful circle post

**Actor:** Facilitator
**Steps:**
1. Navigate to `/facilitator/cohorts/[id]/circle`
2. Click moderation button on a share
3. Confirm removal

**Expected:**
- `circle_shares.is_removed = true`
- Share disappears from all participant circle views immediately
- `reports` record updated with `action_taken`
- Participant who posted the share does not receive notification of removal (no re-traumatization)

---

### F-03: Facilitator escalates a report to admin

**Actor:** Facilitator
**Steps:**
1. Navigate to `/facilitator/reports`
2. Click "Escalate to Admin" on an open report

**Expected:**
- Report flagged in admin queue
- Admin receives in-app notification
- Report remains open until admin acts

---

## Admin Scenarios

### AD-01: Admin creates a new cohort with curriculum

**Actor:** Admin
**Steps:**
1. Navigate to `/admin/cohorts/new`
2. Fill fields (name, facilitator, dates, capacity)
3. Click "Load starter curriculum"
4. Review and save

**Expected:**
- `cohorts` record created
- 8 `cohort_curriculum` records created (weeks 1–8)
- Cohort appears on public `/cohorts` page if `is_open = true`
- Assigned facilitator can see cohort in their facilitator panel

---

### AD-02: Admin publishes a new practice

**Actor:** Admin
**Steps:**
1. Navigate to `/admin/content/practices/new`
2. Fill fields, upload audio file, set published = true
3. Save

**Expected:**
- `practices` record created with `is_published = true`
- Audio uploaded to `practices-audio` Supabase Storage bucket
- Practice visible in participant `/practices` library immediately
- Audio plays via signed URL (not public bucket URL)

---

## Payment & Security Scenarios

### S-01: Stripe webhook rejects invalid signature

**Steps:** Send POST to `/api/webhooks/stripe` with invalid `Stripe-Signature` header

**Expected:**
- Returns HTTP 400
- No database changes occur

---

### S-02: Unauthenticated user cannot access participant routes

**Steps:** Navigate to `/home`, `/journal`, `/circle`, `/check-in` without being logged in

**Expected:**
- Redirected to `/auth/login` with return URL preserved
- No data from Supabase returned

---

### S-03: Participant cannot access admin routes

**Steps:** Participant navigates to `/admin` or any `/admin/*` route

**Expected:**
- HTTP 403 or redirect to `/home`
- No admin data returned

---

## Responsive & PWA Scenarios

### R-01: App is installable as a PWA on iOS

**Steps:**
1. Open app in Safari on iOS
2. Tap Share → Add to Home Screen

**Expected:**
- App icon appears on home screen
- App opens in standalone mode (no Safari chrome)
- Splash screen displayed on launch

---

### R-02: App passes Lighthouse PWA audit

**Steps:** Run Lighthouse audit on production URL

**Expected:**
- PWA score ≥ 90
- App is installable
- Offline fallback page loads when network unavailable
- HTTPS enforced

---

### R-03: Key screens are usable on mobile (375px width)

**Screens to test:** Landing, Apply, Home, Circle, Journal/new, Check-in, Practice detail

**Expected:**
- No horizontal scroll
- Tap targets ≥ 44px
- Text readable without zooming
- Forms fill comfortably without keyboard overlap on key fields

---

## Safety & Legal Scenarios

### SL-01: Crisis resources are accessible from every page

**Steps:** Check footer on landing, about, apply, home, circle, journal

**Expected:**
- "Crisis Resources" link visible in footer on every page
- `/crisis` page loads 988 Lifeline, Crisis Text Line, and NAMI information

---

### SL-02: Disclaimer is prominent and accurate

**Steps:** Navigate to `/disclaimer`

**Expected:**
- Page states clearly: this is not therapy, not medical advice, not a substitute for professional mental health treatment
- Page is accessible without authentication
- Footer on every page links to disclaimer

---

### SL-03: Terms and Privacy Policy pages exist

**Steps:** Navigate to `/terms` and `/privacy`

**Expected:**
- Pages load with placeholder content
- Placeholder content is marked "DRAFT — FOR ATTORNEY REVIEW BEFORE LAUNCH"
- Pages are accessible without authentication
