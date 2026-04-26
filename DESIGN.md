---
version: alpha
name: A Piece of Whole
description: Calm, relational product UI for self-regulation, co-regulation, community, agency, and civic practice.
colors:
  primary: "#7A9E7E"
  secondary: "#C4A882"
  background: "#F9F7F4"
  surface: "#FFFFFF"
  foreground: "#2C2A28"
  muted: "#888684"
  primary-container: "#EAECE6"
  error: "#C0392B"
  on-primary: "#2C2A28"
typography:
  large-title:
    fontFamily: DM Sans
    fontSize: 32px
    fontWeight: 600
    lineHeight: 1.18
  title:
    fontFamily: DM Sans
    fontSize: 24px
    fontWeight: 600
    lineHeight: 1.25
  title-sm:
    fontFamily: DM Sans
    fontSize: 20px
    fontWeight: 600
    lineHeight: 1.3
  body:
    fontFamily: DM Sans
    fontSize: 17px
    fontWeight: 400
    lineHeight: 1.5
  callout:
    fontFamily: DM Sans
    fontSize: 15px
    fontWeight: 400
    lineHeight: 1.45
  caption:
    fontFamily: DM Sans
    fontSize: 13px
    fontWeight: 400
    lineHeight: 1.35
  label:
    fontFamily: DM Sans
    fontSize: 11px
    fontWeight: 500
    lineHeight: 1.25
rounded:
  sm: 2px
  md: 8px
  lg: 16px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 48px
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.callout}"
    rounded: "{rounded.sm}"
    padding: 16px
  button-secondary:
    backgroundColor: transparent
    textColor: "{colors.foreground}"
    typography: "{typography.callout}"
    rounded: "{rounded.sm}"
    padding: 16px
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.foreground}"
    rounded: "{rounded.md}"
    padding: 24px
  input:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.foreground}"
    rounded: "{rounded.sm}"
    padding: 12px
  error-text:
    textColor: "{colors.error}"
    typography: "{typography.caption}"
  caption:
    textColor: "{colors.muted}"
    typography: "{typography.caption}"
  selected-state:
    backgroundColor: "{colors.primary-container}"
    textColor: "{colors.foreground}"
    rounded: "{rounded.sm}"
    padding: 12px
  page:
    backgroundColor: "{colors.background}"
    textColor: "{colors.foreground}"
  step-marker:
    textColor: "{colors.secondary}"
    typography: "{typography.title-sm}"
---

## Overview

A Piece of Whole should feel calm, embodied, and relational. The interface is warm and spacious, but it is still a practical tool for repeated reflection, check-ins, journaling, circle participation, and cohort administration.

The product philosophy is visible in the design choices: no pressure tactics, no shame cues, no fear-based urgency, and no decorative complexity that competes with a user's nervous-system state.

## Colors

The palette is light, natural, and low-noise.

- **Background (#F9F7F4):** warm off-white for full-page foundations.
- **Surface (#FFFFFF):** cards, form fields, and contained content.
- **Foreground (#2C2A28):** warm charcoal for primary text.
- **Muted (55% foreground):** secondary text, labels, timestamps, and helper copy.
- **Border (12% foreground):** quiet dividers and field borders.
- **Primary (#7A9E7E):** sage for calls to action, selected states, focused fields, and supportive emphasis.
- **Secondary (#C4A882):** warm stone for step markers and secondary emphasis.
- **Error (#C0392B):** concise safety, validation, and failure states.

## Typography

Use DM Sans for product UI. Keep headings soft and readable rather than oversized. Large titles are reserved for first-screen welcome and high-level public marketing moments; dashboards, cards, forms, and admin views use tighter title scales.

## Layout

Use a 4px spacing base with common steps of 8, 16, 24, 32, and 48px. Prefer single-column mobile-first layouts with clear reading width. Use generous vertical spacing around reflective content and denser spacing for admin queues and repeated operational items.

## Elevation & Depth

Keep depth subtle. Cards use a white surface, quiet border, and only a minimal shadow where needed for separation. Avoid heavy shadows, floating page sections, gradient backgrounds, and decorative blobs.

## Shapes

Controls and fields use a 2px radius. Cards and larger grouped surfaces may use 8px. Larger rounded shapes are rare and should only appear when they serve a touch or modal affordance.

## Components

Primary buttons use sage with warm-charcoal text and a minimum 44px touch target. Dark text on sage keeps the calm, low-pressure tone of the surface and meets WCAG AA contrast. Ghost or secondary actions keep a transparent background and a quiet border. Form fields use white surfaces, muted borders, and sage focus states. Error text appears inline near the failed action and should be generic when it comes from infrastructure or backend failures.

## Do's and Don'ts

Do make safety, consent, privacy, and repair visible in product choices. Do use plain language and stable layouts that support scanning and reflection. Do keep public pages gentle and clear.

Do not use domination, shame, manipulation, or fear to drive participation. Do not expose backend, Supabase, SQL, policy, token, or configuration details in user-facing errors. Do not introduce a one-note palette, dark WRC comedy tokens, or decorative gradients.
