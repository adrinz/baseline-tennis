# Baseline manual script

Version 1 success path and the privacy cases. Run Part A on a small phone and again on a current phone. Run Part B on the current phone. Use the TestFlight build pointed at staging.

The pass condition for Part A is the version-1 success statement: a beginner in the seeded launch city creates an account, finishes the Ready position lesson, logs a 20-minute wall drill, saves a court, and sends a partner request without contacting support.

Case ids point at `docs/qa/cases.md`.

## Setup

| Role | Birth year to enter | Discoverable at start | Entitlement | Device |
|---|---|---|---|---|
| Beginner | 2000 | Off | Free | The phone under test |
| Partner | 2000 | On, coarse cell in the seeded launch city | Free | A second phone or a seeded staging user |
| Teen | 2010 | Off | Free | Current phone, Part B only |
| Child attempt | 2012 | — | — | Current phone, Part B only |

Birth year is the age gate. In 2026 those years are 26, 16, and 14. Partner is already an adult with discovery on, in the same launch city as the court seed, and is not blocked.

Install the build, confirm it reaches the staging API, and start from a signed-out Welcome screen. Leave VoiceOver off for this script. The accessibility pass is separate.

Record the build number, the phone model, and pass or fail for each part.

## Part A — Success path

Do this once per phone. Use a fresh Beginner identity on each phone, or delete the first Beginner only after Part B if both phones can share one staging account. Prefer a fresh account per phone so delete in Part B has a single owner.

### 1. Account

1. Open Baseline. Welcome shows one sentence, the button “Get started,” and Sign in with Apple.
2. Tap “Get started.”
3. Sign in with Apple as Beginner. If the Apple sandbox is unavailable, sign in with the email one-time code and write that down. Google is allowed only when Sign in with Apple is on the same screen.

Expected: a session starts. The next screen is birth year. No password is requested for email. (BL-002, BL-004)

### 2. Age

4. Enter birth year 2000 and continue.

Expected: the account is kept. Onboarding starts. Partner discovery is still off until the later switch. (BL-007 is the under-18 rejection, not this step.)

### 3. Onboarding

One question per screen. A progress bar is visible. Answer:

5. Have you played before? No.
6. Skill level: 1, Complete Beginner. The screen calls levels guidelines.
7. How often do you play now? Not currently playing.
8. Primary goal: learn from scratch.
9. Singles, doubles, or both: Singles.
10. Days per week you can train: 3.
11. Skills to improve: Forehand.
12. Location: choose “Enter a city instead.” Type the seeded launch city. Skip the system location prompt on this run so the court result does not depend on GPS.
13. Indoor or outdoor: Outdoor.
14. Finding partners: opt in. Availability appears. Pick one evening block.
15. Plan preview title is “Your first week.” It lists three or four sessions. Accept the plan. Note the option to edit days; leave the days at 3.

Expected: Home opens. The greeting uses the time of day. Level 1 is the starting level. Lesson 1 is highlighted and the new-player line is “Start level 1.” The week plan exists. (BL-008, BL-045)

Start a timer at step 2 (“Get started”) if you have not already. Stop it when the first lesson’s text is on screen in the next section. The elapsed time is under two minutes. (BL-009)

### 4. First lesson

16. From Home, open the highlighted Level 1 lesson and confirm the text is on screen, then go to Learn → Level 1 → Ready position (`ready-position`).
17. Read the blocks that are published (why it matters, steps, mistakes). If no video is attached, keep reading. The lesson does not stop on an empty player.
18. Complete the checklist when the lesson shows one. Mark the lesson complete.

Expected: Ready position is completed. The app offers the next lesson or a related drill. Progress counts the lesson. (BL-010, BL-011)

### 5. Log a drill

19. Open Train → drill library. Filter to a level 1 beginner drill if a filter is showing.
20. Open Wall rally (`wall-rally`). Read the setup, including the distance from the wall and the reset after two misses.
21. Log a completion of 20 minutes.

Expected: the completion is saved with 20 minutes. Train or Home progress includes those minutes. The drill’s catalog duration can stay 10 minutes; the logged session is 20. (BL-012)

### 6. Save a court

22. Open Discover → Courts. The map shows the list underneath, with OpenStreetMap attribution on the map.
23. Open a seeded court in the launch city. Confirm surface, lights, hours, and price text when the seed has them.
24. Save the court.

Expected: the court is a favorite and is still saved after leaving the screen and returning. Directions is present and hands the address to the system maps app. (BL-013)

### 7. Send a partner request

25. Open Discover → Players. The screen explains that discovery is off and offers a switch.
26. Turn discovery on. Confirm the coarse area. The confirm step does not ask for a pin on a home address.
27. Find Partner. Open the card. Check the fields before you request: display name, level label, format, city, distance band, goals, and an availability summary. Optional age band may show. Email, birth year, street address, and a map pin on the player are absent.
28. Send a partner request.
29. On Partner’s session, accept the request.
30. On Beginner, open the new conversation and send a short plain-text note.

Expected: the request is delivered. Accept creates one thread. The note appears in that thread for both people. Decline is not used on this run. (BL-014, BL-015, BL-017, BL-018)

Part A passes when steps 1–30 finish on that phone with no crash and no support contact.

## Part B — Privacy cases

Use the current phone and staging. These cases are release blockers.

### B1. Under 16 is blocked

1. Sign out. From Welcome, start account creation with a new Apple or email identity.
2. At birth year, enter 2012 and try to continue.

Expected: the flow stops. There is no Home screen, no profile, and no session for that child. Learning, courts, and messaging do not open. (BL-001)

### B2. Under 18 cannot be discoverable

1. Create Teen with birth year 2010. Finish onboarding with the launch city, and decline finding partners when that question appears.
2. Open Learn and confirm a Level 1 lesson opens. Open Discover → Courts and confirm the court list loads.
3. Open Discover → Players, or Profile → Privacy, and try to turn discovery on. If the client hides the control, call `PUT /v1/me/profile` with `discoverable: true` and this Teen access token.

Expected: Teen can learn and can open courts. Discovery stays off. The profile update is rejected. Teen does not appear in Partner’s player list. Hiding a tab is not the pass by itself; the server rejection is the pass. (BL-006, BL-007)

### B3. No exact location on a player card

1. As Beginner (adult, discoverable), open Partner’s player card again.
2. Read every line on the card. If a debug build can show the `GET /v1/players` body, inspect that body for the same card.

Expected: the card shows a city and a distance band. It does not show latitude, longitude, a home pin, a street address, an email address, or a birth year. A public court page may still show a map pin; that pin is the court, not the player. (BL-016, BL-017)

### B4. Premium lock

1. Stay on Beginner, entitlement free.
2. Open Learn and the published premium lesson Rally construction (`rally-construction`), or another published lesson with `free_tier` false if the seed slug differs.
3. Read the reader, then open the locked continuation.

Expected: the title, overview, and summary are visible. The rest of the lesson is locked. One paywall screen explains what is locked. The full blocks are not on screen. A `GET /v1/lessons/rally-construction` response uses `premium_required` and includes the title and summary. It omits the full blocks. Leave the purchase unfinished. (BL-021, BL-022)

### B5. Delete account

Do this last. It ends the Beginner account used above.

1. Profile → Privacy → Delete account.
2. Type `DELETE` and confirm. There is no email-only path for this step.
3. The app returns to Welcome. Relaunch the app.
4. Attempt to refresh the session with the refresh token captured before deletion (`POST /v1/auth/refresh`). Then sign in again with the same Apple or email identity.

Expected: the deleted refresh token is rejected (`unauthorized`). The old profile, favorites, discovery cell, and messages Beginner sent are gone. Signing in again does not restore that profile. (BL-023, BL-024)

## Record

| Part | Phone | Result | Build | Notes |
|---|---|---|---|---|
| A | Small | | | |
| A | Current | | | |
| B1 Under 16 | Current | | | |
| B2 Under 18 discoverable | Current | | | |
| B3 Player card location | Current | | | |
| B4 Premium lock | Current | | | |
| B5 Delete account | Current | | | |
