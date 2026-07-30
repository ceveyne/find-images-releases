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
ZIP_PATH="$ARTIFACTS_DIR/Find-Images-${VERSION}-arm64.dmg.zip"
NOTES_PATH="$ARTIFACTS_DIR/release-notes-v${VERSION}.md"
CHECKSUM_PATH="$ARTIFACTS_DIR/SHA256SUMS.txt"

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

rm -f "$ZIP_PATH" "$CHECKSUM_PATH"
ditto -c -k --sequesterRsrc --keepParent "$DMG_PATH" "$ZIP_PATH"
shasum -a 256 "$ZIP_PATH" > "$CHECKSUM_PATH"

echo "Prepared release v$VERSION"
echo "  Asset: $ZIP_PATH"
echo "  Notes: $NOTES_PATH"
echo "  SHA-256: $CHECKSUM_PATH"