# End-to-end tests

These checks cover the version-1 player app, the API, and the Postgres schema. Phone Discover uses the device location, Apple Maps, and OpenStreetMap. It does not call Google. Distances on the phone are miles. The API still stores a player search radius in kilometers and returns a coarse distance band, never a coordinate.

Automated cases run in CI without a phone. Device cases need the unlocked iPhone and location permission. A green automated run does not replace the device pass.

## Run

```bash
cd apps/mobile && flutter test
cd services/api && npm test
```

Against a database that already has migrations `001_init.sql` and `002_seed_reference.sql`:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f services/api/db/verify_e2e.sql
```

| Automated file | What it walks |
|---|---|
| `apps/mobile/test/e2e/app_flows_test.dart` | Welcome, onboarding, Home, Learn, Train, search, coach, Profile, equipment, premium, sign out |
| `apps/mobile/test/e2e/discover_flow_test.dart` | Courts, coaches, stores, players, miles, Back, save, location denied, later results |
| `apps/mobile/test/age_gate_test.dart` | Under 16, age-gate copy, Apple on Welcome |
| `apps/mobile/test/lesson_reader_test.dart` | Lesson reader |
| `apps/mobile/test/videos_test.dart` | Licensed clips and credits |
| `services/api/test/api.test.ts` | Age, player-card privacy, premium header, coach rules, video publish |
| `services/api/test/e2e-journey.test.ts` | One adult account through learning, places, partners, export, and deletion |
| `services/api/test/schema-e2e.test.ts` | Migration and seed files match the database contract |
| `services/api/db/verify_e2e.sql` | The same contract on a live Postgres 16 + PostGIS database |

The phone map channel is `baseline/places`. Widget tests stand in for CoreLocation, MapKit, and Overpass. They check that the screen shows every place the channel returns for that mile radius, including nearer places inside a wider radius.

## UI components

| ID | Component | Pass |
|---|---|---|
| E2E-U01 | Welcome and sign-in | “Get started”, “Sign in with Apple”, then Google and email on the next screen. Apple stays visible because Google is offered. |
| E2E-U02 | Type scale | System text scale is not clamped. At 2x, the welcome title uses that scale. |
| E2E-U03 | `BaselineButton`, `LineCard`, `ScaledText` | Primary controls are at least 48 by 48 points. Card text follows the text scaler. |
| E2E-U04 | Tab bar | Home, Learn, Train, Discover, Profile. Each tab is a 56-point target. The selected tab uses the ball marker. |
| E2E-U05 | Discover segments | Courts, Players, Coaches, Stores. Selected segment is night-court fill. Switching segments leaves the previous detail. |
| E2E-U06 | Mile chips | 1, 2, 5, 10, 25, and Other. Selected chip is filled. Other accepts 1 to 50. |
| E2E-U07 | Place card | Name, court-count note when present, address, and a mile label. Under 0.1 miles reads “Under 0.1 mi”. |
| E2E-U08 | Place detail | Eyebrow (COURT, COACH, or STORE), distance, address, source, Back, Directions, and Save. Call when a phone exists. Website when a URL exists. |
| E2E-U09 | Empty and error cards | Location off, location unavailable, and nothing nearby each have one action. |
| E2E-U10 | Equipment cards | Baseline picks and the partner block are separate. The partner card says Sponsored. |

## Account and learning flows

| ID | Flow | Pass |
|---|---|---|
| E2E-A01 | First week | Four questions, then the week preview, then Home. Accepting the plan opens the shell. |
| E2E-A02 | Free lesson | Introduction to tennis can be marked complete. |
| E2E-A03 | Premium lesson | Rally construction shows the lock and See Premium. |
| E2E-A04 | Search, train, coach | Search finds a forehand drill. Train shows the week and Wall rally. A pain question tells the player to see a clinician. |
| E2E-A05 | Profile | Level, age band, and goal. Discoverable for an adult shares a distance band. Equipment, match log, inbox, and privacy open inside Profile. Unlock on this phone does not charge and returns to Profile. Sign out returns to Welcome. |
| E2E-A06 | Discover tab | Discover stays inside the tab shell. Court names use miles. |

Under 16 cannot leave the age gate. A 16 or 17 year old can learn and look up places. Player discovery stays off until 18.

## Discover

The Courts caption is: named parks, schools, academies, and tennis centers. A wider distance keeps every court from a shorter one. Coaches, stores, and players use the same rule for their own lists.

| ID | Check | Pass |
|---|---|---|
| E2E-D01 | 5 miles, then 10 | 5 miles shows Terry Farrell Park, Caledonia Park, and Half Hollow Hills High School West. 10 miles still shows those three and adds Dix Hills Tennis Center. The channel is asked for 5, then 10. |
| E2E-D02 | Court detail | Back returns to the list. Source for a park is OpenStreetMap. Save becomes Saved. Directions calls the map channel. |
| E2E-D03 | Custom miles | 80 is clamped to 50. The 50-mile result still includes the nearer parks. |
| E2E-D04 | Coaches and stores | 10 miles includes the coach and shop already shown at 5 miles, plus the farther ones. Coach detail can call. Store detail can open a website. |
| E2E-D05 | Adult players | No map pins. Empty copy names the selected miles and says a wider band includes the shorter one. Turning on Discoverable asks before sharing a band. |
| E2E-D06 | Under 18 | Players explains that discovery is off. Mile chips and the switch are absent. Courts still search. |
| E2E-D07 | Location denied | “Location is off” and Open Settings. |
| E2E-D08 | Later results | The first courts stay on screen while a farther search finishes. The finished list still contains them. |

The phone must not list a row whose only name is “Tennis Court” or “Tennis Courts”, and it must not list a private court. Those rows are removed before the list is drawn. The widget fixtures only contain the named public places.

## Device pass

Run this on the installed release build, with location allowed, around Dix Hills.

1. Courts at 1, 2, and 5 miles show places inside that distance. Terry Farrell Park, Caledonia Park, and Half Hollow Hills High School West appear once the radius covers them (about 0.8, 1.4, and 3.6 miles).
2. Courts at 10 miles still shows every court that was visible at 1, 2, and 5 miles, then adds farther named parks, schools, academies, and tennis centers.
3. No row is only “Tennis Court”. No private court is listed. Schools and parks appear with a court count when OpenStreetMap grouped the pitches.
4. Open a place. Back, at the top of the tab and in the detail, returns to the same list. Distance is in miles.
5. Coaches and Stores: 10 miles includes every result from 5 miles.
6. Players: choosing 10 miles does not drop anyone who would appear at 5. The list stays empty until another adult opts in. There is no pin on a home.
7. The first results can appear while “Finding more … farther out” is still visible. The spinner does not block those first rows.
8. A park or school detail credits OpenStreetMap. A center or shop from Apple Maps says so.

25 miles can take longer because the court search is split into tiles. A failed far tile omits only that tile. Cached nearer places remain.

## API journey

`E2E-API` in `services/api/test/e2e-journey.test.ts` is one adult account:

1. Unsigned `/v1/me` is 401. A wrong email code is 401. Dev code `000000` signs in.
2. Latitude without longitude is rejected.
3. Onboarding builds a 3-day plan with 12 items. Completing an item twice returns 409.
4. `welcome-to-tennis` can be completed. `rally-construction` returns `premium_required` and the summary, without blocks, until the dev premium header is allowed.
5. Wall rally can be logged. Levels, glossary, rules, and techniques respond. An unknown video is 404.
6. A 1 km court search returns Riverton Municipal Courts and North Loop Indoor Tennis. A 15 km search still returns both, plus Cedar Park Public Courts. The same inclusion holds for coaches and stores.
7. Saving a court twice returns 409. Deleting the favorite returns 204.
8. Turning on discovery stores a coarse cell. The profile and the player list do not contain coordinates, email, or birth year. A 3 km player search returns Riley. A 15 km search still returns Riley and also Casey. Each card has a distance band.
9. Blocking Riley removes Riley and leaves Casey. A connection with Casey can be accepted, messaged, and reported.
10. Equipment has one sponsored product. Search requires `q`. The forehand coach answer is labeled `coaching_assistance`. A pain question names a clinician and has no drill.
11. Export includes the favorite and the sent message, and no raw coordinate. Logout makes the refresh token fail. Deleting the account makes the access token fail.

The in-memory API is what `npm test` runs. Phone progress for lessons and drills is on-device until the app is pointed at this API.

## Database

`schema-e2e.test.ts` reads the migration files. `verify_e2e.sql` checks a live database after migrate and seed.

Pass means all of the following:

- PostGIS is installed.
- The 45 application tables exist, from `users` through `audit_log`.
- `player_profiles.location_cell` is `geography`. There is no latitude, longitude, or email column on that table. `search_radius_km` exists. The gist index exists.
- A deleted profile cannot stay discoverable, and a deleted profile cannot keep `location_cell`.
- Video publish checks require attribution metadata. Owned files cannot use a third-party license.
- Seed data has five levels, at least seven badges, and three public sample courts: South Austin Tennis Center, Little Stacy Neighborhood Park, and Ramsey Park. Those courts are sample rows, not the phone’s live Discover list.
- Sample court names are not “Tennis Court” and do not say private.

Player search results are built by the API from the coarse cell. They are not a database view that returns the point.
