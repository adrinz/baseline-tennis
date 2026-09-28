# Navigation and user flows

## Bottom navigation

Five tabs. Labels stay short.

| Tab | Contains |
|---|---|
| Home | Greeting, continue, today’s plan, recommended drill, progress, discover shortcuts |
| Learn | Levels, current lesson, techniques, videos, rules, glossary |
| Train | This week’s plan, drill library, log a session, match prep, match log |
| Discover | Courts, players, coaches, stores. Segmented control at the top |
| Profile | Level, goals, stats, badges, notifications, privacy, subscription, sign out |

Global search is a field on Home and on Learn. It opens one results screen grouped by type.

## First-run flow

1. Welcome. One sentence and a primary button, “Get started.” Sign in with Apple is on this screen because App Store rules require it if Google is offered.
2. Sign in (Apple, Google, or email code).
3. Birth year. Under 16 cannot continue. Ages 16–17 continue without partner discovery.
4. Onboarding questions, one per screen, with a progress bar.
5. Location: “Find courts near you” explains why, then system permission, plus “Enter a city instead.”
6. Plan preview: “Your first week” with three or four sessions. Edit days or accept.
7. Land on Home with Level 1, lesson 1 highlighted.

## Learn a technique

Learn → level → lesson → read blocks → optional video → checklist → mark complete → next lesson or related drill.

If the lesson is Premium, the reader sees the overview and a locked continuation with what they will get. Purchase happens on a single paywall screen.

## Train today

Home “Today’s training” → ordered blocks with minutes → start block → timer optional → mark done → streak updates.

Drill library is the other door: filter by level and stroke, open drill, read setup, log completion.

## Find a court

Discover → Courts → map with list underneath → filters → court page (surface, lights, hours, price text, booking link if present) → directions or save.

Empty state: “No courts in this radius yet” and a wider radius. OSM attribution sits on the map.

## Find a partner

Discover → Players. If not discoverable, an explanation and a switch. Turning it on asks them to confirm a coarse area, not a pin on their home.

Card → request → the other player accepts → conversation. Decline is silent. Block hides both directions. Report goes to the admin queue and confirms to the reporter.

## Virtual Tennis Pro

From Home or a technique page, “Ask the pro.” Text question. Answer shows causes, a technique link, and drills. Footer: “Coaching help, not medical advice.”

## Profile and safety

Profile → Privacy: discoverable, age band, search radius, delete account (confirm with a typed DELETE), export data.

Notifications: one switch per class from the data model.

## Admin (web)

Sign in as an editor. Left nav: Lessons, Techniques, Drills, Videos, Courts, Coaches, Stores, Equipment, Reports. A video cannot move to Published until license, creator, source, and attribution are filled. The form shows those fields as required.

## Screen list (MVP)

**Mobile**

- Welcome, sign in, email code, age gate
- Onboarding (questions + plan preview)
- Home
- Level list, lesson list, lesson reader, technique page, video player sheet
- Rules index, glossary
- Week plan, drill list, drill detail, session logger
- Match prep, match log form
- Coach ask
- Discover map/list, court detail, player cards, coach detail, store detail
- Equipment guide, product detail
- Paywall
- Inbox, thread
- Profile, edit profile, notifications, privacy, subscription
- Search results

**Admin**

- Login, content list, content editor, video license panel, place editor, report queue

Wireframes live in `docs/design/` and follow this list. Visual design uses the system in that folder. Do not add a sixth tab for community or video analysis in version 1.
