# Android Release Signing

This document explains how to generate a signing keystore, configure GitHub
Secrets, and trigger the automated build workflow for **The Broken Kitchen**.

---

## Prerequisites

- **Java 17+** installed (provides `keytool`)
- A **GitHub repository** with Actions enabled
- A **bash-compatible shell** (Linux, macOS, Git Bash on Windows, or WSL)

---

## 1. Generate a keystore

```bash
chmod +x scripts/generate_keystore.sh
./scripts/generate_keystore.sh
```

The script will prompt you for:

| Prompt                | Example                      |
|-----------------------|------------------------------|
| Organization name     | TheBrokenKitchen LLC         |
| Organizational unit   | Mobile Development           |
| City / Locality       | Cape Town                    |
| State / Province      | Western Cape                 |
| Country code          | ZA                           |
| Common name / author  | The Broken Kitchen Team      |
| Keystore password     | *(entered securely)*         |
| Key alias             | thebrokenkitchen             |
| Key password          | *(entered securely)*         |

After completion, the script prints:

- The **base64-encoded keystore** string
- The **exact secret names** to create in GitHub

> **Privacy notice:** The script does **not** read, collect, or transmit any
> system information, user profile data, IP addresses, or location data.
> Every value is entered manually by the operator.

---

## 2. Add GitHub Secrets

Go to **Settings → Secrets and variables → Actions** in your GitHub repository
and create these **four** repository secrets:

| Secret Name                       | Value                                  |
|-----------------------------------|----------------------------------------|
| `TheBrokenKitchenBase64`          | Base64 string printed by the script    |
| `TheBrokenKitchenStorePassword`   | The keystore password you chose        |
| `TheBrokenKitchenKeyAlias`        | The key alias you chose                |
| `TheBrokenKitchenKeyPassword`     | The key password you chose             |

---

## 3. Trigger the build

The workflow runs **automatically on every push** to any branch.

To trigger it manually:

```bash
git add .
git commit -m "your message"
git push
```

The workflow will:

1. Decode the keystore from `TheBrokenKitchenBase64` at runtime
2. Build a **signed release APK** and **signed release AAB**
3. Delete the keystore and key.properties immediately after the build
4. Upload both artifacts to the workflow run

Download the artifacts from **Actions → (workflow run) → Artifacts**.

### Package / key verification (Play Console)

If you added `android/app/src/main/assets/adi-registration.properties` for Google’s ownership verification, use the **signed release APK** from this same workflow (not a debug build). You do not need a separate local build: download the APK artifact and upload it in the verification screen. See `documentation/PackageNameGuide.md` for file placement details.

---

## 4. Local development

For local release builds, create `android/key.properties` (already in `.gitignore`):

```properties
storeFile=release-keystore.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=YOUR_KEY_ALIAS
keyPassword=YOUR_KEY_PASSWORD
```

Then copy your `release-keystore.jks` to `android/app/` and run:

```bash
flutter build apk --release
flutter build appbundle --release
```

---

## Security guarantees

- The keystore is **never committed** to the repository (`.gitignore` rules)
- In CI, the keystore exists **only during the build** and is deleted afterward
- Secrets are passed via **environment variables** and masked in GitHub logs
- The generation script collects **zero** system/user/IP/location data
- All sensitive values live **exclusively** in GitHub Secrets

---

## Files overview

| File                                  | Purpose                              |
|---------------------------------------|--------------------------------------|
| `.github/workflows/build.yml`         | CI workflow — build signed APK & AAB |
| `scripts/generate_keystore.sh`        | Interactive keystore generator        |
| `android/app/build.gradle.kts`        | Gradle signing + ProGuard config     |
| `android/app/proguard-rules.pro`      | R8 dontwarn rules for Play Core      |
| `SIGNING.md`                          | This document                        |
