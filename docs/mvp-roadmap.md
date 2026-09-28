# MVP plan and roadmap

## Version 1 build order

Work in this order so each slice is demonstrable.

1. **Foundation.** Repo, API health, database migration, Flutter shell with five tabs, admin sign-in stub.
2. **Identity.** Apple, Google, email code, age gate, session refresh, delete account.
3. **Onboarding and profile.** Questions, level, first plan preview.
4. **Learning.** Seed levels 1–3, lesson reader, technique pages, glossary, rules. Progress checkmarks.
5. **Drills and plans.** Library, week plan, log minutes, streak.
6. **Discover places.** Courts map and list, coaches, stores. Favorites and directions.
7. **Partners.** Coarse search, request, thread, block, report. 18+ only.
8. **Equipment guide and paywall.** Entitlement check around premium lessons, plans, and coach ask.
9. **Rules coach.** Symptom catalog wired to real drill slugs.
10. **Notifications.** Local practice reminder plus push for partner requests.
11. **Admin.** Publish lessons and videos with the license gate. Moderate reports.
12. **Release.** TestFlight, privacy labels, age rating, screenshots.

## Content bar for TestFlight

- At least 12 original Level 1 lessons covering the complete-beginner topic list
- At least 10 Level 2 lessons and 8 Level 3 lessons
- At least 15 drills, including wall rally, cross-court rally, forehand and backhand consistency, serve targets, split step, and a figure-8 footwork pattern
- Glossary of the terms in the product brief
- Court seed for one launch city, plus the OSM import path documented
- Coach rules for the common “into the net / into the fence / can’t toss” questions

Videos can be zero at TestFlight if every lesson stands on text and diagrams. Do not ship placeholder copyrighted clips.

## Later roadmap

**1.1** Match prep checklists polished, weekly progress notification, more Level 4 lessons.

**1.2** Community: local groups and milestone posts, still moderated. Coach intro videos.

**1.3** Saved searches and calendar availability that is easier to edit.

**2.0** Android release from the same Flutter app. Play Billing mapped to the same entitlement.

**Next product bets, each behind an existing interface**

- Court booking and coach booking
- Video upload analysis
- Live score and a Baseline rating (external ratings only with a written license)
- Watch workout and Apple Health minutes
- Tournaments and ladders

## Out of scope until a partner exists

Taking payment for a coach, guaranteeing court availability, or claiming an official UTR integration.
