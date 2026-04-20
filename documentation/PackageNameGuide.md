# Android package verification — what we added in the codebase

Short reference for doing the same in this project or another app.

## What was added

**One file** in the Android app module:

| Location | Purpose |
|----------|---------|
| `android/app/src/main/assets/adi-registration.properties` | Holds the one-line registration value Google gives you in the verification flow. |

Details:

- **Folder:** `android/app/src/main/assets/` (create `assets` if it does not exist).
- **Filename:** exactly `adi-registration.properties` (spelling and extension matter).
- **Contents:** a single line — the identifier Google shows you when you start package/key verification. No labels, no extra keys; just that line.

Gradle picks up everything under `src/main/assets/` and puts it in the APK under `assets/`. You do **not** list this file in Flutter’s `pubspec.yaml` for it to be included.

## What was already correct

No change was required to:

- **`applicationId`** / **`namespace`** in `android/app/build.gradle.kts` — they already matched the package name being registered.
- **Kotlin package** and **`MainActivity`** path under `android/app/src/main/kotlin/...` — already aligned with that ID.

## What you do after the file exists

1. Build a **release** APK signed with your **release** keystore (the same key whose certificate fingerprint you gave Google).
2. Upload that APK in the verification screen.

You do **not** have to build on your machine. If this repo uses GitHub Actions (see `SIGNING.md`), push your branch, open the workflow run, download the signed **release APK** artifact, and upload that file to Google’s verification step. The APK must still be signed with the same key you registered.

Nothing else in the repo was modified for this step.

## Doing it on another app

1. Set the app’s **`applicationId`** in `android/app/build.gradle.kts` (or `.gradle`) to the package name you are registering.
2. Add `android/app/src/main/assets/adi-registration.properties` with the **new** one-line value from that app’s verification step.
3. Build and upload a signed release APK as above (locally or via CI).
