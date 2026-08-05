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
RELEASE_DMG_PATH="$ARTIFACTS_DIR/Find-Images-${VERSION}-arm64.dmg"
APPCAST_PATH="$ARTIFACTS_DIR/appcast.xml"
NOTES_PATH="$ARTIFACTS_DIR/release-notes-v${VERSION}.md"
CHECKSUM_PATH="$ARTIFACTS_DIR/SHA256SUMS.txt"
RELEASE_BASE_URL="https://github.com/ceveyne/find-images-releases/releases/download/v${VERSION}"

NOTARIZE=false
if [[ "${1:-}" == "--notarize" ]]; then
  NOTARIZE=true
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--notarize]" >&2
  exit 2
fi

mkdir -p "$ARTIFACTS_DIR"

if [[ ! "$VERSION" =~ ^(.+)-([0-9]+)$ ]]; then
  echo "ERROR: Expected release version ending in -<build>, received $VERSION" >&2
  exit 1
fi
EXPECTED_BUNDLE_VERSION="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"

validate_dmg_bundle_versions() {
  local mountPoint
  local infoPlist
  local bundleVersion
  local shortVersion

  mountPoint="$(mktemp -d /tmp/find-images-release.XXXXXX)"
  if ! hdiutil attach -readonly -nobrowse -mountpoint "$mountPoint" "$DMG_PATH" >/dev/null; then
    rm -rf "$mountPoint"
    echo "ERROR: Could not mount DMG for version validation: $DMG_PATH" >&2
    exit 1
  fi

  infoPlist="$mountPoint/Find Images.app/Contents/Info.plist"
  if [[ ! -f "$infoPlist" ]]; then
    hdiutil detach "$mountPoint" >/dev/null
    rm -rf "$mountPoint"
    echo "ERROR: DMG does not contain Find Images.app" >&2
    exit 1
  fi

  bundleVersion="$(plutil -extract CFBundleVersion raw -o - "$infoPlist")"
  shortVersion="$(plutil -extract CFBundleShortVersionString raw -o - "$infoPlist")"
  hdiutil detach "$mountPoint" >/dev/null
  rm -rf "$mountPoint"

  if [[ "$bundleVersion" != "$EXPECTED_BUNDLE_VERSION" || "$shortVersion" != "$VERSION" ]]; then
    echo "ERROR: DMG version metadata does not match the Sparkle release contract." >&2
    echo "Expected CFBundleVersion=$EXPECTED_BUNDLE_VERSION and CFBundleShortVersionString=$VERSION" >&2
    echo "Found CFBundleVersion=$bundleVersion and CFBundleShortVersionString=$shortVersion" >&2
    exit 1
  fi
}

temporaryNotesPath="$(mktemp "$ARTIFACTS_DIR/.release-notes.XXXXXX")"
trap 'rm -f "$temporaryNotesPath"' EXIT

if [[ "$NOTARIZE" == true ]]; then
  npm --prefix "$APP_DIR" run notarize:mac
else
  npm --prefix "$APP_DIR" run dist:mac
fi

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
  echo "ERROR: Expected DMG not found after packaging: $DMG_PATH" >&2
  exit 1
fi

validate_dmg_bundle_versions

rm -f "$RELEASE_DMG_PATH" "$APPCAST_PATH" "$CHECKSUM_PATH"
cp "$DMG_PATH" "$RELEASE_DMG_PATH"

SIGNATURE=""
PRIVATE_KEY_PATH="$APP_DIR/packaging/sparkle-ed25519/sparkle-ed25519-private.key"
if [[ -f "$PRIVATE_KEY_PATH" ]]; then
  SIGNATURE="$(node "$SCRIPT_DIR/sign-update.mjs" "$RELEASE_DMG_PATH")"
else
  echo "WARNING: No EdDSA private key found at $PRIVATE_KEY_PATH" >&2
  echo "WARNING: Run generate-sparkle-keys.mjs to enable update signature verification." >&2
fi

node "$SCRIPT_DIR/generate-appcast.mjs" "$VERSION" "$RELEASE_DMG_PATH" "$APPCAST_PATH" "$RELEASE_BASE_URL" ${SIGNATURE:=""}
shasum -a 256 "$RELEASE_DMG_PATH" > "$CHECKSUM_PATH"

echo "Prepared release v$VERSION"
echo "  DMG asset: $RELEASE_DMG_PATH"
echo "  Appcast: $APPCAST_PATH"
echo "  Notes: $NOTES_PATH"
echo "  SHA-256: $CHECKSUM_PATH"