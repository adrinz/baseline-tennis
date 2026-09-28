# Testing and release

## Test layers

| Layer | What it covers |
|---|---|
| API unit | Plan builder, coarse location rounding, age gate, premium checks, video publish rules |
| API integration | Auth refresh, lesson complete, connection accept, block hides a player |
| Mobile widget | Onboarding step, lesson reader, paywall locked state |
| Mobile golden | Home, lesson, court card, on a small phone and a large phone |
| Manual script | The version-1 success path in the product requirements |
| Accessibility | VoiceOver pass on onboarding, lesson, and drill log. Dynamic type at the largest size. |

## Cases that must not regress

- Player under 18 cannot set `discoverable`
- Player response has no latitude or longitude
- Video publish fails when attribution is blank
- Premium lesson returns the summary and `premium_required`, not the full blocks
- Deleted account’s refresh token stops working
- Two users who blocked cannot load a thread
- “Forehand into the net” returns only drill slugs that exist
- Sponsored equipment is flagged in the payload

## App Store

- Privacy policy URL and terms URL
- Privacy nutrition labels: account info, coarse location, user content (messages), identifiers, product interaction
- Location purpose string matches the in-app explanation
- Sign in with Apple present
- Age rating questionnaire answered for user-generated messages (expect 17+ if messaging ships)
- Account deletion inside the app, not only by email
- No private API keys in the binary
- Screenshots of Home, a lesson, a drill, and a court map. No mock data that looks like a real person’s full name and exact address
- Export compliance: HTTPS only, standard encryption
- TestFlight on at least one small phone and one current phone before review

## CI

On every change:

- API lint, typecheck, unit tests, migration applies on a fresh database
- Flutter analyze and unit tests
- Admin typecheck

On main: build a staging API image and a TestFlight candidate when the mobile workflow is given signing secrets. Secrets are not committed.

## Release manager checklist

1. Migrations applied on staging, then production
2. Seed content published, not left in draft
3. License report: zero published videos with an empty license
4. Paywall products match RevenueCat offerings
5. Crash-free smoke test of the success path
6. Rollback note: API is backward compatible for the live app version
