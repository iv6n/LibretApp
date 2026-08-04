# LibretApp — Design System

Every screen shares the same tokens and widgets. Use them instead of literal
numbers, colors, or hand-rolled cards/empty states — that's what keeps the
app consistent as it grows. This guide exists because an earlier audit found
the tokens and shared widgets already existed but were barely used (`AppCard`
and `AppChip` had zero real call sites); the goal here is to stop that from
happening again.

## Tokens (`lib/theme/app_theme.dart`)

| Token | Values | Use for |
|---|---|---|
| `AppSpacing` | `xxs` 4, `xs` 8, `sm` 12, `md` 16, `lg` 20, `xl` 24, `xxl` 32 | Any `EdgeInsets`, `SizedBox` gap, or `Row`/`Column` spacing. Never write a literal number like `EdgeInsets.all(14)`. |
| `AppRadii` | `sm` 8, `md` 12, `lg` 16 | Any `BorderRadius.circular(...)`. Never write a literal radius. |
| `AppTextStyles` | `titleLg`, `titleMd`, `body`, `label` | Custom text needs outside what `Theme.of(context).textTheme` already covers. Prefer the theme's `textTheme` first; reach for these only when the theme doesn't have the right style. |
| Colors | `Theme.of(context).colorScheme` / `AppColors` (`lib/core/widgets` imports) | Never hardcode `Color(0x...)`. If a color doesn't exist in the scheme, add it to `AppColors` rather than inlining a hex value in a screen. |

## Shared widgets (`lib/core/widgets/`, exported via `widgets.dart`)

| Situation | Use | Not |
|---|---|---|
| A tappable or informational block with a title/subtitle/leading/trailing/body | `AppCard` | raw `Card(...)` |
| A small labeled tag/status/filter pill | `AppChip` (tones: `neutral`, `info`, `success`, `warning`, `error`) | raw `Container` + `BoxDecoration` chip |
| A list/section with no data yet | `AppEmptyState` (icon, title, message, optional action) | a local `_buildEmpty`/`EmptyView` widget per screen |
| A full-screen or inline loading state | `AppLoadingIndicator` (full-page, optional message) / `AppLoadingIndicator.inline()` (compact, for cards) | bare `Center(child: CircularProgressIndicator())` scattered per screen |
| A search field with optional filter/clear actions | `AppSearchBar` | a custom `TextField` + manual clear/filter buttons |

If a real screen needs something one of these widgets doesn't expose yet
(e.g. a different `AppCard` elevation), extend the shared widget with a new
optional parameter — don't fork it into a local copy.

## Adding a new screen or section

1. Reach for a shared widget from the table above first.
2. If none fits, build with `AppSpacing`/`AppRadii`/theme text styles and
   colors — not literals.
3. If you find yourself repeating a pattern across two or more screens,
   promote it into `lib/core/widgets/` instead of copy-pasting.
