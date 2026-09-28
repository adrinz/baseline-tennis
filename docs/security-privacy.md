# Security and privacy

## Accounts

- Sign in with Apple, Google, and email one-time codes.
- If Google sign-in ships, Sign in with Apple ships in the same build.
- Access tokens last 15 minutes. Refresh tokens rotate and are stored hashed.
- Admin routes check `admin_users`, not a hidden flag in the app.

## Age

- Birth year is required. Under 16: no account.
- Under 18: learning, training, courts, coaches, and stores work. Player browse, requests, and messaging stay off.
- The partner service enforces this on the server. Hiding the tab is not the control.

## Location

- Permission copy: “Baseline uses your location to show nearby courts, coaches, and stores. You can type a city instead.”
- Player profiles store a coarse cell and a radius. The cell is rounded before save.
- API player payloads include `distanceBand` only.
- Court coordinates are public places and may be sent to the device for the map pin.

## Messaging and abuse

- A conversation exists only after an accepted request.
- Block cuts off search and messages in both directions.
- Report stores reason and message snapshot id. Admins see the queue. Reporters see “Thanks, we received this.”
- Message bodies are plain text in MVP (no links preview, no images) to reduce spam.
- Rate limits on auth and send.

## Data rights

- Export: `GET /me/export` returns profile, progress, messages the user sent, and favorites.
- Delete: removes profile, sessions, messages they sent, discovery cell, and favorites. Lesson aggregates can remain without a user id. A deleted account cannot be reactivated.
- Privacy policy and terms are linked from Welcome and Profile before submission.

## App transport and storage

- HTTPS only.
- Tokens in the platform keychain (iOS Keychain via Flutter secure storage).
- Logs do not contain tokens, email codes, or message bodies.
- Object storage buckets are private. Owned video and photos use signed URLs.

## AI boundary

Coach answers and any future video analysis carry `label: coaching_assistance`. Copy does not diagnose injury. If the question mentions pain, the rules engine replies with a short note to stop and talk to a clinician or coach, and does not prescribe a fix.

## Admin audit

Publish, unpublish, suspend, and report decisions write `audit_log`.
