#!/usr/bin/env bash
#
# generate_keystore.sh
#
# Generates a JKS keystore for signing The Broken Kitchen Android app.
# All values are prompted interactively — nothing is auto-filled or read
# from the system, user profile, IP address, or location data.
#
# Output:
#   1. A .jks keystore file
#   2. The base64-encoded keystore (for GitHub Secrets)
#   3. Clear instructions for adding secrets to GitHub
#
# Usage:
#   chmod +x scripts/generate_keystore.sh
#   ./scripts/generate_keystore.sh

set -euo pipefail

KEYSTORE_FILE="release-keystore.jks"

echo "============================================================"
echo "  The Broken Kitchen — Keystore Generator"
echo "============================================================"
echo ""
echo "  This script does NOT read any system information,"
echo "  user data, IP address, or location data."
echo "  All values are entered manually by you."
echo ""
echo "============================================================"
echo ""

# ── Prompt for company / certificate details ──────────────────────

read -rp "Company / Organization name (e.g. TheBrokenKitchen LLC): " CN_ORG
read -rp "Organizational unit   (e.g. Mobile Development): " CN_OU
read -rp "City / Locality       (e.g. Cape Town): " CN_CITY
read -rp "State / Province      (e.g. Western Cape): " CN_STATE
read -rp "Country code (2-letter, e.g. ZA): " CN_COUNTRY
read -rp "Common name / author  (e.g. The Broken Kitchen Team): " CN_NAME

echo ""

# ── Prompt for keystore credentials ──────────────────────────────

read -rsp "Keystore password (will not echo): " STORE_PASS
echo ""
read -rsp "Confirm keystore password: " STORE_PASS_CONFIRM
echo ""

if [ "$STORE_PASS" != "$STORE_PASS_CONFIRM" ]; then
  echo "ERROR: Keystore passwords do not match. Aborting."
  exit 1
fi

read -rp "Key alias (e.g. thebrokenkitchen): " KEY_ALIAS

read -rsp "Key password (will not echo): " KEY_PASS
echo ""
read -rsp "Confirm key password: " KEY_PASS_CONFIRM
echo ""

if [ "$KEY_PASS" != "$KEY_PASS_CONFIRM" ]; then
  echo "ERROR: Key passwords do not match. Aborting."
  exit 1
fi

# ── Validate inputs ──────────────────────────────────────────────

if [ -z "$CN_ORG" ] || [ -z "$CN_OU" ] || [ -z "$CN_CITY" ] || \
   [ -z "$CN_STATE" ] || [ -z "$CN_COUNTRY" ] || [ -z "$CN_NAME" ] || \
   [ -z "$STORE_PASS" ] || [ -z "$KEY_ALIAS" ] || [ -z "$KEY_PASS" ]; then
  echo "ERROR: All fields are required. Aborting."
  exit 1
fi

if [ ${#CN_COUNTRY} -ne 2 ]; then
  echo "ERROR: Country code must be exactly 2 letters (e.g. ZA, US, GB). Aborting."
  exit 1
fi

# ── Remove any pre-existing keystore with the same name ──────────

if [ -f "$KEYSTORE_FILE" ]; then
  echo ""
  echo "WARNING: $KEYSTORE_FILE already exists and will be overwritten."
  rm -f "$KEYSTORE_FILE"
fi

# ── Generate the keystore ────────────────────────────────────────

DNAME="CN=${CN_NAME}, OU=${CN_OU}, O=${CN_ORG}, L=${CN_CITY}, ST=${CN_STATE}, C=${CN_COUNTRY}"

keytool -genkeypair \
  -v \
  -keystore "$KEYSTORE_FILE" \
  -alias "$KEY_ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass "$STORE_PASS" \
  -keypass "$KEY_PASS" \
  -dname "$DNAME"

echo ""
echo "Keystore generated: $KEYSTORE_FILE"
echo ""

# ── Base64-encode the keystore ───────────────────────────────────

KEYSTORE_B64=$(base64 -w 0 "$KEYSTORE_FILE" 2>/dev/null || base64 "$KEYSTORE_FILE" | tr -d '\n')

echo "============================================================"
echo "  GITHUB SECRETS — Copy the values below"
echo "============================================================"
echo ""
echo "Go to your GitHub repo → Settings → Secrets and variables → Actions"
echo "and create the following repository secrets:"
echo ""
echo "┌─────────────────────────────────────┬─────────────────────┐"
echo "│ Secret Name                         │ Value               │"
echo "├─────────────────────────────────────┼─────────────────────┤"
echo "│ TheBrokenKitchenBase64              │ (see below)         │"
echo "│ TheBrokenKitchenStorePassword       │ (your store pass)   │"
echo "│ TheBrokenKitchenKeyAlias            │ $KEY_ALIAS          │"
echo "│ TheBrokenKitchenKeyPassword         │ (your key pass)     │"
echo "└─────────────────────────────────────┴─────────────────────┘"
echo ""
echo "── TheBrokenKitchenBase64 (paste this entire string): ──"
echo ""
echo "$KEYSTORE_B64"
echo ""
echo "── TheBrokenKitchenStorePassword: ──"
echo "  (the keystore password you just entered)"
echo ""
echo "── TheBrokenKitchenKeyAlias: ──"
echo "  $KEY_ALIAS"
echo ""
echo "── TheBrokenKitchenKeyPassword: ──"
echo "  (the key password you just entered)"
echo ""
echo "============================================================"
echo "  IMPORTANT"
echo "============================================================"
echo ""
echo "  1. Do NOT commit $KEYSTORE_FILE to version control."
echo "     It is already listed in .gitignore."
echo ""
echo "  2. Store a backup of $KEYSTORE_FILE in a secure location."
echo "     If you lose it, you cannot update your app on Google Play."
echo ""
echo "  3. The passwords are NOT stored anywhere by this script."
echo "     Keep them in a password manager."
echo ""
echo "============================================================"

# ── Clean up sensitive variables from memory ─────────────────────

unset STORE_PASS STORE_PASS_CONFIRM KEY_PASS KEY_PASS_CONFIRM KEYSTORE_B64
