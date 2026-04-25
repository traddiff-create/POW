# MASTER BUILD PROMPT — A Piece of Whole

**Copy and paste this entire prompt into Claude Code, ChatGPT, or another coding agent to scaffold and build the app.**

---

## Your Task

Build **A Piece of Whole** — a production Next.js PWA for adults 18+ moving through structured cohort experiences combining somatic practice, peer community, and civic engagement. This document is a complete build specification. Do not ask clarifying questions — all decisions are made. Build exactly what is described.

---

## Stack

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 15 (App Router, TypeScript) |
| Auth | Supabase Auth — email magic link only |
| Database | Supabase Postgres with Row-Level Security |
| Storage | Supabase Storage (audio files) |
| Payments | Stripe — one-time checkout sessions per cohort |
| Email | Resend |
| Deployment | Vercel |
| PWA | `@ducanh2912/next-pwa` |
| Styling | Tailwind CSS |
| Forms | React Hook Form + Zod |
| Markdown | `react-markdown` |

---

## Environment Variables

Create `.env.local` with:

```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=

RESEND_API_KEY=
RESEND_FROM_EMAIL=hello@apieceofwhole.com

NEXT_PUBLIC_APP_URL=http://localhost:3000
```

---

## Project Setup

```bash
npx create-next-app@latest web --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
cd web
npm install @supabase/supabase-js @supabase/ssr stripe @stripe/stripe-js resend react-hook-form zod @hookform/resolvers react-markdown @ducanh2912/next-pwa
```

---

## Directory Structure

```
web/
├── src/
│   ├── app/                          # Next.js App Router
│   │   ├── (public)/                 # Unauthenticated layout
│   │   │   ├── page.tsx              # Landing
│   │   │   ├── about/page.tsx
│   │   │   ├── how-it-works/page.tsx
│   │   │   ├── cohorts/
│   │   │   │   ├── page.tsx
│   │   │   │   └── [slug]/page.tsx
│   │   │   ├── apply/page.tsx
│   │   │   ├── faq/page.tsx
│   │   │   ├── contact/page.tsx
│   │   │   ├── terms/page.tsx
│   │   │   ├── privacy/page.tsx
│   │   │   ├── crisis/page.tsx
│   │   │   └── disclaimer/page.tsx
│   │   ├── (auth)/                   # Auth screens
│   │   │   ├── auth/login/page.tsx
│   │   │   ├── auth/verify/page.tsx
│   │   │   └── auth/callback/route.ts
│   │   ├── (app)/                    # Authenticated participant layout
│   │   │   ├── layout.tsx            # Auth guard + nav
│   │   │   ├── home/page.tsx
│   │   │   ├── check-in/page.tsx
│   │   │   ├── practices/
│   │   │   │   ├── page.tsx
│   │   │   │   └── [id]/page.tsx
│   │   │   ├── journal/
│   │   │   │   ├── page.tsx
│   │   │   │   ├── new/page.tsx
│   │   │   │   └── [id]/page.tsx
│   │   │   ├── circle/
│   │   │   │   ├── page.tsx
│   │   │   │   └── share/page.tsx
│   │   │   ├── civic/
│   │   │   │   ├── page.tsx
│   │   │   │   └── [id]/page.tsx
│   │   │   ├── my-piece/page.tsx
│   │   │   └── settings/page.tsx
│   │   ├── (facilitator)/            # Facilitator layout + auth guard
│   │   │   └── facilitator/...
│   │   ├── (admin)/                  # Admin layout + auth guard
│   │   │   └── admin/...
│   │   └── api/
│   │       ├── webhooks/
│   │       │   └── stripe/route.ts   # Stripe webhook handler
│   │       └── auth/
│   │           └── callback/route.ts
│   ├── components/
│   │   ├── ui/                       # Shared UI primitives
│   │   ├── forms/                    # Form components
│   │   ├── layout/                   # Nav, Footer, CrisisBanner
│   │   └── [feature]/               # Feature-specific components
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts             # Browser client
│   │   │   ├── server.ts             # Server client (cookies)
│   │   │   └── middleware.ts
│   │   ├── stripe.ts
│   │   ├── resend.ts
│   │   └── types.ts                  # Database types (generated from schema)
│   └── middleware.ts                 # Auth redirect middleware
├── public/
│   ├── manifest.json
│   └── icons/                        # PWA icons (192px, 512px)
└── next.config.ts
```

---

## Database Schema

Run this SQL in Supabase SQL Editor to create all tables:

```sql
-- Enable UUID extension
create extension if not exists "pgcrypto";

-- user_profiles
create table user_profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text not null,
  full_name   text,
  role        text not null default 'participant' check (role in ('participant', 'facilitator', 'admin')),
  is_active   boolean not null default true,
  onboarding_completed_at timestamptz,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- cohorts
create table cohorts (
  id              uuid primary key default gen_random_uuid(),
  name            text not null,
  slug            text not null unique,
  description     text,
  facilitator_id  uuid references user_profiles(id),
  capacity        int not null default 12,
  starts_at       date not null,
  ends_at         date not null,
  is_open         boolean not null default true,
  is_active       boolean not null default true,
  created_at      timestamptz not null default now()
);

-- applications
create table applications (
  id              uuid primary key default gen_random_uuid(),
  email           text not null,
  full_name       text not null,
  motivation      text not null,
  safety_screen   text not null,
  age_confirmed   boolean not null,
  cohort_id       uuid references cohorts(id),
  status          text not null default 'pending'
                    check (status in ('pending', 'approved', 'rejected', 'waitlisted')),
  admin_notes     text,
  reviewed_by     uuid references user_profiles(id),
  reviewed_at     timestamptz,
  how_heard       text,
  created_at      timestamptz not null default now()
);

-- payments
create table payments (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid references user_profiles(id),
  application_id      uuid references applications(id),
  cohort_id           uuid references cohorts(id),
  stripe_session_id   text unique not null,
  stripe_payment_id   text unique,
  amount_cents        int not null,
  currency            text not null default 'usd',
  status              text not null default 'pending'
                        check (status in ('pending', 'succeeded', 'failed', 'refunded')),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

-- enrollments
create table enrollments (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references user_profiles(id) on delete cascade,
  cohort_id       uuid not null references cohorts(id) on delete cascade,
  application_id  uuid references applications(id),
  payment_id      uuid references payments(id),
  enrolled_at     timestamptz not null default now(),
  unique (user_id, cohort_id)
);

-- practices
create table practices (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  description   text,
  type          text not null check (type in ('audio', 'text', 'both')),
  duration_min  int,
  category      text,
  audio_url     text,
  content       text,
  tags          text[],
  is_published  boolean not null default false,
  sort_order    int not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- cohort_curriculum
create table cohort_curriculum (
  id              uuid primary key default gen_random_uuid(),
  cohort_id       uuid not null references cohorts(id) on delete cascade,
  week_number     int not null check (week_number between 1 and 12),
  title           text not null,
  theme           text,
  practice_id     uuid references practices(id),
  circle_prompt   text not null,
  facilitator_note text,
  created_at      timestamptz not null default now(),
  unique (cohort_id, week_number)
);

-- check_ins (always private)
create table check_ins (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references user_profiles(id) on delete cascade,
  cohort_id       uuid not null references cohorts(id),
  week_number     int not null,
  mood_score      int check (mood_score between 1 and 5),
  body_sensation  text,
  one_word        text,
  note            text,
  created_at      timestamptz not null default now(),
  unique (user_id, cohort_id, week_number)
);

-- journal_entries (always private)
create table journal_entries (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references user_profiles(id) on delete cascade,
  cohort_id   uuid references cohorts(id),
  week_number int,
  prompt      text,
  content     text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- circle_shares
create table circle_shares (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references user_profiles(id) on delete cascade,
  cohort_id       uuid not null references cohorts(id),
  week_number     int,
  content         text not null,
  is_anonymous    boolean not null default false,
  is_removed      boolean not null default false,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- circle_comments
create table circle_comments (
  id          uuid primary key default gen_random_uuid(),
  share_id    uuid not null references circle_shares(id) on delete cascade,
  user_id     uuid not null references user_profiles(id) on delete cascade,
  cohort_id   uuid not null references cohorts(id),
  content     text not null,
  is_removed  boolean not null default false,
  created_at  timestamptz not null default now()
);

-- reports
create table reports (
  id              uuid primary key default gen_random_uuid(),
  reporter_id     uuid not null references user_profiles(id),
  share_id        uuid references circle_shares(id),
  comment_id      uuid references circle_comments(id),
  reason          text not null,
  status          text not null default 'open'
                    check (status in ('open', 'reviewed', 'actioned', 'dismissed')),
  reviewed_by     uuid references user_profiles(id),
  reviewed_at     timestamptz,
  action_taken    text,
  created_at      timestamptz not null default now()
);

-- civic_lessons
create table civic_lessons (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  description   text,
  content       text not null,
  category      text,
  tags          text[],
  is_published  boolean not null default false,
  sort_order    int not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- notifications
create table notifications (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references user_profiles(id) on delete cascade,
  type        text not null,
  title       text not null,
  body        text,
  link        text,
  is_read     boolean not null default false,
  created_at  timestamptz not null default now()
);

-- Enable RLS on all tables
alter table user_profiles enable row level security;
alter table cohorts enable row level security;
alter table applications enable row level security;
alter table payments enable row level security;
alter table enrollments enable row level security;
alter table practices enable row level security;
alter table cohort_curriculum enable row level security;
alter table check_ins enable row level security;
alter table journal_entries enable row level security;
alter table circle_shares enable row level security;
alter table circle_comments enable row level security;
alter table reports enable row level security;
alter table civic_lessons enable row level security;
alter table notifications enable row level security;
```

Then apply the RLS policies from `DATA_AND_PERMISSIONS.md`.

---

## Supabase Storage Setup

Create two storage buckets in the Supabase dashboard:

1. **`practices-audio`** — Private. Access via signed URLs only. Policy: allow authenticated users to read via signed URL; allow service-role to upload.
2. **`avatars`** — Public. Policy: allow authenticated users to upload their own avatar; allow public read.

---

## Stripe Configuration

1. Create a Stripe account
2. Create a Product for each cohort (or a single product with configurable price)
3. Add webhook endpoint: `https://yourdomain.com/api/webhooks/stripe`
4. Subscribe to events: `checkout.session.completed`, `checkout.session.async_payment_failed`
5. Copy webhook signing secret → `STRIPE_WEBHOOK_SECRET`

### Stripe Checkout Session (server action or API route)

```typescript
// src/app/api/checkout/route.ts
import Stripe from 'stripe'
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(req: Request) {
  const { cohortId, applicationId, email, priceId } = await req.json()

  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    payment_method_types: ['card'],
    customer_email: email,
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/auth/login?payment=success`,
    cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/apply`,
    metadata: { cohortId, applicationId },
  })

  return Response.json({ url: session.url })
}
```

### Stripe Webhook Handler

```typescript
// src/app/api/webhooks/stripe/route.ts
import Stripe from 'stripe'
import { createClient } from '@supabase/supabase-js'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!   // service role — bypasses RLS
)

export async function POST(req: Request) {
  const body = await req.text()
  const sig = req.headers.get('stripe-signature')!

  let event: Stripe.Event
  try {
    event = stripe.webhooks.constructEvent(body, sig, process.env.STRIPE_WEBHOOK_SECRET!)
  } catch {
    return new Response('Invalid signature', { status: 400 })
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object as Stripe.CheckoutSession
    const { cohortId, applicationId } = session.metadata!
    const email = session.customer_email!

    // Upsert user_profiles
    let { data: user } = await supabase
      .from('user_profiles')
      .select('id')
      .eq('email', email)
      .single()

    if (!user) {
      // Create Supabase auth user + profile
      const { data: authUser } = await supabase.auth.admin.createUser({ email, email_confirm: true })
      await supabase.from('user_profiles').insert({
        id: authUser.user!.id,
        email,
        role: 'participant',
      })
      user = { id: authUser.user!.id }
    }

    // Update payment record
    await supabase.from('payments').update({
      status: 'succeeded',
      stripe_payment_id: session.payment_intent as string,
      user_id: user.id,
      updated_at: new Date().toISOString(),
    }).eq('stripe_session_id', session.id)

    // Create enrollment
    await supabase.from('enrollments').upsert({
      user_id: user.id,
      cohort_id: cohortId,
      application_id: applicationId,
    })

    // Send magic link email
    await supabase.auth.admin.generateLink({
      type: 'magiclink',
      email,
      options: { redirectTo: `${process.env.NEXT_PUBLIC_APP_URL}/home` },
    })

    // Send confirmation email via Resend
    // ... (see Resend section below)
  }

  return new Response('ok', { status: 200 })
}
```

---

## Auth Middleware

```typescript
// src/middleware.ts
import { createServerClient } from '@supabase/ssr'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

const PROTECTED_PREFIXES = ['/home', '/check-in', '/practices', '/journal', '/circle', '/civic', '/my-piece', '/settings', '/facilitator', '/admin']

export async function middleware(req: NextRequest) {
  const res = NextResponse.next()
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { get: (name) => req.cookies.get(name)?.value, set: (name, value, options) => res.cookies.set({ name, value, ...options }), remove: (name, options) => res.cookies.set({ name, value: '', ...options }) } }
  )

  const { data: { user } } = await supabase.auth.getUser()
  const isProtected = PROTECTED_PREFIXES.some(p => req.nextUrl.pathname.startsWith(p))

  if (isProtected && !user) {
    const loginUrl = new URL('/auth/login', req.url)
    loginUrl.searchParams.set('redirectTo', req.nextUrl.pathname)
    return NextResponse.redirect(loginUrl)
  }

  return res
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|manifest.json|icons).*)'],
}
```

---

## Resend Email Setup

```typescript
// src/lib/resend.ts
import { Resend } from 'resend'
export const resend = new Resend(process.env.RESEND_API_KEY)

export async function sendApplicationReceived(adminEmail: string, applicant: { name: string; email: string; cohort: string; reviewUrl: string }) {
  await resend.emails.send({
    from: process.env.RESEND_FROM_EMAIL!,
    to: adminEmail,
    subject: `New Application — ${applicant.name}`,
    html: `<p>New application from <strong>${applicant.name}</strong> (${applicant.email}) for <strong>${applicant.cohort}</strong>.</p><p><a href="${applicant.reviewUrl}">Review application</a></p>`,
  })
}

export async function sendApprovalEmail(email: string, { name, cohort, paymentUrl }: { name: string; cohort: string; paymentUrl: string }) {
  await resend.emails.send({
    from: process.env.RESEND_FROM_EMAIL!,
    to: email,
    subject: "You're in — here's your next step",
    html: `<p>Hi ${name},</p><p>We've reviewed your application to <strong>${cohort}</strong> and we're glad to welcome you.</p><p>To secure your spot, please complete your payment:</p><p><a href="${paymentUrl}">Complete payment</a></p><p>This link expires in 72 hours. Once payment is confirmed, you'll receive your sign-in link.</p><p>With care,<br>A Piece of Whole</p>`,
  })
}

// Add: sendRejectionEmail, sendWaitlistEmail, sendPaymentConfirmed, sendWeeklyPrompt, sendCommentNotification
```

---

## PWA Configuration

```typescript
// next.config.ts
import withPWA from '@ducanh2912/next-pwa'

const nextConfig = withPWA({
  dest: 'public',
  cacheOnFrontEndNav: true,
  aggressiveFrontEndNavCaching: true,
  disable: process.env.NODE_ENV === 'development',
})({
  // your existing Next.js config
})

export default nextConfig
```

```json
// public/manifest.json
{
  "name": "A Piece of Whole",
  "short_name": "Piece of Whole",
  "description": "A community for co-regulation, practice, and grounded participation.",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#F9F7F4",
  "theme_color": "#7A9E7E",
  "icons": [
    { "src": "/icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icons/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

---

## Design System (Tailwind)

```typescript
// tailwind.config.ts
export default {
  content: ['./src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        background: '#F9F7F4',
        foreground: '#2C2A28',
        sage: '#7A9E7E',
        stone: '#C4A882',
        crisis: '#C0392B',
      },
      fontFamily: {
        serif: ['Georgia', 'Cambria', 'serif'],
        sans: ['system-ui', 'sans-serif'],
      },
    },
  },
}
```

**Design rules:**
- Headings use `font-serif`; body uses `font-sans`
- Background is `bg-background`; primary text is `text-foreground`
- Accent buttons use `bg-sage text-white`
- No shadows, no gradients — flat, calm, editorial
- Spacing uses Tailwind's 4-unit grid (p-4, p-8, gap-6, etc.)
- Max content width: `max-w-2xl mx-auto` for reading content; `max-w-4xl` for grids

---

## Admin Seeding

After deploying, seed the first admin directly via Supabase SQL Editor:

```sql
-- First: create the user in Supabase Auth dashboard, then:
update user_profiles
set role = 'admin'
where email = 'your-admin-email@example.com';
```

---

## Vercel Deployment

```bash
npx vercel --cwd web
# Set all env vars in Vercel dashboard → Project Settings → Environment Variables
# Add NEXT_PUBLIC_APP_URL=https://your-vercel-url.vercel.app
```

Configure Stripe webhook endpoint to your Vercel production URL after first deploy.

---

## Build Order for Agent

Build features in this sequence to minimize rework:

1. **Project scaffold** — `create-next-app`, install packages, Tailwind config, PWA config
2. **Supabase setup** — apply schema SQL, RLS policies, Storage buckets
3. **Auth** — magic link login, callback route, middleware, auth guard layout
4. **Public pages** — landing, about, how-it-works, cohorts (list + detail), apply, FAQ, crisis, legal placeholders
5. **Application flow** — apply form server action, admin email, confirmation email
6. **Admin panel** — application queue, approve/reject/waitlist actions, Stripe payment link generation
7. **Stripe** — checkout session API route, webhook handler, enrollment creation
8. **Participant onboarding** — 5-step flow, `onboarding_completed_at` gate
9. **Home + check-in** — spiral dashboard, weekly check-in form
10. **Practices** — library page, single practice (audio player + text), filters
11. **Journal** — list, new entry, view/edit, private RLS verification
12. **Circle** — feed, intentional share form, inline comments, report button
13. **Civic modules** — lesson list, single lesson (markdown)
14. **My Piece** — personal progress metrics
15. **Facilitator panel** — cohort overview, circle view, prompt management, report queue
16. **Admin CMS** — practices CRUD, civic lessons CRUD, cohort management, curriculum editor
17. **Email notifications** — all Resend templates wired up
18. **PWA audit** — verify manifest, service worker, offline fallback, Lighthouse ≥ 90
19. **Acceptance test pass** — verify all scenarios in `ACCEPTANCE_TESTS.md`

---

## Reference Documents

All in `web/` alongside this file:

- `PRODUCT_SPEC.md` — Vision, audience, MVP scope, non-goals, success criteria
- `UX_AND_SCREENS.md` — Full screen specifications, IA, component behavior
- `DATA_AND_PERMISSIONS.md` — Complete schema + RLS policies
- `CONTENT_AND_CURRICULUM.md` — 8-week curriculum, civic lessons, circle guides
- `ADMIN_AND_OPERATIONS.md` — Admin workflows, email templates, moderation, launch checklist
- `ACCEPTANCE_TESTS.md` — All acceptance test scenarios

---

**End of build prompt. Start with project scaffold and work through the build order above.**
