# Project audit

## Original issues

- Web startup called `Firebase.initializeApp()` without web options, leaving web execution unconfigured.
- Android applied the Google Services plugin without declaring its version in the settings plugin block.
- Registration had no loading guard; controllers were not disposed; async handlers reused widget contexts without mounted checks.
- Passwords were trimmed before authentication, changing valid credentials.
- Chat could resend stale text because a separate `messageText` variable survived controller clearing.
- Sends and sign-out had no error feedback; Firestore stream failures appeared as endless loading.
- Chat was directly routable without an authentication guard, and sign-out left an inconsistent route stack.
- Message history was unbounded. The repository supplied no Firestore security rules.
- Authentication screens duplicated most layout and field code; large fixed spacing and unbounded forms weakened desktop/narrow-screen usability.
- The test was the stock counter test and did not match this app. README and web metadata were template placeholders.
- A Firebase Android client configuration was tracked. No service-account credentials were introduced or printed during this audit.

## Changes

Preserved Flutter, Firebase Authentication, the `messages` collection, and the existing message fields. Added `senderId` to newly created messages to enforce sender identity in the supplied rules; existing documents remain readable without migration. The UI intentionally describes the room as shared, not private.

Introduced a small injectable chat service, shared authentication form/layout, safe startup configuration, explicit local demo mode, and local tests. Added authenticated route gating, generic credential errors, bounded history, send guards, mounted checks, draft retention, and actionable read errors. Controllers and subscriptions are disposed. Member email addresses are no longer displayed or printed by registration.

Added Firebase rules and deployment instructions; rules are **not deployed**, and no live Firebase database or accounts were accessed. The rules restrict creates but do not implement server-side spam/rate limits or moderation.

Removed the Android Firebase client configuration from the Git index only, preserving the local file, and expanded ignore rules for configuration/build/signing outputs. Firebase client configuration can exist in old commits; removing tracking does not erase history.

## Validation

Validation uses local synthetic messages and fake services. Live Firebase authentication, deployed rules, Android/iOS release builds, and production hosting require the owner's environment and remain manual checks. Screenshots are from the visibly labelled demo, not evidence of a live backend connection.

The original collection was a single shared room and remains so. This application is not a private messenger or an end-to-end encrypted service.

### Results (2026-10-19)

- `flutter pub get`: passed; existing dependency versions retained.
- `flutter analyze --no-pub`: no issues.
- `flutter test --no-pub`: 12 tests passed, including validation, password preservation, safe errors, send/duplicate behavior, draft retention, authenticated routing, read failure, narrow layout, and sign-out navigation.
- Normal release web build: passed. Without local Firebase web configuration, startup correctly renders the setup screen.
- Explicit demo release web build: passed, in separate ignored `build/web-demo/`.
- Chrome smoke tests: passed at 390×844, 1440×900, and 320×640. Verified validation, sign-in, send, duplicate prevention, sign-out, and safe missing-config startup. No JavaScript errors, failed HTTP responses, or Firebase network requests were observed during demo tests.
- Seven screenshots visually reviewed, all with synthetic data and empty password fields.
- Native builds, live Firebase connectivity, and Firestore rules emulator/deployment tests were not run. Firebase setup/rules deployment and production Android signing remain manual.
