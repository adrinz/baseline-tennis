# Baseline design system

Visual source of truth for the Flutter app and the admin CMS. Screen layouts live in [screens.md](screens.md). Product behavior lives in the architecture, requirements, flows, and licensing docs. This file decides how that behavior looks, reads, and sounds to VoiceOver.

Baseline should feel like a night match and a paper court diagram: dark green chrome, a cream page, a yellow ball that marks the next action, and white lines that organize the page. It is a tennis product. It is not a generic fitness app. No flame streaks, dumbbells, neon gradients, fake coach avatars, or confetti.

MVP ships one theme. Night court is a surface in that theme, not an operating-system dark mode. Cream pages stay cream when the phone is in Dark Mode. Status-bar content is light on night surfaces and dark on cream surfaces.

## Voice

Second person, short, plain. Say what to do and what happens.

- Use tennis words: court, baseline, rally, serve, deuce, strings. The technique family is **rallying fundamentals** (height, depth, direction, recovery).
- Levels are guidelines. Say that on the level picker and on Edit profile.
- The rules coach is **coaching assistance**. It is not a diagnosis, a certified coach, or a person. Do not draw a face for it.
- Premium locks are named Premium. Sponsored equipment is named Sponsored. Those two words are never swapped, and the ball color is never used for ads.
- Safety copy is literal: block, report, delete, age 16, age 18, distance band.

## Principles

1. **The ball is the next action.** One ball-colored mark per screen: the primary button, the active plan block, or the current lesson. Everything else is green, cream, or ink.
2. **The page is a court.** Horizontal rules act like lines. Cards sit on the cream surface the way tape sits on a court. Shadows are rare.
3. **Teach without the video.** Every lesson and technique is complete as text. Video is large when it exists and absent when it does not. Never leave a blank player-shaped hole.
4. **People are not pins.** Courts, coaches, and stores can be mapped. Players are cards with a distance band.
5. **Color is never the only signal.** Status also uses a word, a check, a lock, or a position.

## Color

### Brand

| Token | Hex | Role |
|---|---|---|
| `nightCourt` | `#10211C` | Tab bar, welcome, paywall, video chrome, selected chips, Premium chip fill |
| `fairway` | `#1F7A4D` | Primary button on cream, links, completed state, progress arc |
| `ball` | `#E4F56A` | The single next action on a dark surface, active baseline mark, progress knob, “Baseline pick” |
| `clay` | `#C46B4A` | Attention border and icons: lock, miss, caution. Not small text. |
| `line` | `#F4F1EA` | Page background, text on night and on fairway buttons |
| `ink` | `#14211C` | Primary text and icons on cream, text on ball |
| `muted` | `#5E6B66` | Secondary text on cream only |

### Derived

These exist so the brand colors are not used in pairs that fail contrast. Do not invent additional brights.

| Token | Hex | Role |
|---|---|---|
| `card` | `#FFFCF7` | Cards and sheets lifted off `line` |
| `mist` | `#C3CFC8` | Secondary text and inactive icons on `nightCourt` |
| `track` | `#E3E6E1` | Progress and switch tracks on cream |
| `fairwayPressed` | `#18643F` | Pressed primary button |
| `clayDeep` | `#7A3424` | Destructive button fill. Label is `line`. |
| `hairline` | `#14211C` at 16% opacity | Dividers and input borders on cream |
| `hairlineOnDark` | `#F4F1EA` at 24% opacity | Dividers on night court |

Flutter: `ColorScheme.surface` = `line`, `onSurface` = `ink`, `primary` = `fairway`, `onPrimary` = `line`, `secondary` = `nightCourt`, `onSecondary` = `line`, `tertiary` = `ball`, `onTertiary` = `ink`, `error` = `clayDeep`, `onError` = `line`, `surfaceContainerLowest` = `card`, `outline` = `hairline`. Put `nightCourt`, `ball`, `clay`, `mist`, and `clayDeep` on a `ThemeExtension` named `BaselineColors`. Do not overload `ColorScheme.error` with raw `clay`.

### Pairs that are allowed for text and 1pt icons

| Foreground | Background | Approx. contrast | Use |
|---|---|---|---|
| `ink` | `line`, `card` | 15:1 | Body, titles |
| `muted` | `line`, `card` | 4.8:1 | Meta text at 13pt and up |
| `line` | `fairway` | 4.7:1 | Primary button label |
| `line` | `nightCourt` | 15:1 | Text on dark chrome |
| `mist` | `nightCourt` | 8:1 | Inactive tab labels, meta on dark |
| `ink` | `ball` | 13:1 | Label on a ball button or chip |
| `ball` | `nightCourt` | 14:1 | Wordmark rule, Premium chip text, active tab mark |
| `line` | `clayDeep` | 8:1 | Delete button |

### Pairs that must not carry text or a small icon

| Pair | Why | Use instead |
|---|---|---|
| `muted` on `nightCourt` | About 3:1 | `mist` |
| `ball` on `line` or `card` | Yellow disappears on cream | Ball as a fill with `ink` text, or a ball mark sitting on `nightCourt` |
| `clay` as text on `line` | About 3.3:1 | `clay` as a 3pt border or a 24pt icon, with the words in `ink` |
| `fairway` as a thin icon on `ball` | Muddy | `ink` on `ball` |
| White `#FFFFFF` body text on `fairway` | Barely different from `line`, easy to drift off-token | `line` |

High-contrast notes (tips, misses, coaching footer, license warnings) use a `line` or `card` fill, `ink` text, and a **3pt** left border. The border color supports the meaning. The words still work in grayscale.

| Note | Border | Title |
|---|---|---|
| Tip | `fairway` | Tip |
| Common miss | `clay` | Common miss |
| Coaching footer | `nightCourt` | Coaching help, not medical advice. |
| Pain | `clay` | Stop if something hurts |
| License / sponsored | `ink` | Sponsored, or the license name |
| Premium preview | `nightCourt` | Premium |

A 24pt icon may repeat the border color. The icon is `ExcludeSemantics`. The title is the accessible name.

### Meaning of color

| Meaning | Color | Also show |
|---|---|---|
| Do this next | `ball` fill or `ball` baseline mark | A verb: Start, Continue, Send |
| Done, saved, success | `fairway` | The word Done or a check |
| Premium lock | `nightCourt` chip, `ball` word “Premium”, `clay` lock icon | The word Premium |
| Sponsored | 1pt `ink` outline chip | The word Sponsored |
| Baseline pick | 8pt `ball` disc | The words Baseline pick |
| Destructive | `clayDeep` fill | The verb Delete |
| Court surface “clay” in a filter | A `clay` swatch plus the word Clay | Never the swatch alone |

## Type

Bundle **Barlow Condensed** (600) and **Source Sans 3** (400, 500, 600). Both are SIL Open Font License. Ship the license with the app. Fallback if a file fails to load: SF Pro on iOS, Roboto on Android. Do not download fonts at runtime.

Barlow Condensed is for the wordmark, screen titles, scores, and eyebrows. Source Sans 3 is for anything the player must read: lessons, buttons, form labels, hints. Condensed type is a poor fit for instructions, so lesson prose never uses it.

Sizes are logical pixels at text scale 1.0. Line height is a multiplier. Do not set `TextScaler.noScaling`. Do not cap the scaler below 2.0. Do not wrap lesson prose in `FittedBox` or a fixed-height `Text`.

| Token | `TextTheme` slot | Family | Size | Weight | Height | Tracking | Use |
|---|---|---|---|---|---|---|---|
| `display` | `displayLarge` | Barlow Condensed | 40 | 600 | 1.05 | -0.5 | Welcome, paywall |
| `title1` | `headlineMedium` | Barlow Condensed | 28 | 600 | 1.10 | -0.3 | Screen titles |
| `title2` | `headlineSmall` | Barlow Condensed | 24 | 600 | 1.15 | 0 | Day headers, hero titles |
| `title3` | `titleLarge` | Source Sans 3 | 20 | 600 | 1.25 | 0 | Section titles |
| `heading` | `titleMedium` | Source Sans 3 | 17 | 600 | 1.30 | 0 | Row and card titles |
| `body` | `bodyLarge` | Source Sans 3 | 17 | 400 | 1.45 | 0 | Lesson and drill prose |
| `secondary` | `bodyMedium` | Source Sans 3 | 15 | 400 | 1.40 | 0 | Supporting copy |
| `button` | `labelLarge` | Source Sans 3 | 17 | 600 | 1.20 | 0.1 | Button labels |
| `meta` | `bodySmall` | Source Sans 3 | 13 | 500 | 1.35 | 0 | Minutes, attribution, captions |
| `eyebrow` | `labelMedium` | Barlow Condensed | 13 | 600 | 1.20 | 1.4 | Uppercase section labels |
| `score` | `displaySmall` | Barlow Condensed | 32 | 600 | 1.00 | 0 | Ring center, streak, set score. Tabular figures |

Eyebrows are uppercase Barlow Condensed. They repeat a label the section title already gives, so VoiceOver should usually read the title and skip the eyebrow (`ExcludeSemantics` on the eyebrow when the next heading says the same thing).

Scores and the progress fraction use `FontFeature.tabularFigures`.

Lesson prose column max width is 640. Center it on iPad. Buttons in that column stretch to the column width, not the full iPad width.

Dynamic Type rules:

- Rows, cards, and the tab bar grow in height. Nothing clips at text scale 2.0.
- A one-line meta label may become two or three lines. Use `maxLines` only on dense rows, and then no less than 2, with the full string in the semantics label.
- The tab-bar label stays visible. Allow two lines before ellipsis.
- Screen titles wrap to three lines, then ellipsis, with the full title on the screen body.

## Spacing

4pt base. Tokens are logical pixels. Implement as `BaselineSpace` constants. Screen horizontal padding is `lg` (20). Section gap is `xxl` (32).

| Token | Value | Use |
|---|---|---|
| `hair` | 2 | Baseline rule thickness |
| `xxs` | 4 | Icon-to-label gap, chip internal tweaks |
| `xs` | 8 | Stacked meta lines, chip padding vertical |
| `sm` | 12 | Inside a dense row |
| `md` | 16 | Card padding, gap between related controls |
| `lg` | 20 | Screen horizontal padding |
| `xl` | 24 | Gap between cards, gap between stacked buttons |
| `xxl` | 32 | Gap between sections |
| `xxxl` | 48 | Space above a hero title |
| `huge` | 64 | Welcome top inset below the status bar |

Touch targets are at least **44 × 44** even when the icon is 24 or the visual chip is 32 tall. Expand the hit area with padding. Do not rely on `visualDensity` to shrink a target under 44.

Scroll views that sit above the tab bar add bottom padding of tab-bar height + home-indicator inset + `md`. A sticky footer button adds the home-indicator inset under the button and a `hair` rule above the footer.

## Radius, stroke, elevation

| Token | Value | Use |
|---|---|---|
| `none` | 0 | Video, map, full-bleed rules |
| `xs` | 4 | Diagram ticks |
| `sm` | 8 | Inputs, thumbnails |
| `md` | 12 | Standard cards |
| `lg` | 20 | Hero cards, plan-day cards |
| `xl` | 28 | Top corners of a bottom sheet |
| `pill` | 999 | Buttons, chips, search field, level chip |

| Stroke | Width | Use |
|---|---|---|
| Hairline | 1 | Inputs, card borders, Sponsored chip |
| Baseline | 2 | The rule under an app bar, above a tab bar, under a section eyebrow |
| Note | 3 | Tip, miss, and warning callouts |
| Focus | 2 + 2 | Keyboard focus: 2pt `ink` ring, then 2pt `ball` ring outside it, 2pt gap. Visible on cream and on night. |

Elevation is flat. The only shadow is on a modal sheet and on the discover list sheet: offset `(0, 8)`, blur 24, color `ink` at 12% opacity. No glows, no colored shadows.

The **baseline rule** is a 2pt horizontal line, full width, `ink` on cream and `line` at 24% on night. It separates chrome from content. It is decorative (`ExcludeSemantics`).

## Motion

| Token | Duration | Curve | Use |
|---|---|---|---|
| `fast` | 120ms | easeOutCubic | Chip select, check |
| `base` | 180ms | easeOutCubic | Screen content, button press scale 0.98 |
| `sheet` | 240ms | easeOutCubic | Bottom sheet |

When `MediaQuery.disableAnimations` is true, duration is 0. The onboarding progress knob does not roll. The streak ball does not bounce. Haptics: a light impact when a lesson or drill is marked done. No haptic on tab changes.

## Iconography

Outlined icons, 1.75pt stroke, 24pt art inside a 44pt target. Use one set (Phosphor or Lucide, outline weight) plus four tennis marks drawn as simple geometry:

- **Ball** — circle with a single curved seam. Used for the next action, streak, and Baseline pick.
- **Court** — rectangle, baseline, and service line. Used for empty states and court setup.
- **Racket** — oval head and a short handle. Used for drills and equipment.
- **Net** — three horizontal lines with a center strap. Used for volley and net-play families.

Do not use a glossy 3D ball, a photoreal racket, or a mascot.

## Accessibility

- VoiceOver labels are the visible words. Add a label only when the control is an icon, a ring, a map, a video, or a switch whose state is not in the text.
- Decorative rules, seams, and empty-state diagrams are `ExcludeSemantics`.
- Group a card with `MergeSemantics` when it is one action. If the card contains a second action (favorite, request), keep that action as its own button.
- Reading order follows visual order, top to bottom, except the court map: the court **list** comes before the map node so pins are not a long rotor. See Court row and the Discover screen.
- Every video has a captions control. Default captions **on** when the system caption preference is on; otherwise remember the player’s last choice.
- Focus order matches reading order. Full Keyboard Access uses the double focus ring above.
- Respect bold text: do not override `FontWeight` back down when the OS asks for bold.
- Minimum contrast for text is WCAG AA. The banned pairs table is the implementation checklist.

Quality bar from the product: VoiceOver can finish onboarding, open a lesson, and log a drill with these targets and labels.

## Screen scaffold

Every mobile screen is a column:

1. Status bar, styled for the surface under it.
2. `BaselineAppBar`, unless the screen is Welcome or the video sheet.
3. Optional baseline rule.
4. Scrollable content, horizontal padding `lg`, section gap `xxl`. Lesson prose is centered in a max-width 640 column.
5. Optional sticky footer: baseline rule, `md` padding, one primary button, home-indicator inset.
6. `BaselineTabBar` on the five tab roots only. Hidden on welcome, sign-in, onboarding, paywall, video sheet, and admin.

Tab roots: Home, Learn (level list), Train (week plan), Discover, Profile.

---

## Components

Each component lists the widget name, the anatomy a Flutter developer builds, the states, and the semantics. Build them as widgets that read `BaselineColors` and `TextTheme`. Do not hard-code hex values inside a screen.

### App bar

**Widget:** `BaselineAppBar`

**Role:** Orientation. The title tells the player where they are. The bar does not compete with the lesson.

**Anatomy, leading to trailing:**

1. Leading slot, 44 × 44. Empty on tab roots. A back chevron on pushed screens. Semantic label “Back”.
2. Title slot, expanded. Barlow `title2` for short root names (Learn, Train, Discover, Profile). Source Sans `heading` for long object names (a lesson or court), max two lines, start-aligned. Home uses the wordmark instead of a title: “BASELINE”, Barlow Condensed 20, weight 600, tracking 2.0, color `ink`.
3. Trailing slot, one or two 44 × 44 icon buttons. Home and Learn: search, label “Search”. Court detail: share, label “Share court”. Player detail: more, label “More actions”.

**Layout:** Minimum height 56 plus the status-bar inset. The bar grows if the title wraps. Horizontal padding `xs` so the 44pt targets sit slightly in from the screen edge. A 2pt baseline rule sits on the bottom edge. Background `line`. Foreground `ink`.

**Dark variant:** Welcome, paywall, and the video sheet do not use this bar. Video uses the video frame’s own close button. If a dark bar is required over a photo, background `nightCourt`, foreground `line`, rule `hairlineOnDark`.

**States:** Default. Loading does not replace the title with a spinner; the body shows progress. Title missing: fall back to the section name (“Lesson”, “Court”).

**Flutter:** A `PreferredSize` widget, not the default `AppBar` title spacing. Set `systemOverlayStyle` from the variant. The back control is an `IconButton` with `tooltip` equal to the semantics label.

### Tab bar

**Widget:** `BaselineTabBar`

**Role:** The five permanent places. Labels stay short: Home, Learn, Train, Discover, Profile. There is no sixth tab.

**Anatomy, per item:**

1. A 20 × 3 `ball` baseline segment, centered, radius pill. Visible only on the selected item. Inset 6pt from the top of the bar.
2. Icon, 24pt, `line` when selected, `mist` when not.
3. Label, `meta` size, weight 600, same colors as the icon. Two lines maximum.

**Layout:** Five equal columns. Bar fill `nightCourt`. A 2pt `hairlineOnDark` rule on the top edge (the app’s baseline). Minimum content height 56, plus the home-indicator inset. The bar grows if labels wrap. Icons, top to bottom in the column: Home (court mark), Learn (open book is acceptable; prefer a folded court diagram), Train (racket), Discover (map pin used only for this tab, never for a player), Profile (circle).

**Badge:** A 8pt `ball` disc on the Profile icon when the inbox has an unread message or a pending request. Semantic label becomes “Profile, new activity”. The disc is not a number.

**States:** Selected, unselected, badge. Pressed: icon opacity 0.7 for `fast`. No Material pill indicator behind the icon.

**Flutter:** Do not use `NavigationBar`’s default pill. A custom row of five `Semantics` buttons with `selected` true or false, `container: true`. Hit target is the full column, well above 44pt. `SafeArea` bottom, `top: false`.

### Primary and secondary buttons

**Widgets:** `BaselinePrimaryButton`, `BaselineSecondaryButton`

**Role:** Primary is the one next action. Secondary is the other real choice (restore, edit days, enter a city). A screen has one primary button.

**Anatomy:**

1. Optional leading icon, 20pt, `ExcludeSemantics`, 8pt gap.
2. Label, `button` token, one line at scale 1, two lines at large type. Centered.
3. Optional trailing spinner, 20pt, only in the loading state, in place of the icon.

**Layout:** Height at least 52, width as given. Screen-level buttons are full width of the content column. Inline buttons hug the label with horizontal padding 20, and still at least 44 tall. Radius `pill`. Gap between a primary and a secondary stack is `sm`.

**Variants:**

| Variant | Fill | Label | Border |
|---|---|---|---|
| Primary on cream | `fairway` | `line` | none |
| Primary on night | `ball` | `ink` | none |
| Primary pressed | `fairwayPressed`, or `ball` at 85% on night | same | none |
| Secondary on cream | transparent | `fairway` | 1.5pt `fairway` |
| Secondary on night | transparent | `line` | 1.5pt `line` |
| Destructive | `clayDeep` | `line` | none |
| Disabled | the same fill at 38% opacity | the same label color at 70% | none |

Disabled does not need to meet contrast. It must set `enabled: false` and ignore taps.

**Loading:** Keep the label. Replace the icon with a spinner. Ignore repeat taps. Do not shrink the button.

**Semantics:** The label is the name. Hint only when the result is not obvious (“Marks this lesson complete”). Destructive buttons use the verb in the label (“Delete account”), never “OK”.

**Flutter:** `FilledButton` and `OutlinedButton` with `ButtonStyle.minimumSize` of `Size.fromHeight(52)`, `tapTargetSize: padded`, `shape: StadiumBorder()`, elevation 0. Overlay color for pressed is black at 8% on fairway and `fairway` at 12% on ball. Put the on-night variant in a local `Theme` or a `onDark` flag. Do not use `ElevatedButton`.

**Text button:** A third style for low-emphasis actions (“Not now”, “Sign out”, “Decline”). `fairway` label on cream, `line` on night, minimum height 44, no border. Decline on a partner request uses this style so Accept stays the only primary.

### Level chip

**Widget:** `BaselineLevelChip`

**Role:** Says which of the five guidelines a lesson, drill, or player belongs to, or which level the viewer is.

**Anatomy:**

1. Optional 8pt ball disc, only when this chip is the viewer’s current level.
2. Label: “1 · Complete Beginner”, “2 · Beginner”, “3 · Advanced Beginner”, “4 · Intermediate”, “5 · Advanced”. Short form “L1” is allowed in a dense row if the semantics label still says “Level 1, Complete Beginner”.

**Layout:** Height at least 32 visually, hit target 44 when it is a control. Horizontal padding 12. Radius `pill`.

**States:**

| State | Fill | Text | Border |
|---|---|---|---|
| Quiet label | transparent | `ink` | 1pt `hairline` |
| Current | `ball` | `ink` | none |
| Selected filter | `nightCourt` | `line` | none |
| Pressed | darken fill 8% | same | same |

The chip is a button only inside a filter or the level picker. On a lesson row it is text inside the row’s button, not a nested button.

**Semantics:** “Level 1, Complete Beginner”. Add “, your level” or “, selected” when true.

### Lesson row

**Widget:** `BaselineLessonRow`

**Role:** One lesson in a level. The row is the button.

**Anatomy, top to bottom inside a horizontal arrangement:**

1. Leading column, 36pt wide: a Barlow Condensed numeral of the lesson index in `fairway`, or a check in `fairway` when completed, or a lock icon in `clay` when Premium.
2. Text column, expanded:
   - Title, `heading`, max two lines, then the full title in semantics.
   - Meta, `meta` token, color `muted`: minutes, then a mid-dot, then “Not started”, “In progress”, or “Done”. If a prerequisite exists, a third line “Suggested after {title}”. Prerequisite does not block the tap. Completing lessons never locks another level.
3. Trailing 44pt slot: chevron in `muted`, `ExcludeSemantics`.

**Layout:** Minimum height 72. Padding vertical `sm`, horizontal 0 (the list provides `lg`). A 1pt `hairline` under the row, inset to align with the title. Background transparent. Pressed: `track` fill.

**States:** Not started. In progress (title stays `ink`, meta says “In progress”). Done (check, meta “Done”). Premium (lock, meta “Premium”, title still visible). The free overview is the reason the title is visible before purchase.

**Semantics:** One button. “{title}, {minutes} minutes, {status}.” Premium adds “Premium.” Hint: “Opens the lesson.”

**Flutter:** `InkWell` inside `Material` type transparency, `MergeSemantics`, minimum height via `ConstrainedBox`. Do not put a `GestureDetector` on a child chip.

### Technique section

**Widget:** `BaselineTechniqueSection`

**Role:** One readable block inside a lesson or a technique page. The page stacks sections. The page is useful with zero videos.

**Anatomy:**

1. Eyebrow, optional, the block kind in uppercase: Overview, Why it matters, Steps, Tip, Common miss, Checklist. Excluded from semantics when the heading repeats it.
2. Heading, `title3`, only when the block has its own title beyond the eyebrow.
3. Body, `body`, `ink`. Paragraph gap `sm`. Max width 640.
4. Kind-specific content, below the body:
   - **Steps.** A vertical list. Each step is a row: a 32pt `nightCourt` square with a `line` numeral (the service-box mark), 12pt gap, then `body` text. The square is excluded from semantics. The step’s name is “Step 3 of 6. {text}.”
   - **Tip and common miss.** A high-contrast note. Fill `card`, 3pt left border (`fairway` for tip, `clay` for miss), padding `md`, title plus body. Beginner mistakes use the miss style and the title “If you are new”.
   - **Checklist.** Rows with a 44pt checkbox target. The box is 24pt visually: empty hairline square, or `fairway` fill with a `line` check. Label is `body`. Checking is local to the lesson and is not required to mark the lesson complete.
   - **Diagram.** When the block has an image, show it full column width, radius `sm`, aspect at least 16:9, never a thumbnail under 200pt tall. Alt text is required in the CMS. If the image is missing, skip the slot.
5. A 2pt baseline rule after the section, `hairline`, margin top `xl`.

**States:** Default. Image failed: skip the image, keep the text, no broken-icon placeholder. Empty body: do not render the section.

**Flutter:** A `Column` of blocks from `lesson_blocks.kind`. Map `overview`, `why`, `steps`, `tips`, `mistakes`, `beginner_mistakes`, `checklist`, and `text` onto this widget. `text` is body only, no eyebrow.

### Drill card

**Widget:** `BaselineDrillCard`

**Role:** A drill in the library, on Home, and inside a technique page.

**Anatomy:**

1. Top row: name (`heading`, expanded) and a quiet level chip.
2. Objective, `secondary`, max three lines on the card, full text on the detail screen.
3. Meta row, `meta` / `muted`, wrapping: “{n} min”, “{n} players” or “Wall or partner”, equipment names joined by mid-dots.
4. Court setup, one line, with a 20pt court icon excluded from semantics: “Both at the baseline”, “Service line”, “No court”.
5. If the drill is Premium and the viewer is free: a Premium chip and the sentence “Instructions are included with Premium.” Hide the step list on the card. The name and objective stay.

**Layout:** Fill `card`, radius `lg`, padding `md`, border 1pt `hairline`. Full width. Sections inside the card gap `xs`.

**States:** Default. Pressed: border `ink`. Done today: meta adds “Logged today” in `fairway`. Locked: as above. The whole card is one button, label “{name}, {level}, {minutes} minutes. {objective}.”

### Plan block

**Widget:** `BaselinePlanBlock`

**Role:** One ordered block inside a training day: warm-up, footwork, focus technique, second stroke, serve or rally, or close. Kinds from the model map to those words: `warmup`, `footwork`, `technique`, `drill`, `serve`, `rally`, `recover`.

**Anatomy:**

1. A 3pt left border, full height. Transparent by default. `ball` when this is the current block. `fairway` when done.
2. Index, 28pt Barlow numeral, `ink`, or a `fairway` check when done.
3. Text column, expanded:
   - Eyebrow: the kind name (“Warm-up”, “Footwork”, “Focus”, “Serve or rally”, “Close”).
   - Title, `heading`.
   - Meta: “{n} min”.
4. Trailing action, min 44pt: “Start” as a secondary button when current, “Done” as `muted` text when complete, nothing when upcoming (the row itself is still a button that opens the block).

**Layout:** Minimum height 72. Padding `sm` vertical, `md` horizontal. Group blocks in a day card: fill `card`, radius `lg`, header “Tuesday · 60 min” in `title2`, then the blocks with hairlines between them.

**States:** Upcoming. Current (ball border, Start). Done (check, “Done”, row still opens the log). Disabled does not exist; a future day can be opened and read.

**Semantics:** “{kind}, {title}, {minutes} minutes, {upcoming, current, or done}.” Start is a separate button when it is showing: “Start {title}.”

### Progress ring

**Widget:** `BaselineProgressRing`

**Role:** A compact picture of lessons, minutes, or a streak. The number is the real information. The arc is support.

**Anatomy:**

1. Track circle, stroke 8, color `track` on cream or `hairlineOnDark` on night, `none` cap.
2. Progress arc, stroke 8, `fairway`, round cap, starting at 12 o’clock, clockwise. At 100% the arc is a full ring.
3. Center column: `score` numeral in `ink`, and a `meta` caption under it (“of 12”, “min”, “days”). Caption color `muted` on cream.

**Layout:** 88pt on Home, 64pt inline. The widget is not a button unless the screen says it opens Progress. Padding around it so the 64pt version still has a 44pt target only when it is a button.

**States:** 0% shows the numeral 0 and an empty track, not a placeholder illustration. Unknown data shows “—” and the semantics “Progress not loaded.” Premium history lock is not drawn on the ring. The chart below the ring locks; the ring always shows the basic streak and lesson count, which are free.

**Semantics:** One label, the arc excluded. “{current} of {total} lessons complete.” Streak: “{n} day streak.” Do not say “ring” or “chart” unless there is a chart.

**High contrast:** The numeral is always present. The arc additionally uses a 1pt `ink` edge when the OS high-contrast setting is on, so a green-on-gray arc is not the only shape.

**Flutter:** `CustomPaint` sized with `Semantics(label: ...)`. Do not use a circular percent package that hides the fraction.

### Court row

**Widget:** `BaselineCourtRow`

**Role:** A public court in the Discover list.

**Anatomy:**

1. Text column, expanded:
   - Name, `heading`, two lines max.
   - Meta, `meta` / `muted`, wrapping: surface, lights or no lights, indoor or outdoor, distance if the device location is available (“1.2 km”). City if it is not.
   - Price text, only if present, same meta style.
2. Favorite button, 44 × 44, star outline or `fairway` filled star. Separate from the row.
3. Chevron, excluded from semantics.

**Layout:** Minimum height 72. Hairline under the row. The row is a button. The star is a sibling button, not a child of that button’s semantics.

**States:** Default. Saved (star filled, label “Saved, {name}”). Unavailable filters do not produce a special row; they remove the row. OSM courts look the same as admin courts. Attribution lives on the map, not on each row.

**Semantics:** Row: “{name}, {surface}, {lights}, {distance}. Opens court.” Favorite: “Save {name}” or “Remove saved court {name}.”

### Player card

**Widget:** `BaselinePlayerCard`

**Role:** A person who opted into discovery. It is not a map marker and it has no coordinates.

**Anatomy:**

1. Top row: display name (`heading`) and a quiet level chip.
2. Meta, wrapping: format (Singles, Doubles, Both), home city, distance band in the API’s words (“within 5 km”). Never a street, never a pin, never a precise meter value.
3. Optional age band, only when that player set `show_age_band`. One chip: “18–24”, “25–34”, and so on. If the flag is false, omit it. Never show birth year.
4. Availability summary, `secondary`, one or two lines: “Weeknights, mornings”.
5. Goal, one line, if present.
6. Footer: primary or secondary “Request” / “Request pending” / “Message”. Pending is not tappable except to cancel. Message opens the thread.

**Layout:** Fill `card`, radius `lg`, padding `md`, 1pt hairline. Full width. No photo in MVP if none was collected at onboarding. Do not invent an avatar from a face API. A monogram disc, 40pt, `nightCourt` fill, `line` initial, is allowed and is decorative if the name is beside it.

**States:** Can request. Pending. Accepted (Message). Hidden after block (the card leaves the list). Over the free daily cap: do not render a partial card; the list ends with the limit empty state. Under 18 viewers never receive cards.

**Semantics:** “{name}, {level}, {format}, {distance band}. {availability}.” Request is its own button: “Send a play request to {name}.”

### Coach card

**Widget:** `BaselineCoachCard`

**Role:** A public coach or academy listing. Junior programs may appear here. They do not create a child account.

**Anatomy:**

1. Photo, 64 × 64, radius `sm`. If missing, a monogram on `fairway` with `line` initial. Photo is decorative when the name is next to it; otherwise alt text is the coach name.
2. Text column:
   - Name, `heading`.
   - Credentials, `secondary`, two lines.
   - Meta: audience (Adults, Juniors, Adults and juniors), format (Private, Group, Both), price text if present.
   - Specialties, quiet chips, wrapping. Max three on the card, rest on the detail screen.
3. Chevron.

**Layout:** Same shell as a tappable card: `card` fill, radius `lg`, padding `md`, the photo and text in a row, gap `md`. Minimum height 88.

**States:** Default. No “online now”. No booking checkout. If `contact_url` exists it is on the detail screen, not the card.

**Semantics:** “{name}, coach, {audience}, {format}. Opens profile.”

### Paywall

**Widget:** `BaselinePaywall`

**Role:** The only purchase surface. Lesson locks and the daily player cap navigate here. They do not embed their own price.

**Anatomy, top to bottom, on a `nightCourt` fill:**

1. Eyebrow “PREMIUM”, `ball`, excluded if the headline repeats it.
2. Headline, `display`, `line`, max three lines. Name the thing they were doing: “Keep going with the forehand” or, if opened from Profile, “Train with the full path”.
3. One sentence, `secondary` sized, color `mist`: what is on the other side of this screen.
4. Benefit list. Each row is a 24pt `ball` disc (decorative) and `line` text, `heading` weight 600 for the benefit, `mist` for one line of detail:
   - All published lessons and drills
   - Weekly plans built from your days and goal
   - Ask the pro
   - Full progress history
   - Unlimited partner browsing
5. Price block. Store product title and localized price from StoreKit or RevenueCat. Period underneath (“per month”, “per year”) from the product, not from a hard-coded string. No strike-through price.
6. Primary button, on-night variant: “Continue” or the store’s subscribe verb. Loading while the product loads: button disabled, label “Loading price”.
7. Secondary on night: “Restore purchases”.
8. Text button on night: “Not now”.
9. Legal, `meta`, `mist`: auto-renewal, cancel in the App Store, links to Terms and Privacy. This block is always present.

**States:**

| State | What the player sees |
|---|---|
| Ready | Price and Continue |
| Products loading | Benefits visible, price row is a 16pt-tall `track` on dark, button disabled |
| Products failed | “Prices aren’t available right now.” Retry. No invented price. |
| Purchase pending | Button shows a spinner and “Contacting the App Store” |
| Purchase failed | The store’s message in a high-contrast note, clay border, `line` text on `nightCourt` is illegal — use a `card` note with `ink` text sitting on the night page |
| Restore found nothing | “No Premium purchase was found for this Apple ID.” |
| Already premium | Do not open this screen. Callers pop back. |

**Semantics:** Headline is a header. Benefits are a list. The price is text, not an image. “Not now” is “Dismiss Premium offer”.

**Flutter:** A full-screen `Scaffold` with `backgroundColor: nightCourt`. This widget is also the body of the Paywall screen. Do not present it as a small dialog. A compact **locked continuation** used inside a lesson is not this widget; it is a `card` with a night header strip, the overview already shown above it, three benefit lines, and a primary “See Premium” that pushes this screen.

### Coach-answer card

**Widget:** `BaselineCoachAnswerCard`

**Role:** The rules-engine reply. It cites catalog items. It does not invent drill ids, and the UI must not invent any either. Only render links the payload includes.

**Anatomy:**

1. Eyebrow “COACHING ASSISTANCE”, `muted`. This one is **included** in semantics because the headline may not repeat it. Label the region “Coaching assistance”.
2. Summary, `heading`.
3. Causes, a list. Each cause is `body` with a 8pt `nightCourt` square bullet, decorative. Header “Likely causes”.
4. Technique row, if `nextTechniqueSlug` is present: a lesson-row-like control, “Open {technique name}”.
5. Drill cards, if any slugs returned, using `BaselineDrillCard` compact (name, minutes, objective only).
6. Practice note, `secondary`, if present.
7. Footer note, always, high-contrast, 3pt `nightCourt` border: “Coaching help, not medical advice.”

**Pain variant:** If the service (or the client’s pre-check for words about pain, injury, or swelling) returns the pain path, replace causes, technique, and drills with one note, 3pt `clay` border, title “Stop if something hurts”, body “A clinician or a coach in person should look at pain. Baseline will not suggest a fix.” The footer remains.

**Fallback variant:** Summary plus one link to the last unfinished lesson and one consistency drill, as the API describes. Title the cause list “A place to start” so it is not pretending to diagnose.

**Locked variant:** Free players do not see this card. They see the paywall. The Ask entry point can explain “Ask the pro is included with Premium” before the push.

**Semantics:** The card is a region named “Coaching assistance”. Links inside are buttons. The footer is text, not hidden.

### Empty states

**Widget:** `BaselineEmptyState`

**Role:** Explains a vacant list and, when there is a useful next step, offers one button.

**Anatomy:**

1. Court diagram, 120pt tall, decorative, `ExcludeSemantics`. Draw a baseline and a service box in `ink` strokes on `line`, plus one `ball` disc off to the side. No stock illustration, no people, no dumbbells.
2. Title, `title3`, `ink`, centered.
3. Body, `secondary`, `muted`, centered, max width 320 inside the column.
4. Optional button, primary or secondary, only one.

**Layout:** Centered in the remaining viewport above the tab bar. Padding `xxl`. If the screen already has a title in the app bar, the empty state does not repeat a second screen title; its title is the empty condition.

**Copy:**

| Id | Title | Body | Button |
|---|---|---|---|
| `courts` | No courts in this radius yet | Try a wider radius, or enter a city. | Widen radius |
| `playersOff` | You’re not visible yet | Turn on discovery to see players and send requests. People see a distance band, not your address. | Turn on discovery |
| `playersUnder18` | Partner finding starts at 18 | You can still learn, train, and find courts. | Find courts |
| `playersCap` | You’ve seen today’s free players | Premium removes the daily limit. | See Premium |
| `playersNone` | No players in this area yet | Save a court and check again later. Your area is only a distance band. | Find courts |
| `inbox` | No messages yet | When someone accepts a request, the conversation shows up here. A decline stays private. | Find a player |
| `search` | No matches | Try a stroke, a rule, or a place name. | none |
| `drills` | No drills for these filters | Clear filters to see the drills you can open. | Clear filters |
| `lessons` | No published lessons in this level yet | Level 1 is the full starting path. | Go to Level 1 |
| `plan` | No week planned yet | Tell Baseline the days you can train and it will build a week. | Build my week |
| `video` | This video can’t play | The written lesson is still available. | Back to the lesson |
| `chart` | Full history is part of Premium | Your streak and completed lessons stay visible. | See Premium |
| `pushOff` | Notifications are off in Settings | Your plan is still on the Train tab. | Open Settings |
| `favorites` | No saved places | Save a court, coach, or store and it will show up here. | Find a court |
| `reports` | No open reports | New player and content reports will land here. | none |

**Error variant:** Same anatomy. Title “Something went wrong.” Body is the API `message` when it is safe to show, otherwise “Try again.” Button “Try again”. Do not show raw codes (`premium_required`, `rate_limited`) as the title. Map `premium_required` to navigation to the paywall, not to this error. Map `rate_limited` to “Too many tries. Wait a minute and try again.” Map offline to “You’re offline. Try again when you are connected.” Do not promise an offline lesson cache; the product does not define one.

---

## Supporting controls

These are smaller than the required set. Screens assume them.

### Choice card

Onboarding answers. Min height 56, full width, radius `md`, fill `card`, 1pt hairline. Selected: 2pt `ink` border and a `fairway` check. Label `heading`. The whole card is the button, label equal to the choice. Multi-select (skills) toggles and does not advance until Continue.

### Text field

Height at least 52, radius `sm`, fill `card`, 1pt hairline, focus border 2pt `fairway`. Label above the field in `heading`, not only a placeholder. Error text under the field in `ink` on a transparent background, with a 3pt `clay` border on the field. The error is also announced. Password fields are out of scope; email sign-in is a one-time code.

### Search field

Pill, height 44, fill `card`, leading magnifier excluded from semantics, hint “Lessons, drills, courts”. Submit opens Search results. A clear button, 44pt, label “Clear search”, appears when there is text.

### Segmented control

Discover uses four segments: Courts, Players, Coaches, Stores. Height 44 including the touch target, radius `pill`, track `track`, selected segment `nightCourt` with `line` label. Semantics: “Courts, 1 of 4, selected.”

### Filter chip

Quiet level-chip geometry. Selected uses the selected level-chip colors. Label includes the category: “Surface, clay, selected”.

### Switch row

A row, min height 44, label and one-line description in a column, `Switch` trailing. The switch uses `fairway` when on and `track` when off, with an `ink` thumb outline in high contrast. Semantics live on the row: “{label}, {on or off}. {description}.”

### Video frame

Used at the top of a lesson and inside the video sheet.

- 16:9, full content width, radius `none` when full bleed, `sm` when inset.
- Poster is the first frame or a CMS image. Play button is a 64pt `ball` circle with an `ink` triangle, label “Play {title}”.
- Captions control, 44pt, label “Captions on” or “Captions off”, always visible. Default on when the system prefers captions.
- Transport: play/pause, scrubber with a 44pt hit height, elapsed and duration as text.
- Attribution under the frame, `meta`: “{creator}. {license name}. {source name}.” This is required whenever a third-party embed or Creative Commons clip plays. Original Baseline video still shows “Baseline” as the creator.
- No download, no share-file, no “open mp4” action.
- Missing or blocked video: do not render the frame. The technique sections start immediately. A failed load after tap uses the `video` empty state inside the sheet.

### Locked continuation

The in-lesson Premium gate. Not the paywall.

- Shown after the overview block. Later blocks are not in the tree, so they cannot be scrolled to.
- `card`, radius `lg`, night header strip 8pt tall.
- Title “The rest of this lesson is Premium”.
- Three lines: steps and checkpoints, the video if one is attached, the related drill.
- Primary button “See Premium”.
- The overview above remains selectable and readable.

### Sponsored mark and Baseline pick

Sponsored: pill, 1pt `ink` border, transparent fill, label “Sponsored”, `meta`. Placed above the product name. Baseline pick: 8pt `ball` disc plus “Baseline pick” in `meta`. A card is never both. Sponsored cards are outside the Baseline pick list, with their own heading “From our partners”.

### Sticky footer

A column at the bottom of the scaffold: baseline rule, `md` padding, the primary button, `SafeArea`. Used on onboarding, the lesson reader, the drill detail, the session logger, and confirmations.

### Toast

A short confirmation, `nightCourt` fill, `line` text, radius `sm`, above the tab bar, 4 seconds. Used for “Saved”, “Request sent”, “Thanks, we received this.” It is polite live-region text (`Semantics` live region). Errors use the empty-state error variant or an inline note, not a toast that disappears before it can be read.

## Admin specifics

The CMS uses the same tokens. Canvas is `line`. Left nav is 240pt wide, `nightCourt` fill, `line` labels, selected item has a 3pt `ball` bar on its left edge. Content max width 960, centered in the remaining space. Tables use `heading` for the primary column and `meta` for status. Required fields show “Required” in `muted` next to the label and a `clay` border when empty on submit. Publish is a primary button. It stays disabled until the licensing checklist is complete, and the disabled reason is listed in text above the button, not only in a tooltip.

Editors see Save draft. Admins see Publish and Unpublish. Suspend appears only on the report queue and only for admins.

## What not to build into the theme

- A dark-mode `ThemeData` for MVP.
- A sixth tab, a community composer, or a swing-upload button.
- Star ratings on courts. Reviews are deferred.
- A hard-coded price, a fake discount, or a countdown.
- Player map pins, heat maps, or “distance from you: 180 m”.
- Download or raw-file actions on video.
