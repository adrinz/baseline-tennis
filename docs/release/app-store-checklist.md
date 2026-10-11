# Before the App Store

The database and API can stay on this Mac while you test. App Store players cannot reach your Mac. Do these outside the repo before you submit.

## Accounts and servers

- [ ] Put Postgres with PostGIS on a host (Neon, Railway, or similar). Do not ship the Mac database.
- [ ] Put the API on a host with an `https://` address. The phone talks to the API, never to the database.
- [ ] Buy or choose a domain, and point it at that API.
- [ ] Create a Resend, Postmark, or Amazon SES account so sign-in codes go to an inbox. Keep the API key on the server, not in the app and not in chat.
- [ ] Choose the From address, for example `Baseline <codes@yourdomain>`.

## Apple

- [ ] In App Store Connect, create the app `com.baselinetennis.baseline`.
- [ ] Add screenshots, a description, a support URL, and the age-rating answers. Messaging between players points to 17+.
- [ ] Host a privacy policy and terms, and put both links in App Store Connect and in the app.
- [ ] Fill in App Privacy (the nutrition labels): account, email, location for nearby places, and messages if those ship.
- [ ] On the Identifiers page, open **Baseline** and leave **Sign in with Apple** on.
- [ ] If Premium should charge money, create the subscription in App Store Connect. The on-phone unlock cannot be the paid version in the store.
- [ ] If practice reminders should arrive while the app is closed, create an Apple push key and add it to the server.

## Google

- [ ] In Google Auth Platform, publish the consent screen or add every player as a test user. A testing screen only allows listed Google accounts.
- [ ] The iOS client already uses bundle ID `com.baselinetennis.baseline`. Leave the App Store ID blank until the app is live, then add the number Apple assigns.

## On the day you submit

- [ ] Install the store build on a phone that is not on your home Wi-Fi and sign in with Apple, Google, and email.
- [ ] Confirm delete account removes the player from the hosted database.
- [ ] Confirm Discover still explains location, and player search does not show a home address.
