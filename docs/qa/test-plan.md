# Baseline test plan

Version 1. This plan is the gate for a TestFlight build of the iOS app. It follows the product requirements, the API, the privacy rules, navigation, and the testing-and-release checklist.

Out of scope for this plan: community feed, court or coach booking, swing-video analysis, live scoring, Apple Watch, and marketplace checkout. Those stay behind interfaces and are not required to submit version 1.

## Layers

| Layer | What it proves | Where it runs |
|---|---|---|
| API unit | Plan builder, coarse location rounding, age gate, premium checks, video publish rules | CI, every change |
| API integration | Auth refresh, lesson complete, connection accept, block hides a player | CI, every change, fresh database |
| Mobile widget | Onboarding step, lesson reader, paywall locked state | CI, every change |
| Mobile golden | Home, lesson, and court card on a small phone and a large phone | CI, every change |
| Manual script | The version-1 success path and the privacy cases in `docs/qa/manual-script.md` | TestFlight, on device |
| Accessibility | VoiceOver on onboarding, the lesson reader, and the drill log. Dynamic Type at the largest size | TestFlight, on device |

CI on every change also runs API lint and typecheck, proves migrations apply on a fresh database, runs Flutter analyze and unit tests, and typechecks the admin app. On main, CI builds a staging API image and a TestFlight candidate when the mobile workflow has signing secrets. Secrets stay in the host secret store.

## Environments

| Environment | Used for | Data | Notes |
|---|---|---|---|
| Local | Unit tests, integration tests, developer runs | Migration on a fresh database, then seed | The app talks only to the API. |
| Staging | TestFlight and the manual script | Published seed for one launch city. RevenueCat sandbox offerings | This is the TestFlight target. |
| Production | The build that ships after review | Migrations applied only after the staging migration succeeded | Account deletion and refresh-token checks stay on staging. |

The phone build for TestFlight uses the staging API base URL and the RevenueCat public key. Private API keys are not in the binary.

## Automated and manual

Automated tests own the rules that can be decided from a response body or a widget tree. A person owns the path a new player walks, the App Store privacy surfaces, and the screen reader.

| Check | Automated | Manual on TestFlight |
|---|---|---|
| Plan for 2, 3, 4, and 5+ days | API unit | Accept the week-1 preview in the script |
| Coarse location rounding | API unit | Player card shows a city and a distance band |
| Under 16 rejected; under 18 cannot set `discoverable` | API unit | Birth-year screens in the script |
| Premium lesson returns summary and `premium_required` | API unit and paywall widget | Open a premium lesson while free |
| Video publish rules, including blank attribution | API unit | Admin form treats license fields as required |
| Refresh rotation, lesson complete, connection accept, block hides a player | API integration | Script covers complete, request, and block on device |
| Onboarding step, lesson reader, locked paywall | Mobile widget | Full ten-question onboarding and the reader |
| Home, lesson, court card | Mobile golden, small and large phone | Same three screens on the two TestFlight phones |
| Version-1 success path | Not end to end | `docs/qa/manual-script.md` Part A |
| Privacy cases (age, discoverable, exact location, premium lock, delete) | Age, premium, and player payload in API tests | Part B of the manual script |
| Sponsored flag | API unit on the equipment payload | “Sponsored” on the card, absent from Baseline picks |
| Coach: existing drill slugs, and a pain question | API unit against `content/seed/coach_rules.json` | Read both replies, including the coaching footer |
| VoiceOver and largest Dynamic Type | Not a substitute for the device pass | Accessibility pass below |
| Privacy labels, purpose string, screenshots, age rating | — | Exit checklist |

A green CI run does not close the manual script or the accessibility pass.

## Accessibility pass

Run this on the TestFlight build, on the current phone, with a physical device. The small phone is included when the layout pass is open.

Scope, in order:

1. VoiceOver from Welcome through the last onboarding screen, including the progress bar, the city entry option, and the week-1 preview. The tester can move forward and back without a sighted tap on an unlabeled control.
2. VoiceOver on the lesson reader for Ready position: title, each block that is on the lesson, the complete control, and the next action. A missing video still leaves the lesson readable.
3. VoiceOver on the drill log for Wall rally: setup, minutes, and save. After save, the completion is announced or visible in progress.
4. Dynamic Type at the largest system size on those same three flows. Text stays on screen. Primary buttons stay reachable. The five tabs keep their short labels.

Pass means each flow can be finished with VoiceOver, and the largest type size does not clip the primary action. A failure on onboarding or the lesson reader blocks TestFlight exit. Cases BL-037 through BL-040 record the result.

## TestFlight entry

All of the following are true before the build is uploaded to TestFlight.

1. The commit’s CI run is green: API lint, typecheck, unit tests, migration on a fresh database, Flutter analyze, Flutter unit tests, admin typecheck.
2. Staging migrations are applied.
3. Seed content is published, not left in draft. The content bar for this build is at least 12 original Level 1 lessons, 10 Level 2 lessons, 8 Level 3 lessons, and 15 drills. The drill set includes wall rally, cross-court rally, forehand consistency, backhand consistency, serve targets, split step, and a figure-8 footwork pattern. The glossary and the coach rules for “into the net,” “into the fence,” and “can’t toss” are loaded.
4. The license report shows zero published videos with an empty license. Zero videos is acceptable when every lesson stands on text. Placeholder copyrighted clips are not in the build.
5. RevenueCat offerings match the paywall products. The app reads the entitlement. It does not hard-code a price.
6. Privacy policy and terms URLs open from Welcome and from Profile.
7. Sign in with Apple is on Welcome in any build that offers Google sign-in.
8. The location purpose string is: “Baseline uses your location to show nearby courts, coaches, and stores. You can type a city instead.”
9. The binary contains the public API base URL and the RevenueCat public key only. Signing secrets are not in the repo.
10. The eight must-not-regress cases, BL-007, BL-016, BL-019, BL-021, BL-023, BL-026, BL-031, and BL-033, pass against staging.

## TestFlight exit

All of the following are true before the build is submitted for App Store review.

1. Part A of the manual script passes, crash-free, on at least one small phone and one current phone. The tester does not contact support.
2. Part B of the manual script passes on the current phone: under 16 blocked, under 18 cannot become discoverable, the player card has no exact location, the premium lesson stays locked, and delete account revokes the refresh token.
3. The accessibility pass is signed off.
4. Mobile golden screenshots exist for Home, a lesson, and a court card at the small and large phone sizes used in CI. App Store screenshots add a drill. Screenshot data does not look like a real person’s full name and exact address.
5. Privacy nutrition labels match collection: account info, coarse location, user content (messages), identifiers, and product interaction.
6. The age-rating questionnaire is answered for user-generated messages. Expect 17+ when messaging ships.
7. Account deletion is available inside Profile, confirmed by typing DELETE.
8. Export compliance is recorded as HTTPS only with standard encryption.
9. A rollback note says the API on staging is backward compatible with the app version already live. Breaking API changes use `/v2`.
10. Every case in `docs/qa/cases.md` marked regression has a passing result on this build. Any failure blocks exit.

Production release stays on the release-manager checklist: migrations on staging then production, seed published, license report clean, paywall products matched, crash-free success path, and the same rollback note. TestFlight exit is the evidence that checklist items 2 through 5 are already true on staging.
