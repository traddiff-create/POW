# Design System

## iOS — SwiftUI (iOS 18+ / iOS 26 Preview)

### UI Framework
- **SwiftUI** — declarative, @Observable state, NavigationStack
- **Liquid Glass** (iOS 26) — frosted glass material for overlays, sheets, navigation bars
- **SF Symbols 6** — system iconography, variable color, animations
- **Dynamic Type** — all text must scale with user font size preference
- **Dark Mode** — all color tokens must have light + dark variants

### Color Tokens (fill in with brand colors)
```swift
// Core/Design/Colors.swift
extension Color {
    static let appPrimary   = Color("Primary")     // #XXXXXX
    static let appSecondary = Color("Secondary")   // #XXXXXX
    static let appBackground = Color("Background") // #XXXXXX
    static let appSurface   = Color("Surface")     // #XXXXXX
    static let appOnPrimary = Color("OnPrimary")   // #XXXXXX
}
```

### Typography Scale
```swift
// Core/Design/Typography.swift
// Use .font(.largeTitle), .font(.headline), .font(.body) — never hardcode pt sizes
```

### Spacing Grid
- Base unit: 4pt
- Common: 4, 8, 12, 16, 24, 32, 48

### iOS UI Patterns
- `NavigationStack` + `.navigationDestination` for push navigation
- `.sheet` / `.fullScreenCover` for modal flows
- `ScrollView` + `LazyVStack` for lists (prefer over `List` for custom styling)
- `.task` modifier for async data loading
- `.searchable` for search UI

---

## Android — Jetpack Compose + Material 3 Expressive

### UI Framework
- **Jetpack Compose** — declarative UI
- **Material 3 Expressive** (2025) — updated motion, typography, adaptive color
- **Dynamic Color** — system-generated palette from wallpaper (Android 12+)
- **Adaptive Layouts** — support phone, tablet, foldable with `WindowSizeClass`

### Color Tokens
```kotlin
// core/theme/Color.kt
val Primary = Color(0xFFXXXXXX)
val Secondary = Color(0xFFXXXXXX)
val Background = Color(0xFFXXXXXX)
val Surface = Color(0xFFXXXXXX)
// Use MaterialTheme.colorScheme.* everywhere — never hardcode
```

### Typography
```kotlin
// Use MaterialTheme.typography.* — headlineLarge, bodyMedium, labelSmall, etc.
```

### Spacing
- Same 4dp base grid as iOS for consistency

### Android UI Patterns
- `NavHost` + `composable()` for navigation
- `ModalBottomSheet` for bottom sheets
- `LazyColumn` / `LazyRow` for scrollable lists
- `ViewModel` + `collectAsStateWithLifecycle()` for state
- `Scaffold` with `TopAppBar` for standard screen layout

---

## Shared Brand Tokens

| Token | Value | Notes |
|-------|-------|-------|
| Primary | TBD | Main brand color |
| Secondary | TBD | Accent |
| Background | TBD | Screen background |
| Border radius | 12pt / 12dp | Cards, sheets |
| Animation duration | 300ms | Standard transitions |
| Shadow elevation | 2dp | Cards |
