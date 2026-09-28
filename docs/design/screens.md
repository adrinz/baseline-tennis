# Baseline screens

Wireframes for every MVP screen in [user-flows-and-navigation.md](../user-flows-and-navigation.md). Visual rules live in [design-system.md](design-system.md). Components named here (`BaselineLessonRow`, `BaselinePaywall`, and the rest) are defined there.

ASCII frames are structure, not pixel specs. Spacing, type, and color come from the design system. The phone frame starts under the status bar. Tab roots include the tab bar. Pushed screens include a back button. There is no sixth tab.

## How to read a frame

- `[ Primary ]` is `BaselinePrimaryButton`.
- `( Secondary )` is `BaselineSecondaryButton`.
- `{ text }` is a text button.
- A line of `────` is a baseline rule or a hairline.
- Copy in a frame is the intended MVP string unless marked as sample content.

## Shared behavior

**Shell.** After onboarding, Home, Learn, Train, Discover, and Profile stay in the tab bar. Welcome through plan preview, the paywall, the video sheet, and admin have no tab bar.

**Priority of the next action.** Each screen has one primary button. Home reorders modules so the unfinished action is first (rules below).

**Premium.** A locked lesson still shows its title, summary, and overview, then a locked continuation. Purchase happens only on Paywall. The app does not hard-code a price. `premium_required` navigates to Paywall. It is not an error toast.

**Errors.** Offline: “You’re offline. Try again when you are connected.” Rate limit: “Too many tries. Wait a minute and try again.” Other failures use the empty-state error variant with “Try again”. Do not show raw error codes.

**Age.** Under 16 cannot finish signup. Ages 16–17 use Learn, Train, courts, coaches, and stores. Players, requests, and messages stay off. The server enforces that. Hiding the segment is not the only control.

**Location.** Asked when the player opens Discover or chooses “use my location,” and during onboarding. Courts, coaches, and stores may be mapped. Players never are.

**Video.** A lesson is complete without a video. No download control. Captions are available whenever a frame is shown.

**VoiceOver.** Icon-only controls use the labels in the design system. Onboarding, the lesson reader, and the session logger must be completable with VoiceOver, 44pt targets, and Dynamic Type up to at least 2.0.

## Screen index

| # | Screen | Section |
|---|---|---|
| 1 | Welcome | First run |
| 2 | Sign in | First run |
| 3 | Email code | First run |
| 4 | Age gate | First run |
| 5 | Onboarding questions | First run |
| 6 | Plan preview | First run |
| 7 | Home | Home |
| 8 | Level list | Learn |
| 9 | Lesson list | Learn |
| 10 | Lesson reader | Learn |
| 11 | Technique page | Learn |
| 12 | Video player sheet | Learn |
| 13 | Rules index | Learn |
| 14 | Glossary | Learn |
| 15 | Week plan | Train |
| 16 | Drill list | Train |
| 17 | Drill detail | Train |
| 18 | Session logger | Train |
| 19 | Match prep | Train |
| 20 | Match log form | Train |
| 21 | Coach ask | Train |
| 22 | Discover map/list | Discover |
| 23 | Court detail | Discover |
| 24 | Player cards | Discover |
| 25 | Player request | Discover |
| 26 | Coach detail | Discover |
| 27 | Store detail | Discover |
| 28 | Equipment guide | Discover |
| 29 | Product detail | Discover |
| 30 | Paywall | Account |
| 31 | Inbox | Account |
| 32 | Thread | Account |
| 33 | Profile | Account |
| 34 | Edit profile | Account |
| 35 | Notifications | Account |
| 36 | Privacy | Account |
| 37 | Subscription | Account |
| 38 | Search results | Account |
| 39 | Admin login | Admin |
| 40 | Content list | Admin |
| 41 | Content editor | Admin |
| 42 | Video license panel | Admin |
| 43 | Place editor | Admin |
| 44 | Report queue | Admin |

Player request is the confirmation step of Player cards. The rules article is the second frame under Rules index, because the index would otherwise be a dead end.

---

## First run

### 1. Welcome

**Purpose.** State the promise and start account creation. Sign in with Apple is on this screen because Google is offered later.

**Key elements.** Night-court full bleed. Wordmark. One sentence. Primary “Get started”. Official Sign in with Apple button, same width, directly under the primary, white per Apple’s guidance on a dark background. Text button for an existing account. Terms and Privacy as text buttons.

**Primary action.** Get started → Sign in.

**States.** None empty. If Apple fails, inline error note and the buttons remain.

```
┌────────────────────────────────────┐
│                                    │
│ BASELINE                           │
│ ════════════                       │
│                                    │
│ Learn tennis from              │
│ a solid base.                      │
│                                    │
│ Lessons, drills, courts,           │
│ and people to hit with.            │
│                                    │
│ [ Get started ]                    │
│                                    │
│ ┌────────────────────────────────┐ │
│ │  Sign in with Apple            │ │
│ └────────────────────────────────┘ │
│                                    │
│ { I already have an account }      │
│                                    │
│ { Terms }          { Privacy }     │
└────────────────────────────────────┘
```

The sentence under the wordmark is one line at the default size and may wrap: “Learn tennis from a solid base.”

VoiceOver order: wordmark, sentence, Get started, Sign in with Apple, I already have an account, Terms, Privacy.

### 2. Sign in

**Purpose.** Apple, Google, or email. Apple is first and the same visual weight as Google.

**Key elements.** App bar “Sign in” with back. Three full-width choices. Short reassurance about age and privacy. Links repeat Terms and Privacy.

**Primary action.** The provider the player taps. Apple and Google complete in the system sheet and then go to the age gate if birth year is missing, or Home if the profile exists. Email goes to Email code.

**States.** Provider error: inline note “That didn’t sign you in. Try again or use email.” Buttons stay enabled. Loading: the tapped button shows a spinner and the others go disabled until it returns.

```
┌────────────────────────────────────┐
│ ←  Sign in                         │
│ ────────────────────────────────── │
│                                    │
│ Use the account you               │
│ want on this phone.                │
│                                    │
│ ┌────────────────────────────────┐ │
│ │  Sign in with Apple            │ │
│ └────────────────────────────────┘ │
│ ┌────────────────────────────────┐ │
│ │  Continue with Google          │ │
│ └────────────────────────────────┘ │
│ ( Continue with email )            │
│                                    │
│ Baseline is for ages 16 and up.    │
│                                    │
│ { Terms }          { Privacy }     │
└────────────────────────────────────┘
```

### 3. Email code

**Purpose.** Send a one-time code, then collect it. There is no password in MVP.

**Key elements.** Email field with label. Send code. After a successful send, a six-digit field, paste-friendly, each digit area at least 44pt wide. Resend. Change email.

**Primary action.** Address step: “Send code”. Code step: “Continue” (also fires when the sixth digit lands).

**States.** Invalid email: field error “Enter a valid email.” Wrong code: “That code doesn’t match. Request a new one.” The digits clear. Resend is disabled for 30 seconds with the label “Resend code in 0:30”. Rate limit uses the shared copy. Success moves to the age gate or Home.

```
┌────────────────────────────────────┐
│ ←  Email                           │
│ ────────────────────────────────── │
│                                    │
│ Email                              │
│ ┌────────────────────────────────┐ │
│ │ you@example.com                │ │
│ └────────────────────────────────┘ │
│                                    │
│ [ Send code ]                      │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│ ←  Check your email                │
│ ────────────────────────────────── │
│                                    │
│ We sent a 6-digit code to          │
│ you@example.com.                   │
│                                    │
│ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐│
│ │ 4 │ │ 1 │ │   │ │   │ │   │ │   ││
│ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘│
│                                    │
│ { Resend code in 0:30 }            │
│ { Use a different email }          │
└────────────────────────────────────┘
```

Semantics for the code: one text field, “6-digit code”, not six unlabeled boxes, even if the visuals are split.

### 4. Age gate

**Purpose.** Collect birth year. Under 16 cannot have an account. Ages 16–17 continue without partner discovery.

**Key elements.** Year field, no default year, not a full birth date. Plain explanation. Continue.

**Primary action.** Continue.

**States.**

- Empty or not a year: “Enter the 4-digit year you were born.”
- Under 16: replace the form with a stop. “Baseline is for ages 16 and older.” Primary “Close” signs out and returns to Welcome. If a user row was created, the client deletes it before leaving. No onboarding.
- 16–17: Continue is enabled. A note under the button: “You can learn, train, and find courts. Finding players is available at 18.”
- 18 or older: Continue, no extra note.

```
┌────────────────────────────────────┐
│ ←  About you                       │
│ ────────────────────────────────── │
│                                    │
│ What year were you born?           │
│                                    │
│ We use this only to apply          │
│ age rules. It is not shown         │
│ on your player card.               │
│                                    │
│ Birth year                         │
│ ┌────────────────────────────────┐ │
│ │                                │ │
│ └────────────────────────────────┘ │
│                                    │
│ [ Continue ]                       │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│    Ages 16 and up                  │
│ ────────────────────────────────── │
│                                    │
│ Baseline is for ages               │
│ 16 and older.                      │
│                                    │
│ [ Close ]                          │
└────────────────────────────────────┘
```

### 5. Onboarding questions

**Purpose.** One question per screen, in order, so a new player reaches lesson 1 in under two minutes. Finishing creates the profile, the starting level, one goal, and the first week.

**Key elements.** Back. Progress as text “4 of 10” and a 4pt track with a fairway fill and a ball knob. The text is the accessible name: “Question 4 of 10.” Question title in `title1`. Choice cards. Sticky Continue when the answer is not a single tap.

**Primary action.** A single-select card both selects and advances. Multi-select, location, and availability use Continue.

**Skipped questions.** If birth year is under 18, skip question 10 and do not ask to find partners.

**States.** Continue stays disabled until the question has a valid answer. System location denial is not an error; focus moves to the city field.

Shared chrome:

```
┌────────────────────────────────────┐
│ ←                      4 of 10     │
│ ──────────────●───────────────     │
│                                    │
│ Question title                     │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ Choice                         │ │
│ └────────────────────────────────┘ │
│ ┌────────────────────────────────┐ │
│ │ Choice                         │ │
│ └────────────────────────────────┘ │
│                                    │
│ [ Continue ]                       │
└────────────────────────────────────┘
```

| Step | Title | Choices | Notes |
|---|---|---|---|
| 1 | Have you played before? | Not yet · Yes | Single select. Advances on tap. |
| 2 | What level fits you now? | The five levels, each card is the name plus one plain line (below) | Subcopy on the screen: “Levels are guidelines. You can change this later.” |
| 3 | How often do you play now? | Never · A few times a year · Monthly · Weekly · Several times a week | |
| 4 | What do you want most? | Learn from scratch · Fix a stroke · Consistency · Play a first match · Singles · Doubles · Fitness · Tournament prep | This becomes the active goal. |
| 5 | How do you want to play? | Singles · Doubles · Both | |
| 6 | How many days a week can you train? | 2 · 3 · 4 · 5+ | Feeds the week plan. |
| 7 | What do you want to improve? | Forehand · Backhand · Serve · Return · Volley · Footwork · Rallying fundamentals · Fitness | Multi-select. At least one. Continue. |
| 8 | Find courts near you | Use my location · city field | Copy below. Continue when permission is granted or the city has two or more characters. |
| 9 | Where do you prefer to play? | Indoor · Outdoor · Either | |
| 10 | Find players near you? | Not now · Yes, show availability | Shown only at 18+. “Not now” advances. “Yes” reveals the availability grid on the same screen and does **not** set discoverable. Copy: “We’ll ask you to confirm a general area before anyone can see you.” |

Level cards, step 2:

| Level | Line on the card |
|---|---|
| 1 Complete Beginner | New to the game, or starting over. |
| 2 Beginner | You have rallied and want reliable contact. |
| 3 Advanced Beginner | You play points and want a fuller game. This is the deepest path. |
| 4 Intermediate | You compete and want targeted practice. The path is shorter for now. |
| 5 Advanced | You train with intent. Key techniques and drills are here. Outline depth. |

Step 8 frame:

```
┌────────────────────────────────────┐
│ ←                      8 of 10     │
│ ────────────────────●─────────     │
│                                    │
│ Find courts near you               │
│                                    │
│ Baseline uses your location to     │
│ show nearby courts, coaches, and   │
│ stores. You can type a city        │
│ instead.                           │
│                                    │
│ [ Use my location ]                │
│                                    │
│ City                               │
│ ┌────────────────────────────────┐ │
│ │                                │ │
│ └────────────────────────────────┘ │
│                                    │
│ [ Continue ]                       │
└────────────────────────────────────┘
```

If the system dialog is denied, the body adds: “Location stayed off. Type a city to continue.”

Step 10 availability, after Yes:

```
│ Days you can hit                   │
│ [ Mon ] [ Tue ] [ Wed ] [ Thu ]    │
│ [ Fri ] [ Sat ] [ Sun ]            │
│                                    │
│ Times                              │
│ [ Morning ] [ Afternoon ] [ Evening ]│
│                                    │
│ [ Continue ]                       │
```

At least one day and one time before Continue. Chips are filter chips, min 44pt.

### 6. Plan preview

**Purpose.** Show the first week before Home. The player can change days or accept.

**Key elements.** Title “Your first week”. The goal in an eyebrow. Three or four day cards (or five if they chose 5+; show five). Each day is an ordered list of blocks: warm-up, footwork, focus, second stroke, serve or rally, close, with minutes. Edit days. Accept.

**Primary action.** “Start week” → Home, with Level 1, lesson 1 highlighted. If they picked a higher starting level, highlight that level’s first published lesson instead, and still offer Level 1 in Learn.

**States.** Rebuild in flight: the list dims and the button reads “Building your week”. Failure: “The week didn’t build. Try again.” Edit days swaps the day cards for the same 2 / 3 / 4 / 5+ choices, then reloads the preview.

```
┌────────────────────────────────────┐
│ ←  Your first week                 │
│ ────────────────────────────────── │
│ LEARN FROM SCRATCH                 │
│                                    │
│ Three sessions · about 60 min      │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ Tuesday · 60 min               │ │
│ │ Warm-up                    8   │ │
│ │ Split step                10   │ │
│ │ Ready position            20   │ │
│ │ Rallying fundamentals     15   │ │
│ │ Close                      7   │ │
│ └────────────────────────────────┘ │
│ ┌────────────────────────────────┐ │
│ │ Thursday · 60 min              │ │
│ │ …                              │ │
│ └────────────────────────────────┘ │
│                                    │
│ ( Edit days )                      │
│ [ Start week ]                     │
└────────────────────────────────────┘
```

Sample block titles above are illustrative. Real titles come from `PlanBuilder`.

---

## Home

### 7. Home

**Purpose.** Get the player into the next unfinished action, then show the rest of the loop: train, drill, progress, nearby places, a video, the goal.

**Key elements.** Wordmark and search. Time-of-day greeting (“Good morning”, “Good afternoon”, “Good evening”) without a name until `display_name` is set. Then the modules below. Ask the pro sits under the goal as a secondary button. Profile-tab badge is independent of this screen.

**Primary action.** Whichever module is the hero. One primary button on the hero only. Other modules are rows, not extra primaries.

**Order.**

1. Hero, chosen by the first match:
   - A plan block is due today and not done → Today’s training, button “Start {block}”.
   - No lesson has been completed → “Start level 1”, button “Start {lesson 1 title}”.
   - Otherwise → Continue learning, button “Continue”.
2. The other learning or training module that was not promoted.
3. Recommended drill.
4. Progress snapshot.
5. Shortcuts: Court, Player, Coach, Store.
6. Recommended video.
7. Active goal, then “Ask the pro”.

**States.**

- New player: hero is Start level 1. Today’s training still appears under it if the week exists, but it is not first.
- Plan due: hero is today’s training.
- Premium plan locked (free player after the free plan window): the training card is the locked continuation, “Weekly plans are Premium”, button “See Premium”. Do not show an empty plan.
- Video missing: omit the video module. Do not leave a hole.
- Progress loading: rings show “—”.
- Offline: error note at the top, modules that have nothing to show use the error empty state.

Returning player, plan due:

```
┌────────────────────────────────────┐
│ BASELINE                       ⌕   │
│ Good evening                       │
│                                    │
│ TODAY                              │
│ ┌────────────────────────────────┐ │
│ │ Tuesday · 60 min               │ │
│ │▌Warm-up                  8  Done│ │
│ │█Split step             10      │ │
│ │  [ Start split step ]          │ │
│ │  Forehand               20      │ │
│ └────────────────────────────────┘ │
│                                    │
│ CONTINUE                           │
│ Ready position                     │
│ Level 1 · 8 min · In progress      │
│                                    │
│ DRILL                              │
│ Wall rally · 20 min · No court     │
│                                    │
│ PROGRESS                           │
│ ( 2 )   2 lessons                  │
│  of 12  40 min · 4 day streak      │
│                                    │
│ NEAR YOU                           │
│ Court  Player  Coach  Store        │
│                                    │
│ WATCH                              │
│ ┌────────────────────────────────┐ │
│ │            ▶                   │ │
│ └────────────────────────────────┘ │
│ Ready position · 1:12              │
│ Baseline                           │
│                                    │
│ GOAL                               │
│ Learn from scratch                 │
│ ( Ask the pro )                    │
├────────────────────────────────────┤
│ Home  Learn  Train  Discover  You  │
└────────────────────────────────────┘
```

New player hero replaces the Tuesday card at the top:

```
│ START                              │
│ ┌────────────────────────────────┐ │
│ │ Level 1 · Complete Beginner    │ │
│ │ Ready position                 │ │
│ │ 8 min · Lesson 1               │ │
│ │ [ Start ready position ]       │ │
│ └────────────────────────────────┘ │
```

Shortcuts are four equal targets, each at least 44pt tall, icon plus word. Player shortcut for under 18 goes to the under-18 empty state on Player cards, not to a hidden tab. Search opens Search results.

---

## Learn

The Learn tab root is the level list. Techniques, rules, glossary, and videos are reached from it.

### 8. Level list

**Purpose.** Show the five levels, the current lesson, and the doors to techniques, rules, glossary, and videos.

**Key elements.** “Levels are guidelines.” Five level rows with name, a one-line summary, and “{done} of {published}”. Current level uses the current level chip. Continue row if a lesson is in progress. Links: Techniques, Rules, Glossary. A horizontal video strip of licensed clips attached to lessons the player may play. Levels 4 and 5 are visible even when short.

**Primary action.** The continue row, or Level 1 if nothing is in progress. The row is the button. There is no second primary.

**States.** A level with zero published lessons uses the row subtitle “Lessons are on the way” and still opens an empty lesson list. Video strip hidden if there are no playable videos.

```
┌────────────────────────────────────┐
│ Learn                          ⌕   │
│ ────────────────────────────────── │
│ Levels are guidelines.             │
│                                    │
│ CONTINUE                           │
│ Ready position · Lesson 1          │
│                                    │
│ 1 Complete Beginner          2/12  │
│ New to the game.                   │
│ 2 Beginner                   0/10  │
│ Reliable contact.                  │
│ 3 Advanced Beginner          0/14  │
│ The deepest path.                  │
│ 4 Intermediate             Outline │
│ Key techniques and drills.         │
│ 5 Advanced                 Outline │
│ Key techniques and drills.         │
│                                    │
│ Techniques                         │
│ Rules                              │
│ Glossary                           │
│                                    │
│ VIDEOS                             │
│ [ poster ] [ poster ] [ poster ]   │
├────────────────────────────────────┤
│ Home  Learn  Train  Discover  You  │
└────────────────────────────────────┘
```

Technique index opens from Techniques: a list grouped by family (ready, grip, footwork, groundstroke, net, serve, return, rally, specialty). Each row is the technique name, difficulty ticks, and level minimum. That list is this same Learn stack, not a new tab. Frame:

```
┌────────────────────────────────────┐
│ ←  Techniques                      │
│ ────────────────────────────────── │
│ READY                              │
│ Ready position                 L1  │
│ Split step                     L1  │
│                                    │
│ GROUNDSTROKE                       │
│ Forehand                       L1  │
│ Backhand                       L2  │
└────────────────────────────────────┘
```

Empty family: omit the header. Search in the app bar searches the whole catalog, not only techniques.

### 9. Lesson list

**Purpose.** Every published lesson in one level, in path order.

**Key elements.** Level name. Guideline sentence. `BaselineLessonRow` for each lesson. Premium rows show the lock and the word Premium. A line “Suggested after {title}” when a prerequisite exists. The row still opens.

**Primary action.** Tap a row → lesson reader.

**States.** Empty level: `lessons` empty state. Free player scrolling into Premium lessons: those rows stay visible and locked. No surprise dialog.

```
┌────────────────────────────────────┐
│ ←  Complete Beginner               │
│ ────────────────────────────────── │
│ Levels are guidelines.             │
│                                    │
│ 1  Ready position            8 min │
│    In progress                     │
│ 2  Grips                     10 min│
│    Not started                     │
│ 3  Forehand                  12 min│
│    Premium                         │
└────────────────────────────────────┘
```

### 10. Lesson reader

**Purpose.** Teach one lesson. Video first when a licensed video exists. Text stands alone when it does not. Mark complete, then the next lesson or a related drill.

**Key elements.** App bar title is the lesson name. Meta row: level chip, minutes, difficulty as “Difficulty 2 of 5” plus five baseline ticks. Video frame full width if `lesson_videos` has a published, licensed video the player is allowed to play. Attribution under it. Then technique sections in block order: overview, why, steps, tips, mistakes, beginner mistakes, checklist, text. Related drills as drill cards. Sticky footer.

**Primary action.** “Mark complete”. If this lesson is already complete, the footer primary becomes “Next lesson” when `next_lesson_id` exists, otherwise “Related drill”.

**States.**

- **Text only.** No video frame. Sections start under the meta row. This is the required fallback, not an error.
- **Video failed.** Frame area becomes the `video` empty state. Sections remain under it.
- **Premium lock.** Overview section renders. Locked continuation replaces every later block and the video. Footer primary is “See Premium”. “Mark complete” is absent.
- **Checklist.** Boxes are optional. They do not gate the footer.
- **Just completed.** Footer swaps to the next action. A toast “Lesson complete”. Streak updates if this was the day’s qualifying work. Do not show XP math on this screen.

Free lesson with video:

```
┌────────────────────────────────────┐
│ ←  Ready position                  │
│ ────────────────────────────────── │
│ L1 Complete Beginner · 8 min       │
│ Difficulty 1 of 5  ▌▌▌▌▌           │
│ ┌────────────────────────────────┐ │
│ │                                │ │
│ │              ▶                 │ │
│ │                         [CC]   │ │
│ └────────────────────────────────┘ │
│ Baseline · Original · 1:12         │
│                                    │
│ OVERVIEW                           │
│ The ready position is where        │
│ every shot starts.                 │
│                                    │
│ WHY IT MATTERS                     │
│ …                                  │
│                                    │
│ STEPS                              │
│ ┌──┐                               │
│ │1 │ Feet wider than your hips    │
│ └──┘                               │
│ ┌──┐                               │
│ │2 │ Weight on the balls of       │
│ └──┘    your feet                  │
│                                    │
│ ┌ Tip ───────────────────────────┐ │
│ │ Stay low enough to push off.   │ │
│ └────────────────────────────────┘ │
│ ┌ Common miss ───────────────────┐ │
│ │ Standing straight up.          │ │
│ └────────────────────────────────┘ │
│                                    │
│ CHECKLIST                          │
│ ☐ Feet set                         │
│ ☐ Knees soft                       │
│                                    │
│ DRILL                              │
│ Shadow ready position · 5 min      │
├────────────────────────────────────┤
│ [ Mark complete ]                  │
└────────────────────────────────────┘
```

Locked continuation, after the overview only:

```
│ OVERVIEW                           │
│ A forehand starts in the           │
│ ready position…                    │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ The rest of this lesson        │ │
│ │ is Premium                     │ │
│ │                                │ │
│ │ Steps, checklist, and video    │ │
│ │ Related drill                  │ │
│ │ [ See Premium ]                │ │
│ └────────────────────────────────┘ │
```

“Ask the pro” is a text button under the drills, not a second primary. It opens Coach ask with the technique name as context.

### 11. Technique page

**Purpose.** The reference for one technique, reachable from Learn and from a coach answer. Readable with no video.

**Key elements.** Name, family eyebrow, difficulty, level minimum, reps if present. Sections in this order: overview, why it matters, steps, tips, mistakes, drills, checklist, related techniques (`next` and `similar`). Optional video frame only when a published licensed video is linked.

**Primary action.** “Start drill” when a drill is linked, otherwise “Open lesson” when a lesson points here. If both exist, the drill is primary and the lesson is secondary.

**States.** Draft techniques are not shown. Missing video: no frame. Premium drills on the page use the locked drill card. Related techniques are text rows, not a graph.

```
┌────────────────────────────────────┐
│ ←  Forehand                        │
│ ────────────────────────────────── │
│ GROUNDSTROKE                       │
│ Difficulty 2 of 5 · From level 1   │
│ Suggested reps · 20                │
│                                    │
│ Overview, why, steps, tip,         │
│ common miss, checklist             │
│ (same section anatomy as a lesson) │
│                                    │
│ DRILLS                             │
│ [ Wall rally                 ]     │
│                                    │
│ RELATED                            │
│ Next · Contact point               │
│ Similar · Rallying fundamentals    │
├────────────────────────────────────┤
│ [ Start drill ]                    │
│ ( Open lesson )                    │
└────────────────────────────────────┘
```

### 12. Video player sheet

**Purpose.** Play one licensed video without leaving the lesson. Dismiss returns to the same scroll position.

**Key elements.** Sheet radius `xl`, night fill. Close, 44pt, label “Close video”. 16:9 frame. Captions control. Scrubber with 44pt hit height. Elapsed and duration as text. Attribution line. No download, no air-drop of a file, no third-party mp4 link.

**Primary action.** Play / pause. The play control is the ball button.

**States.** Loading. Playing. Paused. Captions on or off. Failed: `video` empty state inside the sheet, “Back to the lesson” dismisses. Embed mode uses the provider player inside the same sheet and still shows Baseline’s attribution line under it. Owned mode uses a signed URL and never displays that URL.

```
┌────────────────────────────────────┐
│ ┌────────────────────────────────┐ │
│ │ Close                      CC  │ │
│ │                                │ │
│ │              ▶                 │ │
│ │                                │ │
│ │ 0:12 ─────────●───── 1:12      │ │
│ │ Baseline · Original            │ │
│ └────────────────────────────────┘ │
│                                    │
│ Lesson text still underneath       │
└────────────────────────────────────┘
```

### 13. Rules index

**Purpose.** Original Baseline articles about how the game is played. Not a copy of the ITF rulebook.

**Key elements.** Grouped rows for scoring, singles, doubles, serve, let, tiebreak, lines, conduct. Each row is the article title and one-line summary.

**Primary action.** Open an article.

**States.** Empty topic: omit the topic. Article with no body: do not list it.

```
┌────────────────────────────────────┐
│ ←  Rules                           │
│ ────────────────────────────────── │
│ SCORING                            │
│ How a game is scored               │
│ Tiebreak                           │
│                                    │
│ LINES                              │
│ When a ball is in                  │
└────────────────────────────────────┘
```

**Rules article** (pushed from the index):

**Purpose.** Read one article.

**Key elements.** Title, body blocks using technique-section text styles, no complete button, no video required.

**Primary action.** Back.

**States.** Load error uses the shared error empty state.

```
┌────────────────────────────────────┐
│ ←  When a ball is in               │
│ ────────────────────────────────── │
│                                    │
│ A ball that lands on the line      │
│ is in.                             │
│                                    │
│ …                                  │
└────────────────────────────────────┘
```

### 14. Glossary

**Purpose.** Short original definitions, searchable.

**Key elements.** Search field bound to this list. Rows: term and definition. Quiet level chip when `level_min` is above 1. Tap expands the definition in place. Expanded definition is `body`, not a new screen.

**Primary action.** Focus search, or expand a term.

**States.** No query match: “No terms match that.” Clear. Empty catalog should not happen in production; if it does, “Glossary is on the way.”

```
┌────────────────────────────────────┐
│ ←  Glossary                        │
│ ────────────────────────────────── │
│ ( Search terms                 )   │
│                                    │
│ Deuce                              │
│ The score when both sides          │
│ have 40.                           │
│                                    │
│ Let                          L1    │
│ A serve that is replayed.          │
└────────────────────────────────────┘
```

---

## Train

The Train tab root is the week plan.

### 15. Week plan

**Purpose.** This week’s generated plan, plus doors to the drill library, logging, match prep, and the match log.

**Key elements.** Week range. Goal. Day cards of `BaselinePlanBlock`. A text link “Change days” rebuilds via the 2 / 3 / 4 / 5+ choices. Rows: Drill library, Log a session, Match prep, Match log.

**Primary action.** “Start {current block}” on today’s current block. If today has no remaining block, primary is absent and the next day is labeled “Next”.

**States.**

- No plan: `plan` empty state, “Build my week”.
- Free player without the premium plan entitlement: locked continuation instead of day cards. “Weekly plans are Premium.” Drill library and match log remain reachable. The free drill set is the way to train.
- Rebuild failure: keep the previous week on screen and show an inline error.
- All blocks done: a fairway note “Week complete” and the drill library as the next place to go. No fake extra workout.

```
┌────────────────────────────────────┐
│ Train                              │
│ ────────────────────────────────── │
│ Sep 22–28 · Learn from scratch     │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ Tuesday · 60 min               │ │
│ │▌Warm-up               8   Done │ │
│ │█Split step          10         │ │
│ │  [ Start split step ]          │ │
│ │  Ready position      20        │ │
│ └────────────────────────────────┘ │
│ ┌────────────────────────────────┐ │
│ │ Thursday · 60 min              │ │
│ │  …                             │ │
│ └────────────────────────────────┘ │
│                                    │
│ { Change days }                    │
│                                    │
│ Drill library                      │
│ Log a session                      │
│ Match prep                         │
│ Match log                          │
├────────────────────────────────────┤
│ Home  Learn  Train  Discover  You  │
└────────────────────────────────────┘
```

### 16. Drill list

**Purpose.** Find a drill by level and stroke.

**Key elements.** Filter chips: level (all or 1–5) and stroke family (forehand, backhand, serve, return, volley, footwork, rallying fundamentals). `BaselineDrillCard` list. Free drills open fully. Premium drills show name, objective, and the lock.

**Primary action.** Open a card.

**States.** No matches: `drills` empty state. Loading: three card-shaped tracks, announced as “Loading drills”.

```
┌────────────────────────────────────┐
│ ←  Drills                          │
│ ────────────────────────────────── │
│ [ All levels ] [ Forehand ]        │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ Wall rally              L1     │ │
│ │ Keep a ball in play.           │ │
│ │ 20 min · 1 player · Wall       │ │
│ │ No court                       │ │
│ └────────────────────────────────┘ │
│ ┌────────────────────────────────┐ │
│ │ Cross-court rally       L3     │ │
│ │ Premium · objective only       │ │
│ └────────────────────────────────┘ │
└────────────────────────────────────┘
```

### 17. Drill detail

**Purpose.** Enough setup to run the drill, then log it.

**Key elements.** Name, level, objective. Meta: duration, repetitions, players, equipment. Court setup in words plus a simple court diagram (decorative if the words repeat it). Instructions as numbered steps. Coaching tips and common misses as high-contrast notes. Video frame only when licensed. Sticky footer.

**Primary action.** “Log this drill” → session logger with the drill attached.

**States.** Premium locked: objective and meta only, then locked continuation, footer “See Premium”. No instructions in the tree. Video missing: no frame. Already logged today: footer still allows another log; meta says “Logged today”.

```
┌────────────────────────────────────┐
│ ←  Wall rally                      │
│ ────────────────────────────────── │
│ L1 · Keep a ball in play           │
│ 20 min · 30 reps · 1 player        │
│ Racket, balls                      │
│                                    │
│ SETUP                              │
│ ┌────────────────────────────────┐ │
│ │  court lines, you at baseline  │ │
│ └────────────────────────────────┘ │
│ Stand 12 steps from a wall.        │
│                                    │
│ STEPS                              │
│ 1  Drop and hit to the wall        │
│ 2  Let it bounce                   │
│ 3  Hit again, aim above a mark     │
│                                    │
│ ┌ Tip ───────────────────────────┐ │
│ │ Height over power.             │ │
│ └────────────────────────────────┘ │
│ ┌ Common miss ───────────────────┐ │
│ │ Creeping closer after misses.  │ │
│ └────────────────────────────────┘ │
├────────────────────────────────────┤
│ [ Log this drill ]                 │
└────────────────────────────────────┘
```

### 18. Session logger

**Purpose.** Record minutes for a plan block or a drill. Optional timer. Updates the streak when the save succeeds.

**Key elements.** What is being logged (“Split step” or “Wall rally”). Minutes stepper, default from the block or drill, minimum 1, maximum 180. Optional timer: start, pause, and “Use this time”, which writes the elapsed minutes. Note field, optional, one short paragraph. Sticky save.

**Primary action.** “Save session”.

**States.** Saving disables the button. Success pops to the previous screen and toasts “Session saved”. If the streak incremented, the toast is “Session saved. Streak is {n} days.” Failure keeps the form and shows an inline error. Timer is optional; saving does not require it to have run.

```
┌────────────────────────────────────┐
│ ←  Log session                     │
│ ────────────────────────────────── │
│ Split step                         │
│ Footwork · planned 10 min          │
│                                    │
│ Minutes                            │
│ ( − )        10            ( + )   │
│                                    │
│ ( Start timer )                    │
│                                    │
│ Note                               │
│ ┌────────────────────────────────┐ │
│ │ Optional                       │ │
│ └────────────────────────────────┘ │
├────────────────────────────────────┤
│ [ Save session ]                   │
└────────────────────────────────────┘
```

VoiceOver: the stepper buttons are “Decrease minutes” and “Increase minutes”. The value is “10 minutes”.

### 19. Match prep

**Purpose.** Three short checklists: before, during, and after a match. Included in Train for 1.0 when schedule allows; the screen exists either way so the tab does not change later.

**Key elements.** Segmented control: Before, During, After. Checklist rows, local to the phone for the day, not a gate. A footer link “Log the match” to the match log form.

**Primary action.** “Log the match” on the After segment. Before and During have no primary; checking items is the work.

**States.** All items checked: the segment label gains “Done”. Items are sample copy the CMS may replace; ship these if the CMS has none.

| Segment | Items |
|---|---|
| Before | Water and balls · Know the format · Arrive with time to warm up · One cue for the first point |
| During | Use the cue between points · Notice serve, return, and focus · Reset after a miss |
| After | Note what worked · Note one thing to practice · Log the match |

```
┌────────────────────────────────────┐
│ ←  Match prep                      │
│ ────────────────────────────────── │
│ ( Before | During | After )        │
│                                    │
│ ☐ Water and balls                  │
│ ☐ Know the format                  │
│ ☐ Arrive with time to warm up      │
│ ☐ One cue for the first point      │
│                                    │
│ { Log the match }                  │
└────────────────────────────────────┘
```

### 20. Match log form

**Purpose.** Save a simple match log. Not live scoring.

**Key elements.** Date, default today. Format: singles or doubles. Result: win, loss, unfinished. Score text, free, example hint “6–4, 3–6”. Went well. To improve. Optional serve note, return note, mental note. These map to the match log fields.

**Primary action.** “Save match”.

**States.** Missing result: “Choose a result.” Success pops and toasts “Match saved”. The log list is a second state of this screen’s root, reached from Train’s “Match log”: newest first, tap to read, no edit in MVP beyond adding another. Empty list: “No matches logged yet.” Button “Log a match”.

```
┌────────────────────────────────────┐
│ ←  Log a match                     │
│ ────────────────────────────────── │
│ Date                     Today     │
│ Format           Singles  Doubles  │
│ Result     Win   Loss   Unfinished │
│                                    │
│ Score                              │
│ ┌────────────────────────────────┐ │
│ │ 6–4, 3–6                       │ │
│ └────────────────────────────────┘ │
│ Went well                          │
│ To improve                         │
│ Serve note                         │
│ Return note                        │
│ Mental note                        │
├────────────────────────────────────┤
│ [ Save match ]                     │
└────────────────────────────────────┘
```

### 21. Coach ask

**Purpose.** Ask the rules coach a question. The answer is coaching assistance: causes, one technique, and catalog drills.

**Key elements.** Prompt “What is going wrong?”. Multiline field. Examples as quiet chips that fill the field, they do not auto-send: “Forehand into the net”, “Toss is inconsistent”, “Can’t start a rally”. Answer uses `BaselineCoachAnswerCard`. Footer on the answer is always “Coaching help, not medical advice.”

**Primary action.** “Ask”.

**States.**

- Free player: do not show the field. Locked continuation, “Ask the pro is included with Premium”, button “See Premium”.
- Empty question: button disabled.
- Loading: button spinner, “Looking in the lesson catalog”.
- Pain: the pain variant of the answer card. No drills.
- Fallback: “A place to start”, last unfinished lesson, one consistency drill.
- Error: inline retry. The question text stays.

```
┌────────────────────────────────────┐
│ ←  Ask the pro                     │
│ ────────────────────────────────── │
│ What is going wrong?               │
│ ┌────────────────────────────────┐ │
│ │ I keep hitting my forehand     │ │
│ │ into the net.                  │ │
│ └────────────────────────────────┘ │
│ [ Forehand into the net ]          │
│                                    │
│ [ Ask ]                            │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ COACHING ASSISTANCE            │ │
│ │ Several common causes fit a    │ │
│ │ forehand into the net.         │ │
│ │                                │ │
│ │ LIKELY CAUSES                  │ │
│ │ Contact point too low          │ │
│ │ Swing path down through it     │ │
│ │                                │ │
│ │ Open · Contact point           │ │
│ │ Drill · Wall rally             │ │
│ │                                │ │
│ │ Coaching help, not medical     │ │
│ │ advice.                        │ │
│ └────────────────────────────────┘ │
└────────────────────────────────────┘
```

Opened from a technique page, the field is prefilled with “About {technique}: ” and the player finishes the sentence.

---

## Discover

Segmented control: Courts, Players, Coaches, Stores. The map exists for public places. Switching to Players removes the map.

### 22. Discover map/list

**Purpose.** Find a court, coach, or store near the player or in a typed city.

**Key elements.** Segmented control. City or “Near you”. Filter button. For Courts: map on top, list underneath, OSM attribution on the map’s top-left whenever any pin has source `osm`: “© OpenStreetMap”. Pins are courts only. Filters: indoor, lights, surface (Hard, Clay, Grass, Carpet — Clay is a swatch plus the word), access (Public, Private, Club). Radius 5, 10, 25, 50 km. List uses `BaselineCourtRow`.

Coaches segment: no requirement to be a map. A list of `BaselineCoachCard`. Filters: audience, format, price band if the API returns one. Optional map of coach locations only because they are public places. No player pins on that map.

Stores segment: list. Filter by service, including stringing. Link “Equipment guide”.

**Primary action.** Open the first useful row. The map pin and the row open the same detail.

**States.**

- Location not decided: a card above the map. “Baseline uses your location to show nearby courts, coaches, and stores. You can type a city instead.” Buttons “Use my location” and the city field. This is the only other place, besides onboarding, that asks.
- Permission denied: city field focused. Map shows the city result or the empty state.
- No courts: `courts` empty state. “Widen radius” selects the next radius.
- OSM attribution remains visible at the collapsed list detent. Do not cover it with the sheet.
- VoiceOver order: segments, city, filters, **list**, then one map node labeled “Court map, same places as the list.”

```
┌────────────────────────────────────┐
│ Discover                           │
│ ( Courts | Players | Coaches | Stores )
│ [ Near you          ] [ Filters ]  │
│ ┌────────────────────────────────┐ │
│ │ © OpenStreetMap                │ │
│ │            • pin               │ │
│ │                                │ │
│ ├────────────────────────────────┤ │
│ │ Riverside Park           1.2 km│ │
│ │ Hard · Lights · Outdoor    ☆   │ │
│ │ Club clay                2.4 km│ │
│ │ Clay · No lights · Outdoor ☆   │ │
│ └────────────────────────────────┘ │
├────────────────────────────────────┤
│ Home  Learn  Train  Discover  You  │
└────────────────────────────────────┘
```

Coaches and stores replace the map with a list when that is the clearer default. Courts always offer the map.

### 23. Court detail

**Purpose.** Decide whether to go, then get directions or save the court.

**Key elements.** Name. Surface, indoor or outdoor, lights, access, court count. Hours. Price text. Booking link only if `booking_url` is present, labeled “Booking site”. It opens the system browser. Baseline does not take payment. Address. Map snapshot. Directions. Favorite. Share: the system share sheet with the name and address.

**Primary action.** “Directions”. Opens the system maps app with the address.

**States.** Missing hours or price: omit the row. Missing booking URL: omit the button. Do not say “Call to book” unless a phone exists. Phone, if present, is a button “Call”. Load error: shared error. Favorite toasts “Saved”.

```
┌────────────────────────────────────┐
│ ←  Riverside Park              ☆   │
│ ────────────────────────────────── │
│ Hard · Outdoor · Lights            │
│ 4 courts · Public                  │
│                                    │
│ Hours        7:00–21:00            │
│ Price        Free                  │
│ Address      100 Park Rd           │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ map snapshot                   │ │
│ └────────────────────────────────┘ │
│                                    │
│ [ Directions ]                     │
│ ( Share )                          │
└────────────────────────────────────┘
```

### 24. Player cards

**Purpose.** Browse people who opted in, at a distance band, and start a request. This is the Players segment, full screen, no map.

**Key elements.** Segmented control still visible so the player can leave. `BaselinePlayerCard` list. Filters: level, format, setting (indoor, outdoor, either). Radius preference in a filter, stored as `search_radius_km`. Daily free cap called out in `meta` when the viewer is free: “{n} free profiles left today.” The count comes from the API. Design for a cap of five if the server has not sent a different number.

**Primary action.** “Request” on a card → Player request.

**States.**

- Not discoverable: `playersOff` empty state. “Turn on discovery” opens a confirm, not a silent toggle. Confirm copy: “Players will see your name, level, city, and a distance band such as within 5 km. They will not see your address or an exact location.” Primary “Turn on”. Secondary “Not now”. Turning on asks the system location only if a coarse cell is missing, or confirms the city they already typed. Save rounds to the coarse cell on the server.
- Under 18: `playersUnder18`. No switch.
- Cap reached: list shows the cards already returned, then `playersCap`.
- Nobody nearby: `playersNone`.
- Blocked people do not appear.
- Decline is silent. A declined request returns the card to “Request” with no “declined” copy and no notification.

```
┌────────────────────────────────────┐
│ Discover                           │
│ ( Courts | Players | Coaches | Stores )
│ [ Level ] [ Format ] [ Setting ]   │
│ 4 free profiles left today         │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ A  Alex Kim              L2    │ │
│ │ Singles · Queens               │ │
│ │ within 5 km                    │ │
│ │ Weeknights                     │ │
│ │ [ Request ]                    │ │
│ └────────────────────────────────┘ │
├────────────────────────────────────┤
│ Home  Learn  Train  Discover  You  │
└────────────────────────────────────┘
```

Card tap opens detail (still this flow, not a new tab): bio, goal, availability, age band only if allowed, Request, and More. More holds Block and Report.

```
┌────────────────────────────────────┐
│ ←  Alex Kim                        │
│ ────────────────────────────────── │
│ L2 Beginner · Singles              │
│ Queens · within 5 km               │
│ Weeknights · Mornings              │
│                                    │
│ Goal                               │
│ Play a first match                 │
│                                    │
│ [ Request ]                        │
│ { Block }            { Report }    │
└────────────────────────────────────┘
```

Block confirm: “Block Alex Kim? You will not see each other in search or messages.” Primary destructive “Block”. Report: reason chips Harassment, Spam, Safety, Something else, plus an optional note. Primary “Submit report”. Success toast: “Thanks, we received this.”

### 25. Player request

**Purpose.** Confirm before a request is sent. The connection model has no message body, so this screen does not collect one.

**Key elements.** Who will receive it. What they will see: name, level, format, city, distance band. What they will not see: address, exact location, email, birth year. Pending explanation: “If they accept, you can message. If they decline, you will not be notified.”

**Primary action.** “Send request”.

**States.** Sending. Success: pop back, card becomes “Request pending”, toast “Request sent”. `forbidden` because of age or discoverable off: return to the matching empty state. Cap: go to Paywall. Duplicate pending: “Request pending” without a second send.

```
┌────────────────────────────────────┐
│ ←  Ask to hit                      │
│ ────────────────────────────────── │
│                                    │
│ Send a request to Alex Kim?        │
│                                    │
│ They will see your name, level,    │
│ format, city, and a distance       │
│ band. Not your address.            │
│                                    │
│ If they decline, you will not      │
│ be notified.                       │
│                                    │
│ [ Send request ]                   │
│ { Cancel }                         │
└────────────────────────────────────┘
```

### 26. Coach detail

**Purpose.** Read a coach or academy listing and leave to contact them. No in-app payment.

**Key elements.** Photo or monogram. Name. Credentials. Years, if present. Audience, including Juniors when that is the listing. Format. Specialties. Price text. Summary. Academy name if linked. Intro video only when the video record is published and licensed, using the video sheet. Contact button if `contact_url` or phone exists.

**Primary action.** “Contact” when a URL or phone exists. Otherwise there is no primary; the screen is informational. Favorite is the star in the app bar.

**States.** Missing photo: monogram. Missing price: omit. Junior audience line, always when audience is junior or both: “This is a coach listing, not a Baseline account for a child.”

```
┌────────────────────────────────────┐
│ ←  Priya Shah                  ☆   │
│ ────────────────────────────────── │
│ [ photo ]                          │
│ USPTA · 12 years                   │
│ Adults · Private and group         │
│ Price · from the listing           │
│                                    │
│ Forehand, serve, match play        │
│                                    │
│ Intro video                        │
│ ┌────────────────────────────────┐ │
│ │ ▶                              │ │
│ └────────────────────────────────┘ │
│                                    │
│ [ Contact ]                        │
└────────────────────────────────────┘
```

### 27. Store detail

**Purpose.** Show a shop or stringer and how to reach them.

**Key elements.** Name. Services as chips: stringing, grips, shoes, repair, used. Address, hours, phone, website. Directions. Favorite. Link to the equipment guide.

**Primary action.** “Directions” if there is an address, otherwise “Call” or “Website”.

**States.** Omit empty contact rows. No reviews. No checkout.

```
┌────────────────────────────────────┐
│ ←  Line & String               ☆   │
│ ────────────────────────────────── │
│ [ Stringing ] [ Grips ] [ Repair ] │
│                                    │
│ Hours        Tue–Sat 10–18         │
│ Address      20 Main St            │
│                                    │
│ [ Directions ]                     │
│ { Equipment guide }                │
└────────────────────────────────────┘
```

### 28. Equipment guide

**Purpose.** Editorial recommendations by level, budget, and playing style. Sponsored rows are labeled and kept out of the Baseline pick list.

**Key elements.** Filters: level, budget band, category (racket, shoes, strings, balls). Section “Baseline pick” with product rows. Section “From our partners” only if a sponsored row matches the filters. Each sponsored row has the Sponsored mark above the name. Footer always: “Some links are affiliate links. A shop or coach should check grip size and shoes if you have pain. This guide is not medical advice.”

**Primary action.** Open a product.

**States.** No editorial match: “Nothing in this combination yet. Clear a filter.” Sponsored section hidden when empty. Never place a sponsored card inside Baseline pick.

```
┌────────────────────────────────────┐
│ ←  Equipment                       │
│ ────────────────────────────────── │
│ [ Level 1 ] [ Budget ] [ Racket ]  │
│                                    │
│ BASELINE PICK                      │
│ ● Starter racket                   │
│   Level 1–2 · Under $100           │
│                                    │
│ FROM OUR PARTNERS                  │
│ Sponsored                          │
│   Demo racket                      │
│                                    │
│ Some links are affiliate links.    │
│ A shop or coach should check grip  │
│ size and shoes if you have pain.   │
└────────────────────────────────────┘
```

### 29. Product detail

**Purpose.** One recommendation, with pros, considerations, and an outbound retailer link.

**Key elements.** Name. Baseline pick or Sponsored, never both. Level range, style, budget. Specs. Pros. Considerations. Price from `price_cents` if present, formatted in the product currency, otherwise omit. “Updated {date}”. Retailer name.

**Primary action.** “View at {retailer}” opens `retailer_url` in the browser. If there is no URL, there is no primary button.

**States.** Sponsored uses the outline mark and does not say Baseline pick. Pain or injury language must not appear in editorial copy. The guide footer from the list repeats at the bottom of sponsored and affiliate products.

```
┌────────────────────────────────────┐
│ ←  Starter racket                  │
│ ────────────────────────────────── │
│ ● Baseline pick                    │
│ Level 1–2 · Under $100             │
│                                    │
│ PROS                               │
│ Lighter swing weight               │
│                                    │
│ CONSIDERATIONS                     │
│ Move on when you outgrow it        │
│                                    │
│ [ View at the retailer ]           │
└────────────────────────────────────┘
```

---

## Account

### 30. Paywall

**Purpose.** The single purchase screen. Callers include locked lessons, locked drills, weekly plans, Ask the pro, history charts, and the player-card cap.

**Key elements.** `BaselinePaywall`. Headline names the interrupted task when there is one.

**Primary action.** The store subscribe button once a price is loaded.

**States.** Listed on the component: loading price, price failed, purchase failed, restore empty, already premium (do not present). “Not now” returns to the caller. The overview the player already read stays on the lesson underneath.

```
┌────────────────────────────────────┐
│                                    │
│ PREMIUM                            │
│ Keep going with                    │
│ the forehand                       │
│                                    │
│ ● All lessons and drills           │
│ ● Weekly plans                     │
│ ● Ask the pro                      │
│ ● Full progress history            │
│ ● Unlimited partner browsing       │
│                                    │
│ Baseline Premium                   │
│ Price from the App Store           │
│                                    │
│ [ Continue ]                       │
│ ( Restore purchases )              │
│ { Not now }                        │
│                                    │
│ Renews until you cancel in         │
│ the App Store.                     │
│ { Terms }          { Privacy }     │
└────────────────────────────────────┘
```

Do not put a dollar amount in the layout as a placeholder that could ship. If the product has not loaded, the price line reads “Loading price”.

### 31. Inbox

**Purpose.** Pending requests and accepted conversations. Reached from the Profile badge, Profile, and after a request is sent. Not a tab.

**Key elements.** Two sections. Requests: name, level, Accept and Decline. Conversations: name, last message preview, unread ball if the last message is incoming and unseen.

**Primary action.** Accept on the top request, if any. Otherwise open the top conversation.

**States.** Empty: `inbox`. Decline is a text button. After decline, the row disappears and the other person is not told. Accept opens the thread. Blocked conversations are gone.

```
┌────────────────────────────────────┐
│ ←  Inbox                           │
│ ────────────────────────────────── │
│ REQUESTS                           │
│ Alex Kim · L2 · within 5 km        │
│ [ Accept ]          { Decline }    │
│                                    │
│ CONVERSATIONS                      │
│ ● Sam Ortiz                        │
│   Saturday morning works           │
└────────────────────────────────────┘
```

### 32. Thread

**Purpose.** Plain-text messages after an accepted request.

**Key elements.** Title is the other person’s name. Message list, oldest at top. Incoming bubbles `card` with hairline. Outgoing bubbles `nightCourt` with `line` text. Composer: one text field, send button 44pt, label “Send”. More menu: Block, Report.

**Primary action.** Send.

**States.** Empty thread: “Say where and when you want to hit.” Send disabled while the field is empty. Send failure: the message stays in the composer and an inline note appears. No images, no link previews. Rate limit uses the shared copy. Report success: “Thanks, we received this.” Block closes the thread and returns to Inbox.

```
┌────────────────────────────────────┐
│ ←  Sam Ortiz                   ··· │
│ ────────────────────────────────── │
│                                    │
│ ┌────────────────────┐             │
│ │ Saturday morning?  │             │
│ └────────────────────┘             │
│             ┌────────────────────┐ │
│             │ Yes. Riverside.    │ │
│             └────────────────────┘ │
│                                    │
│ ┌─────────────────────────┐ [Send] │
│ │ Message                 │        │
│ └─────────────────────────┘        │
└────────────────────────────────────┘
```

### 33. Profile

**Purpose.** The player’s level, goal, stats, badges, and the doors to settings.

**Key elements.** Display name or “Add your name”. Current level chip. Active goal. Stats that are free: lessons complete, drills logged, minutes, streak. A 14-day minutes strip. Full history is a locked row if the viewer is free (`chart` empty state in miniature, “See Premium”). Badges earned, and locked badges by name without a puzzle. Rows: Edit profile, Notifications, Privacy, Subscription, Equipment guide, Inbox, Saved places. Sign out. Terms and Privacy.

**Primary action.** None. The screen is a menu. The first row, Edit profile, is the top action.

**States.** No badges yet: “Badges show up as you finish lessons and weeks.” Saved places empty state lives on the saved-places screen pushed from this row: courts, coaches, stores the player starred, or `favorites`. Sign out confirms: “Sign out of Baseline?” Primary “Sign out”.

```
┌────────────────────────────────────┐
│ Profile                            │
│ ────────────────────────────────── │
│ Add your name                      │
│ L1 · Complete Beginner             │
│ Goal · Learn from scratch          │
│                                    │
│ ( 2 )  2 lessons · 1 drill         │
│ of 12  40 min · 4 day streak       │
│ Last 14 days  ▁▃▂▅                 │
│ { Full history }                   │
│                                    │
│ BADGES                             │
│ First lesson                       │
│                                    │
│ Edit profile                       │
│ Notifications                      │
│ Privacy                            │
│ Subscription                       │
│ Equipment guide                    │
│ Inbox                              │
│ Saved places                       │
│                                    │
│ { Sign out }                       │
│ { Terms }          { Privacy }     │
├────────────────────────────────────┤
│ Home  Learn  Train  Discover  You  │
└────────────────────────────────────┘
```

### 34. Edit profile

**Purpose.** Change the tennis profile. Levels are guidelines. Discovery switches are not on this screen.

**Key elements.** Display name. Level picker, five choice cards, current one selected, sentence “Levels are guidelines. You can change this later.” Played before. How often. Primary goal. Format. Days per week. Focus skills, multi-select. Indoor, outdoor, or either. Bio. Home city. Availability grid if they already opted into partners; otherwise a note “Availability is used if you turn on discovery in Privacy.”

**Primary action.** “Save”.

**States.** Save disabled until a change exists. Success pops and toasts “Profile saved”. City change does not move the coarse cell until they confirm discovery again. Validation errors sit on the fields.

```
┌────────────────────────────────────┐
│ ←  Edit profile                    │
│ ────────────────────────────────── │
│ Name                               │
│ ┌────────────────────────────────┐ │
│ │                                │ │
│ └────────────────────────────────┘ │
│                                    │
│ Level                              │
│ Levels are guidelines. You can     │
│ change this later.                 │
│ ( 1 Complete Beginner        ✓ )   │
│ ( 2 Beginner                 )     │
│ ( 3 Advanced Beginner        )     │
│ ( 4 Intermediate             )     │
│ ( 5 Advanced                 )     │
│                                    │
│ Goal, format, days, skills,        │
│ indoor or outdoor, bio, city       │
├────────────────────────────────────┤
│ [ Save ]                           │
└────────────────────────────────────┘
```

### 35. Notifications

**Purpose.** One switch per class in the data model. In-app inbox badges do not depend on these pushes.

**Key elements.** Switch rows. If the OS has denied alerts, a `pushOff` note at the top.

**Primary action.** None. Each switch saves on change.

**States.** Save failure reverts the switch and shows an inline error. Defaults: practice reminders on, partner requests on, and the other five off.

| Switch | Description | Default |
|---|---|---|
| Practice reminders | A nudge on days you planned to train. | On |
| Plan reminders | When this week’s plan is ready. | Off |
| Lesson tips | A short cue from the lesson you just did. | Off |
| Weekly progress | A Sunday summary of minutes and lessons. | Off |
| Partner requests | When someone asks to hit. | On |
| Messages | When an accepted partner writes. | Off |
| Milestones | Streaks and badges. | Off |

There is no marketing switch.

```
┌────────────────────────────────────┐
│ ←  Notifications                   │
│ ────────────────────────────────── │
│ Practice reminders            [on] │
│ A nudge on days you planned        │
│ to train.                          │
│                                    │
│ Plan reminders               [off] │
│ Partner requests              [on] │
│ Lesson tips                  [off] │
│ Weekly progress              [off] │
│ Messages                     [off] │
│ Milestones                   [off] │
└────────────────────────────────────┘
```

### 36. Privacy

**Purpose.** Control discovery, export data, and delete the account.

**Key elements.**

- Discoverable switch. Off by default. Under 18: the switch is absent, replaced by “Partner finding starts at 18.”
- When turning on: the same coarse-area confirm as Player cards. “Players see a distance like within 5 km, never your address.”
- Show age band, switch, default off. Description: “Shows a range such as 25–34 on your card. Never your birth year.”
- Search radius, chips 5, 10, 25, 50 km.
- Export: “Download my data”.
- Delete: opens the confirm frame.
- Privacy policy link.

**Primary action.** None on the main list. On the delete confirm, the destructive primary is “Delete account”, enabled only when the field equals `DELETE`.

**States.** Discoverable rejected by the server for age: show the under-18 line and force the switch off. Export success opens the system share sheet with the JSON. Export failure: inline retry. Delete success returns to Welcome. Copy on the confirm: “This removes your profile, messages you sent, saved places, and discovery area. It cannot be undone, and the account cannot be reactivated.”

```
┌────────────────────────────────────┐
│ ←  Privacy                         │
│ ────────────────────────────────── │
│ Discoverable                 [off] │
│ People can see a card with a       │
│ distance band, not your address.   │
│                                    │
│ Show age band                [off] │
│ A range such as 25–34. Never       │
│ your birth year.                   │
│                                    │
│ Search radius                      │
│ [ 5 km ] [ 10 ] [ 25 ] [ 50 ]      │
│                                    │
│ [ Download my data ]               │
│ { Delete account }                 │
│ { Privacy policy }                 │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│ ←  Delete account                  │
│ ────────────────────────────────── │
│ This removes your profile,         │
│ messages you sent, saved places,   │
│ and discovery area. It cannot      │
│ be undone.                         │
│                                    │
│ Type DELETE                        │
│ ┌────────────────────────────────┐ │
│ │                                │ │
│ └────────────────────────────────┘ │
│                                    │
│ [ Delete account ]                 │
│ { Cancel }                         │
└────────────────────────────────────┘
```

The delete button uses the destructive variant and stays disabled until the field is exactly `DELETE`.

### 37. Subscription

**Purpose.** Show the current entitlement and how to manage it.

**Key elements.** Plan name: Free or Premium. If Premium and `expires_at` is present, “Renews {date}” or “Ends {date}” from the store status. What Premium includes, the same five benefits as the paywall, as a checklist. Free players see those rows unchecked.

**Primary action.** Free: “See Premium” → Paywall. Premium: “Manage in the App Store”. Both states offer “Restore purchases”.

**States.** Restore in flight. Restore found a purchase: the plan row updates to Premium. Restore found nothing: inline note. Loading entitlement: the word “Checking your plan” and no price.

```
┌────────────────────────────────────┐
│ ←  Subscription                    │
│ ────────────────────────────────── │
│ Free                               │
│                                    │
│ ☐ All lessons and drills           │
│ ☐ Weekly plans                     │
│ ☐ Ask the pro                      │
│ ☐ Full progress history            │
│ ☐ Unlimited partner browsing       │
│                                    │
│ [ See Premium ]                    │
│ ( Restore purchases )              │
└────────────────────────────────────┘
```

### 38. Search results

**Purpose.** One query, grouped hits, from Home or Learn.

**Key elements.** The search field, prefilled, with clear. Groups in order, omitting empty groups: Lessons, Techniques, Drills, Glossary, Courts, Coaches, Stores, Players. Player hits only when the viewer is 18+ and discoverable is on, and they use the same card rules (distance band, no pin). Each group shows at most five rows and “More” if the API says there are more.

**Primary action.** Open the top hit.

**States.** Empty: `search`. Loading: section tracks. `rate_limited`: the shared minute copy. Premium lessons appear in results with the Premium meta and open into the locked reader. Under-18 queries do not show a Players group and do not explain the absence on this screen.

```
┌────────────────────────────────────┐
│ ←  ( forehand              ✕ )     │
│ ────────────────────────────────── │
│ LESSONS                            │
│ Forehand                     L1    │
│                                    │
│ DRILLS                             │
│ Wall rally                   L1    │
│                                    │
│ GLOSSARY                           │
│ Follow through                     │
└────────────────────────────────────┘
```

---

## Admin

Web CMS, 1280-wide layout. Same color tokens. Left nav 240px, night court. An editor can save drafts. An admin can publish, unpublish, and suspend. The signed-in role is in the nav footer.

Nav: Lessons, Techniques, Drills, Videos, Courts, Coaches, Stores, Equipment, Reports.

### 39. Admin login

**Purpose.** Sign an editor or admin in. No Sign in with Apple requirement on the web. Use the same email code as the API.

**Key elements.** Wordmark. Email. Code step. Role failure.

**Primary action.** “Email me a code”, then “Sign in”.

**States.** Code error matches the mobile copy. If the account has no `admin_users` row: “This account is not an editor.” Sign out. Do not show the nav.

```
┌─────────────────────────────────────────────┐
│                                             │
│ BASELINE                                    │
│ Editor sign in                              │
│                                             │
│ Email                                       │
│ ┌─────────────────────────────────────────┐ │
│ │                                         │ │
│ └─────────────────────────────────────────┘ │
│ [ Email me a code ]                         │
│                                             │
└─────────────────────────────────────────────┘
```

### 40. Content list

**Purpose.** Find a lesson, technique, drill, or video and open its editor. Places and reports use this same shell with their own columns.

**Key elements.** Nav. Title of the section. Status filter: Draft, Published, All. Search. Table. Primary “New”.

**Columns.**

| Section | Columns |
|---|---|
| Lessons | Title, level, category, free or Premium, status, updated |
| Techniques | Name, family, level min, status |
| Drills | Name, level min, free or Premium, status |
| Videos | Title, license, creator, status |

**Primary action.** “New”, or open a row.

**States.** Empty section: “Nothing in {section} yet.” Button “New”. A video in draft with incomplete license shows status “Draft · license missing” in ink with a clay dot, not color alone.

```
┌──────────┬──────────────────────────────────┐
│ BASELINE │ Lessons                    [New] │
│          │ [ Draft | Published | All ]      │
│ Lessons  │                                  │
│ Techniq. │ Title            Lvl  Status     │
│ Drills   │ Ready position    1   Published  │
│ Videos   │ Forehand          1   Draft      │
│ Courts   │                                  │
│ Coaches  │                                  │
│ Stores   │                                  │
│ Equip.   │                                  │
│ Reports  │                                  │
│          │                                  │
│ Editor   │                                  │
└──────────┴──────────────────────────────────┘
```

### 41. Content editor

**Purpose.** Edit one lesson. The same shell edits a technique or a drill with the field swap at the end of this section. This is the lesson editor the licensing doc describes.

**Key elements.**

- Title. Summary. Level. Category: rules, technique, strategy, fitness, etiquette, mental. Technique, or none for a general or rules lesson. Estimated minutes. Difficulty 1–5. Prerequisite. Next lesson. Free-tier switch (on means free).
- Blocks, ordered, each with a kind picker: overview, why, steps, tips, mistakes, beginner mistakes, checklist, text. Body is headings and paragraphs, not raw HTML. Move up, move down, delete.
- Images, with required alt text.
- Videos: a picker of videos whose license is complete. A video that fails the license check cannot be added. Copy on the picker: “A video block with a missing license is dropped, not shipped.”
- Tips and mistakes also remain available as block kinds.
- Linked drills. Equipment list.
- Checklist of publish requirements, visible, not a tooltip.
- Save draft for everyone. Publish and Unpublish for admins only. Editors see “An admin publishes this lesson.”
- Read-only phone preview of the lesson reader, video-first, so an editor can see the text fallback when no video is attached.

**Primary action.** Admin: “Publish” when the checklist is clear, otherwise “Save draft”. Editor: “Save draft”.

**States.** Missing required fields: those inputs get the clay border and the checklist lists them in ink. Publish stays disabled. A lesson may publish with text and zero videos. Unpublish confirms: “This leaves the mobile app. The draft stays.”

```
┌──────────┬──────────────────────────────────┐
│ Lessons  │ ← Ready position                 │
│ …        │                                  │
│          │ Title        [ Ready position  ] │
│          │ Summary      [ …               ] │
│          │ Level        [ 1 ]               │
│          │ Category     [ technique ]       │
│          │ Technique    [ ready-position ]  │
│          │ Minutes      [ 8 ]               │
│          │ Difficulty   [ 1 ]               │
│          │ Free tier    [ on ]              │
│          │ Prerequisite [ none ]            │
│          │ Next         [ grips ]           │
│          │                                  │
│          │ BLOCKS                           │
│          │ 1 overview        [ up down ]    │
│          │ 2 steps           [ up down ]    │
│          │ [ Add block ]                    │
│          │                                  │
│          │ VIDEOS                           │
│          │ Ready position · license ready   │
│          │ [ Attach video ]                 │
│          │                                  │
│          │ DRILLS   EQUIPMENT   IMAGES      │
│          │                                  │
│          │ Checklist                        │
│          │ ✓ Title  ✓ Level  ✓ Blocks       │
│          │                                  │
│          │ ( Preview )  [ Save draft ]      │
│          │              [ Publish ]         │
│          │                                  │
│          │ ┌──────── preview ────────────┐  │
│          │ │ video or text-first reader  │  │
│          │ └─────────────────────────────┘  │
└──────────┴──────────────────────────────────┘
```

Technique editor swaps in: slug, name, family, difficulty, reps, overview, why it matters, level min, related techniques, status. Drill editor swaps in: objective, equipment, court setup, players, instructions, duration, repetitions, difficulty, tips, misses, free tier, videos. Both keep Save draft / Publish and the preview.

### 42. Video license panel

**Purpose.** A video cannot be published until the license record is complete. This panel is the video editor, opened from Videos or from “Attach video” on a lesson.

**Key elements.** Required fields, each labeled Required: title, source, creator, license, attribution, URL, category, level, technique or “general”, duration. License is one of: original, licensed, public domain, Creative Commons, provider embed.

Conditional fields:

- Licensed: contract URL, required.
- Creative Commons: the exact license, such as CC BY, required. A required checkbox: “I checked that this license allows an app to show the video. I checked share-alike and non-commercial terms.” If the editor cannot check it, Publish stays disabled. Helper text: “No share-alike and non-commercial limits unless they were reviewed.”
- Provider embed: watch URL, required. Helper: “YouTube or Vimeo embed only. Baseline does not download the file.”
- Original or licensed: playback may be “File we own” or “Embed”. Any other license hides the file upload.
- A pasted third-party raw file URL (a direct mp4 or similar from another host) shows: “Baseline doesn’t host other people’s files. Use an embed or a video we own.” The field does not save that URL.

Publish checklist at the top, every missing item in text. Status draft or published. Reviewed-at is read-only once an admin publishes.

**Primary action.** “Publish” for an admin when the checklist is complete. “Save draft” always, including when the checklist is incomplete.

**States.** Publish disabled with the list visible. Editor role: no Publish button. Owned-file selected with a CC license: inline error and the control snaps back to embed. Unpublish returns the video to draft and drops it from lesson playback.

```
┌──────────┬──────────────────────────────────┐
│ Videos   │ ← New video                      │
│          │                                  │
│          │ Cannot publish yet               │
│          │ · Creator                        │
│          │ · Attribution                    │
│          │                                  │
│          │ Title       [          ] Required│
│          │ Source      [          ] Required│
│          │ Creator     [          ] Required│
│          │ License     [ provider embed ▾ ] │
│          │ Attribution [          ] Required│
│          │ Watch URL   [          ] Required│
│          │ Category    [ technique ▾ ]      │
│          │ Level       [ 1 ▾ ]              │
│          │ Technique   [ general ▾ ]        │
│          │ Duration    [ 1:12 ] Required    │
│          │                                  │
│          │ Playback                         │
│          │ ( Embed URL )  ( File we own )   │
│          │ File we own is available for     │
│          │ original and licensed only.      │
│          │                                  │
│          │ [ Save draft ]                   │
│          │ [ Publish ]                      │
└──────────┴──────────────────────────────────┘
```

Creative Commons adds the license string and the confirmation checkbox under License. The checkbox label is fully visible, not icon-only.

### 43. Place editor

**Purpose.** Create or edit a court, coach, academy, or store. One form, type-specific fields. Booking is a link, not a payment.

**Key elements.** Type: Court, Coach, Academy, Store. Shared: name, address, map pin (public place), phone, website, hours, status (draft or published), source (admin or OSM).

| Type | Extra fields |
|---|---|
| Court | Court count, indoor, access, lights, surface, price text, booking URL, OSM id |
| Coach | Academy, credentials, years, specialties, audience, format, price text, contact URL, photo, intro video id |
| Academy | Kind: academy, club, school, center. Summary |
| Store | Services: stringing, grips, shoes, repair, used |

If source is OSM, show a locked attribution line “© OpenStreetMap” and do not imply the record was scraped from a review site. Booking URL helper: “This opens in the browser. Baseline does not take payment.”

**Primary action.** “Save”. Admin may also publish the place. There is no review importer.

**States.** Missing name or missing point: save disabled, fields listed. Invalid booking URL: field error. Coach audience includes Junior. Helper: “A junior program is a listing. It does not create an account for a child.”

```
┌──────────┬──────────────────────────────────┐
│ Courts   │ ← Riverside Park                 │
│          │ Type [ Court ▾ ]                 │
│          │ Name [ Riverside Park ]          │
│          │ Address [ 100 Park Rd ]          │
│          │ ┌──────── map pin ─────────────┐ │
│          │ │ •                            │ │
│          │ └──────────────────────────────┘ │
│          │ Indoor [ ]  Lights [x]           │
│          │ Surface [ Hard ▾ ]               │
│          │ Access [ Public ▾ ]              │
│          │ Courts [ 4 ]                     │
│          │ Price text [ Free ]              │
│          │ Booking URL [ ]                  │
│          │ Opens in the browser. Baseline   │
│          │ does not take payment.           │
│          │ Source  Admin                    │
│          │ [ Save ]                         │
└──────────┴──────────────────────────────────┘
```

### 44. Report queue

**Purpose.** Read player and content reports. Admins suspend. Editors can close a report with a note. Every decision can be audited.

**Key elements.** Filter: Open, Closed. Table: when, reporter, target type, reason, status. Detail pane: reason, note, target id, message snapshot id if the API sent one, the reported text when the backend includes it. Actions: Close, and for admins Suspend account. A note field for the decision.

**Primary action.** “Close report” on the open detail. Suspend is destructive and secondary in emphasis: it is a destructive button, not the default.

**States.** Empty: `reports`. Suspend confirms: “Suspend this account? They cannot sign in.” Closing toasts nothing flashy; the row moves to Closed. The reporter’s app already said “Thanks, we received this.” Do not email them from this screen in MVP.

```
┌──────────┬──────────────────────────────────┐
│ Reports  │ Open                             │
│          │                                  │
│          │ When     Target    Reason        │
│          │ Today    Player    Harassment    │
│          │                                  │
│          │ ┌──────── detail ──────────────┐ │
│          │ │ Harassment                   │ │
│          │ │ Note from reporter           │ │
│          │ │ Snapshot id                  │ │
│          │ │ Decision note [            ] │ │
│          │ │ [ Close report ]             │ │
│          │ │ [ Suspend account ]          │ │
│          │ └──────────────────────────────┘ │
└──────────┴──────────────────────────────────┘
```

Suspend is hidden for the editor role. The nav does not include a community moderation view, a booking desk, or a video-analysis queue.
