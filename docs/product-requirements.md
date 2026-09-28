# Product requirements

## Promise

Help anyone learn tennis step by step, find a place to practice, find someone to play with, and see themselves improve.

The app should feel like a virtual tennis pro, a training assistant, and a local tennis directory. Community posting, live booking, and swing-video analysis wait until the core loop is solid.

## Audience

- **Primary:** complete beginners and advanced beginners.
- **Secondary:** intermediate and advanced players using drills, match prep, court finding, and partners.
- **Not the first customer:** tournament directors, stringers running a shop, or children under 16.

Accounts require age 16 or older. Player discovery and messaging require age 18 or older. Junior programs can appear as coach listings. Those listings do not create a child account.

## Levels

Players pick a level during onboarding and can change it in Profile. The copy on that screen says levels are guidelines.

Content topics follow the five-level outline in the product brief (complete beginner through advanced). Levels 1–3 ship as complete courses in the MVP. Levels 4–5 ship as a visible path with fewer published lessons so advanced players are not turned away.

## MVP features

1. Register and sign in with Apple, Google, or email.
2. Onboarding that sets level, goal, weekly days, singles or doubles, and location choice.
3. Learning path for levels 1–3, with levels 4–5 visible.
4. Technique library. Each technique has overview, why it matters, steps, tips, mistakes, drills, a checklist, difficulty, and related techniques.
5. Video records with license metadata. Playback only for original, licensed, public-domain, or permitted embed sources.
6. Drill library with the fields in the product brief.
7. A weekly plan for 2, 3, 4, or 5+ days.
8. Progress: level, lessons, drills, minutes, streak, and a simple match log.
9. Nearby courts with filters, favorites, directions, and share.
10. Nearby players using coarse location, requests, in-app messages, block, and report.
11. Coach and academy directory.
12. Stores and stringing services.
13. Equipment guide by level, budget, and playing style. Sponsored rows are labeled.
14. Profile, notification controls, privacy, delete account.
15. Admin CMS for content, places, products, and reports.

## Explicitly after MVP

Virtual Tennis Pro can ship in the first release as the rules engine if the catalog is ready. These stay behind interfaces and are not required to submit version 1.0:

- Community feed, challenges, and groups
- Court or coach booking and payments to coaches
- AI swing-video analysis
- Live scoring, UTR or other rating imports, leagues
- Apple Watch and Apple Health
- Marketplace checkout

Match preparation checklists (before, during, after) are small and included in Train for version 1.0 if schedule allows, otherwise the first update. The data model includes `match_logs` either way.

## Free and Premium

**Free**

- Level 1 lessons and a sample of level 2
- A limited drill set and the videos attached to free lessons
- Court search
- A limited player browse (for example 5 profiles a day) and sending a request
- Basic progress (streak and lessons completed)

**Premium**

- All published lessons and drills
- Generated weekly plans
- Virtual Tennis Pro
- Full progress history and charts
- Unlimited partner browsing

Prices are a store decision at launch. The app reads entitlements. It does not hard-code a price.

## Home screen

Time-of-day greeting, then:

- Continue learning
- Today’s training
- One recommended drill
- Progress snapshot
- Shortcuts: court, player, coach, store
- One recommended video
- Active goal

The order favors the next unfinished action. A new player sees “Start level 1.” A player with a plan due today sees the plan first.

## Onboarding questions

1. Have you played before?
2. Skill level (1–5, with plain-language labels)
3. How often do you play now?
4. Primary goal
5. Singles, doubles, or both
6. Days per week you can train
7. Skills to improve (multi-select)
8. Location permission, or a city typed by hand
9. Indoor or outdoor preference
10. Optional availability, shown only if they opt into finding partners

Finishing onboarding creates the profile, the starting level, one goal, and the first week plan.

## Quality bar

- A new player reaches the first lesson in under two minutes.
- Every technique screen is readable without a video, in case the video is missing or blocked.
- Discover never shows another player’s exact location.
- A third-party video cannot be saved unless license fields are complete.
- VoiceOver can complete onboarding, open a lesson, and log a drill.

## Success for version 1

A beginner in a city with seeded courts can create an account, finish the ready-position lesson, log a 20-minute wall drill, save a court, and send a partner request without contacting support.
