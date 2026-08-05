#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RELEASE_REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_DIR="$(cd "$RELEASE_REPO_DIR/../find-images" && pwd)"
PACKAGE_JSON="$APP_DIR/package.json"
CHANGELOG="$RELEASE_REPO_DIR/docs/CHANGELOG.md"
ARTIFACTS_DIR="$RELEASE_REPO_DIR/artifacts"

VERSION="$(node -p 'require(process.argv[1]).version' "$PACKAGE_JSON")"
DMG_PATH="$APP_DIR/release/Find Images-${VERSION}-arm64.dmg"
DMG_ZIP_PATH="$ARTIFACTS_DIR/Find-Images-${VERSION}-arm64.dmg.zip"
APPCAST_PATH="$ARTIFACTS_DIR/appcast.xml"
NOTES_PATH="$ARTIFACTS_DIR/release-notes-v${VERSION}.md"
CHECKSUM_PATH="$ARTIFACTS_DIR/SHA256SUMS.txt"
RELEASE_BASE_URL="https://github.com/ceveyne/find-images-releases/releases/download/v${VERSION}"

mkdir -p "$ARTIFACTS_DIR"

temporaryNotesPath="$(mktemp "$ARTIFACTS_DIR/.release-notes.XXXXXX")"
trap 'rm -f "$temporaryNotesPath"' EXIT

if ! awk -v prefix="## [$VERSION] - " '
  /^## \[/ && found { exit }
  index($0, prefix) == 1 { found = 1 }
  found { print }
  END { if (!found) exit 1 }
' "$CHANGELOG" > "$temporaryNotesPath"; then
  echo "ERROR: No changelog section found for version $VERSION in $CHANGELOG" >&2
  exit 1
fi

if [[ ! -s "$temporaryNotesPath" ]]; then
  echo "ERROR: No changelog section found for version $VERSION in $CHANGELOG" >&2
  exit 1
fi

mv "$temporaryNotesPath" "$NOTES_PATH"

if [[ ! -f "$DMG_PATH" ]]; then
  echo "ERROR: Expected notarized DMG not found: $DMG_PATH" >&2
  echo "Run from find-images first: npm run dist:mac -- --notarize" >&2
  exit 1
fi

rm -f "$DMG_ZIP_PATH" "$APPCAST_PATH" "$CHECKSUM_PATH"
ditto -c -k --sequesterRsrc "$DMG_PATH" "$DMG_ZIP_PATH"

SIGNATURE=""
PRIVATE_KEY_PATH="$APP_DIR/packaging/sparkle-ed25519/sparkle-ed25519-private.key"
if [[ -f "$PRIVATE_KEY_PATH" ]]; then
  SIGNATURE="$(node "$SCRIPT_DIR/sign-update.mjs" "$DMG_ZIP_PATH")"
else
  echo "WARNING: No EdDSA private key found at $PRIVATE_KEY_PATH" >&2
  echo "WARNING: Run generate-sparkle-keys.mjs to enable update signature verification." >&2
fi

node "$SCRIPT_DIR/generate-appcast.mjs" "$VERSION" "$DMG_ZIP_PATH" "$APPCAST_PATH" "$RELEASE_BASE_URL" ${SIGNATURE:=""}
shasum -a 256 "$DMG_ZIP_PATH" > "$CHECKSUM_PATH"

echo "Prepared release v$VERSION"
echo "  DMG asset: $DMG_ZIP_PATH"
echo "  Appcast: $APPCAST_PATH"
echo "  Notes: $NOTES_PATH"
echo "  SHA-256: $CHECKSUM_PATH"