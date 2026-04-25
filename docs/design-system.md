# Design System — A Piece of Whole

## Color Tokens (`Core/Design/Colors.swift`)

| Token | Hex / Value | Usage |
|-------|------------|-------|
| `powBackground` | `#F9F7F4` | App background (warm off-white) |
| `powSurface` | `#FFFFFF` | Cards, input fields |
| `powForeground` | `#2C2A28` | Primary text |
| `powMuted` | `#2C2A28` @ 55% | Labels, secondary text |
| `powBorder` | `#2C2A28` @ 12% | Strokes, dividers |
| `powSage` | `#7A9E7E` | Primary accent — focused fields, selected states |
| `powSageLight` | `#7A9E7E` @ 12% | Sage tint backgrounds |
| `powStone` | `#C4A882` | Warm secondary accent |
| `powError` | `#C0392B` | Error states |

## Typography Scale (`Core/Design/Typography.swift`)

| Token | Size / Weight | Usage |
|-------|-------------|-------|
| `.powLargeTitle` | 32pt semibold | Hero headings |
| `.powTitle` | 24pt semibold | Section headers |
| `.powTitle2` | 20pt semibold | Card titles, nav titles |
| `.powHeadline` | 17pt semibold | Emphasized body |
| `.powBody` | 17pt regular | Body text |
| `.powCallout` | 15pt regular | Secondary body, subtitles |
| `.powCaption` | 13pt regular | Field labels, footnotes |
| `.powLabel` | 11pt medium uppercaseSmallCaps | Metadata tags |

## Spacing Grid
Base unit: 4pt. Common values: 4, 8, 12, 16, 24, 32, 48.

## Component Library (`Core/Design/Components/`)

### POWTextField
```swift
POWTextField(label: "Email", text: $email, placeholder: "you@example.com")
POWTextField(label: "Password", text: $password, isSecure: true)
POWTextField(label: "Note", text: $note, axis: .vertical)   // multiline
```
- Sage border on focus (1.5pt), muted border at rest (1pt)
- Suppresses iOS password autofill system sheet via `.textContentType(.init(rawValue: ""))`

### POWButton
```swift
POWButton(title: "Save", isLoading: isLoading) { /* action */ }
```
- Full-width, sage background, loading state built-in

### POWCard
```swift
POWCard { /* content */ }
```
- White surface, rounded corners, subtle shadow

## iOS UI Patterns
- `NavigationStack` + `.navigationDestination` for push navigation
- `.sheet` for modal flows (check-in, new post)
- `.task` modifier for async data loading on appear
- `ScrollView` + `VStack` for custom-styled lists (not `List`)
- Error displayed inline as red caption text below failed action

## Accessibility
- All POW* components support Dynamic Type via `.font(.powBody)` etc.
- Focus state exposed via `@FocusState` on all text inputs
- Color contrast: sage `#7A9E7E` on white passes WCAG AA for large text
