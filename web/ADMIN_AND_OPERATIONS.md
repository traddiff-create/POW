# A Piece of Whole — Admin & Operations

---

## Admin Role Overview

Admins have full access to all platform functions. At launch, the initial admin is set by seeding a `user_profiles` row with `role = 'admin'` directly in Supabase (service-role operation or Supabase dashboard). There is no admin self-registration.

**Admin responsibilities:**
- Review and act on applications (approve / reject / waitlist)
- Create and manage cohorts
- Assign facilitators to cohorts
- Manage the content library (practices, civic lessons)
- Review escalated moderation reports
- Monitor enrollment and basic usage metrics

---

## Application Review Workflow

### Incoming Applications

1. Applicant submits form at `/apply`
2. Application saved to `applications` table with `status = 'pending'`
3. Resend email sent to admin (configured via `RESEND_FROM_EMAIL`): subject "New Application — [Name]", body includes name, email, cohort, motivation excerpt, link to `/admin/applications/[id]`
4. Admin sees pending count badge on `/admin` dashboard

### Review Actions

| Action | Result |
|--------|--------|
| **Approve** | `status = 'approved'`, `reviewed_by`, `reviewed_at` set. Email sent to applicant with Stripe payment link. |
| **Reject** | `status = 'rejected'`. Email sent to applicant with kind decline message and optional admin note. |
| **Waitlist** | `status = 'waitlisted'`. Email sent to applicant confirming they're on the waitlist. |

### Approval Email (sent via Resend)

**Subject:** "You're in — here's your next step"

**Body:**
```
Hi [Name],

We've reviewed your application to [Cohort Name] and we're glad to welcome you.

To secure your spot, please complete your payment here:
[Stripe payment link — single-use, 72-hour expiry]

Once payment is confirmed, you'll receive your sign-in link and cohort details.

If you have questions, reply to this email.

With care,
A Piece of Whole
```

### Rejection Email

**Subject:** "Your application to A Piece of Whole"

**Body:**
```
Hi [Name],

Thank you for applying to [Cohort Name]. After careful review, we aren't able to offer
you a spot in this cohort.

[Optional: brief, kind admin note — e.g., "We think this moment may call for
a different kind of support first."]

We hope you'll consider applying to a future cohort when the timing feels right.

With care,
A Piece of Whole
```

### Waitlist Email

```
Hi [Name],

Thank you for applying to [Cohort Name]. This cohort is currently full, but we've
added you to the waitlist. If a spot opens, you'll hear from us before the cohort begins.

We'll also let you know when new cohorts are scheduled.

With care,
A Piece of Whole
```

### SLA

Target: Review all pending applications within **48 hours** of submission. Applications older than 48 hours show an overdue indicator in the admin queue.

---

## Cohort Management

### Creating a Cohort

Admin fills `/admin/cohorts/new`:
- **Name:** e.g., "Spring Cohort 2026"
- **Description:** shown on public cohort detail page
- **Facilitator:** search existing users with `role = 'facilitator'`
- **Capacity:** typically 8–12 participants
- **Start date / End date:** 8-week span
- **Is open:** true = accepting applications; false = closed to new applications
- **Is active:** true = participants can access cohort content

### Loading the Starter Curriculum

On the cohort edit page, "Load starter curriculum" button pre-fills all 8 weeks from `CONTENT_AND_CURRICULUM.md` defaults. Admin can then edit any week before the cohort starts.

### Enrollment

Enrollment is created automatically by the Stripe webhook handler. Admin can also manually create an enrollment from the member detail page (for comps or exceptions).

### Cohort Lifecycle

| Status | `is_open` | `is_active` | Meaning |
|--------|-----------|-------------|---------|
| Accepting applications | true | true | Normal pre-cohort state |
| Full / closed to applications | false | true | Cohort running, no new applications |
| Cohort ended | false | false | Complete; participants retain read access for 90 days |

---

## Content CMS

All content is managed through the admin panel at `/admin/content`. No external CMS — Supabase is the database.

### Practices

**Fields:** Title, Description, Type (audio/text/both), Duration (minutes), Category, Tags, Audio file (upload → Supabase Storage `practices-audio` bucket), Text content (markdown), Published toggle.

**Audio files:**
- Upload via admin form → stored in `practices-audio` bucket
- Access via signed URLs (generated server-side, 1-hour expiry)
- Never store raw bucket URLs client-side

**Publishing:** Practices with `is_published = false` are invisible to participants. Use draft state for in-progress content.

### Civic Lessons

Same CMS as practices but without audio. Markdown content editor. Same publish/draft toggle.

### Cohort Curriculum

Managed per-cohort in `/admin/cohorts/[id]` on the Curriculum tab. 8-week table. Changes take effect immediately for enrolled participants.

---

## Facilitator Workflow

### Facilitator Assignment

Admin assigns a facilitator to a cohort at cohort creation or edit time. The assigned facilitator gains visibility into that cohort's circle and member list (not private journals or check-ins).

### Weekly Prompt Management

Facilitator sets or edits the week's circle prompt at `/facilitator/cohorts/[id]/prompts`. Change is immediate — displayed at top of `/circle` for all cohort members.

### Circle Facilitation Principles

See `CONTENT_AND_CURRICULUM.md` → Circle Guides section for detailed facilitation guidance.

### Escalation

If a facilitator encounters content beyond their capacity to handle (active crisis, potential harm), they use the "Escalate to Admin" action in the report queue. Admin receives a notification and takes over.

---

## Moderation Queue

### Report Flow

1. Participant clicks "Report" on a circle share or comment
2. Form: select reason (harmful content / off-topic / privacy concern / other) + optional note
3. Report saved to `reports` table with `status = 'open'`
4. Facilitator and admin receive in-app notification

### Facilitator Actions

| Action | Effect |
|--------|--------|
| Remove post/comment | Sets `is_removed = true` on share or comment; disappears from circle |
| Warn | Admin notes field; no automated action in MVP |
| Dismiss | `report.status = 'dismissed'`; no action taken |
| Escalate to admin | `report.status = 'open'` flagged for admin; admin notified |

### Admin Actions

Same as facilitator + can suspend member accounts.

### Crisis Protocol

If content indicates active crisis or intent to harm:
1. Remove content immediately
2. Reach out to participant via email (admin or facilitator)
3. Share crisis resources: 988 Lifeline, Crisis Text Line (text HOME to 741741), NAMI helpline
4. Escalate to admin if not already admin-reviewed
5. Document action in `reports.action_taken`

---

## Email Notifications (Resend)

All emails sent via Resend from `RESEND_FROM_EMAIL` (configured in env vars). At launch: `hello@apieceofwhole.com` or `hello@traddiff.com` pending domain setup.

| Trigger | Recipients | Template |
|---------|-----------|----------|
| Application submitted | Admin | "New application: [Name]" |
| Application approved | Applicant | "You're in — payment link" |
| Application rejected | Applicant | "Your application" |
| Application waitlisted | Applicant | "You're on the waitlist" |
| Payment confirmed | Participant | "Welcome — sign-in link + cohort info" |
| Weekly circle prompt | All cohort participants | "This week in [Cohort Name]: [prompt]" |
| New comment on share | Share author | "[Name] responded to your share" |
| Report actioned | Reporter | "We reviewed your report" |

**Weekly prompt email:** Sent via a Supabase scheduled function or Vercel cron job on Monday at 9am in the cohort's timezone. Includes current week's theme title and circle prompt.

**Email unsubscribe:** Include one-click unsubscribe for comment notification emails (required by CAN-SPAM). Application and payment emails are transactional — not subject to unsubscribe.

---

## Reporting & Metrics

### Admin Dashboard Metrics

Available at `/admin`:
- Total applications (pending / approved / rejected / waitlisted)
- Total enrolled participants by cohort
- Weekly check-in completion rate (% per cohort — no individual data)
- Circle share count per cohort per week
- Open report count

### Privacy Constraints on Metrics

- Never show admin: individual check-in content, journal entries, or who-shared-what at the individual level
- Aggregate counts only for check-ins
- Circle shares are individually visible to admin only for moderation purposes, not casual browsing

---

## Launch Checklist (Operations)

Before first cohort opens:

- [ ] Supabase project created, schema applied, RLS enabled and tested
- [ ] Supabase Storage buckets created with correct policies
- [ ] Stripe account active, products created (one per cohort price), webhook endpoint configured
- [ ] Resend domain verified, email templates configured
- [ ] Vercel project connected to GitHub repo, env vars set
- [ ] Admin account seeded (direct Supabase insert)
- [ ] At least one facilitator account created and assigned
- [ ] Starter curriculum loaded into first cohort
- [ ] At least 4 published practices in library
- [ ] At least 4 published civic lessons
- [ ] All legal placeholder pages live (Terms, Privacy, Disclaimer, Crisis Resources)
- [ ] Crisis banner visible on all pages
- [ ] PWA manifest and service worker configured
- [ ] Lighthouse PWA audit passes (score ≥ 90)
- [ ] End-to-end enrollment flow tested: apply → approve → pay → access
- [ ] Private journal RLS tested (confirm no cross-user access)
