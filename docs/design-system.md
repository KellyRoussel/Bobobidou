# Bobobidou — design system

Source of truth for the app (`lib/theme/`) and for everything around it
(store listing, social posts, website, slides). The values here and in
`lib/theme/bobo_tokens.dart` must stay identical.

## Personality

Bobobidou is a gentle companion for people living with digestive pain. It
should feel **warm, round and calm**, never clinical or alarming. Everything
comes from the logo: a peach background, a coral swirl, a blue-to-violet
wave and a few citrus fruits.

## Colors

| Token | Hex | Use |
|---|---|---|
| `corail` | `#E07A7A` | Brand color (default accent). Filled buttons, selected states, **meals**. |
| `corailProfond` | `#A13F47` | Coral for text and icons on light grounds (5.7:1 on peach). |
| `corailTendre` | `#F9DAD6` | Meal tiles, chips, navigation indicator. |
| `peche` | `#FFF0E5` | App background. |
| `pecheSplash` | `#FBD1B9` | Splash screen, logo background, avatars. |
| `prune` | `#6B4BC4` | **Pain episodes** (logo tail). White text on it: 6.1:1. |
| `pruneTendre` | `#ECE6FA` | Pain tiles. |
| `lagon` | `#3A97B0` | Secondary accent, "low" severity. |
| `soleil` | `#F2B33D` | Highlights, "moderate" severity, timeline links. Dark text only. |
| `cacao` | `#3D2B2B` | Text (11.9:1 on peach). |
| `cacaoDoux` | `#7A6260` | Secondary text (5.0:1 on peach). |
| `creme` | `#FFFFFF` | Cards, sheets, inputs. |
| `ligne` | `#F0DDD3` | Hairlines, input borders. |

Rules:
- Meals are always coral, pain is always plum: in the journal, the charts and
  any communication material.
- Severity is never told by color alone: it always carries its word
  (Faible / Modéré / Élevé / Très élevé).
- White on `corail` is 2.9:1: keep it for bold labels of 15px and more
  (buttons). For smaller text use `cacao` or `corailProfond`.
- The accent can be changed by the user (Violet, Vert, Bleu); the peach
  background, neutrals and meal/pain colors never change.

## Typography

| Role | Face | Size / line height |
|---|---|---|
| Display (`displaySmall`) | Fredoka SemiBold | 36 / 42 |
| Page title (`headlineMedium`) | Fredoka SemiBold | 30 / 36 |
| Sheet title (`headlineSmall`) | Fredoka SemiBold | 24 / 30 |
| Section title (`titleLarge`) | Fredoka SemiBold | 20 / 26 |
| Item title (`titleMedium`) | Nunito Bold | 16 / 22 |
| Body (`bodyLarge`) | Nunito Regular | 16 / 24 |
| Secondary (`bodyMedium`) | Nunito Regular, `cacaoDoux` | 14 / 20 |
| Button (`labelLarge`) | Nunito ExtraBold | 15–16 / 20 |
| Overline (`labelSmall`) | Nunito ExtraBold, uppercase, +0.8 | 11 / 14 |

Both faces are bundled in `assets/fonts/` (SIL Open Font License) and are on
Google Fonts for web and print material.

## Shape, spacing, elevation

- Spacing scale: 4 · 8 · 12 · 16 · 24 · 32 · 48. Page gutter: 20.
- Radii: 12 (small), 16 (inputs), 24 (cards, sheets), pill (buttons, chips).
- One shadow only, soft and warm: `0 6 20 rgba(61,43,43,.08)`, under cards.
- Icons: Material *Rounded*. Meal = `restaurant_rounded`, pain = `bolt_rounded`.

## Voice

- French first, *vouvoiement*, short and kind sentences.
- Sentence case everywhere, no ALL CAPS buttons ("Enregistrer le repas").
- A button says what it does; a confirmation says what happened ("Repas enregistré").
- No medical promises: the analysis gives *pistes*, not a diagnosis.

## Navigation

Three destinations in a bottom navigation bar:

1. **Journal** — greeting, two quick actions (Repas / Douleur) opening a
   bottom sheet, last-7-days summary, entries grouped by day.
2. **Analyse** — ingredients most often eaten before pain, the timeline, the
   searchable list of every ingredient.
3. **Moi** — Google account, accent, language, CSV export.
