#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RELEASE_REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_DIR="$(cd "$RELEASE_REPO_DIR/../find-images" && pwd)"
GH_BIN="${GH_BIN:-/opt/homebrew/bin/gh}"
GITHUB_REPOSITORY="ceveyne/find-images-releases"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--dry-run]" >&2
  exit 2
fi

if [[ ! -x "$GH_BIN" ]]; then
  echo "ERROR: GitHub CLI not found at $GH_BIN. Set GH_BIN to its executable path." >&2
  exit 1
fi

if [[ "$DRY_RUN" == false ]]; then
  "$GH_BIN" auth status --hostname github.com >/dev/null

  if [[ -n "$(git -C "$RELEASE_REPO_DIR" status --porcelain)" ]]; then
    echo "ERROR: Commit and push the release repository before publishing." >&2
    exit 1
  fi

  if [[ "$(git -C "$RELEASE_REPO_DIR" branch --show-current)" != "main" ]]; then
    echo "ERROR: Releases must be published from the main branch." >&2
    exit 1
  fi

  localCommit="$(git -C "$RELEASE_REPO_DIR" rev-parse HEAD)"
  remoteCommit="$("$GH_BIN" api "repos/$GITHUB_REPOSITORY/commits/main" --jq '.sha')"
  if [[ "$localCommit" != "$remoteCommit" ]]; then
    echo "ERROR: Local main does not match $GITHUB_REPOSITORY/main. Push the current commit first." >&2
    exit 1
  fi
fi

"$SCRIPT_DIR/sync-docs-to-app.sh" --check
"$SCRIPT_DIR/prepare-release.sh"

VERSION="$(node -p 'require(process.argv[1]).version' "$APP_DIR/package.json")"
TAG="v$VERSION"
ARTIFACTS_DIR="$RELEASE_REPO_DIR/artifacts"
DMG_ZIP_PATH="$ARTIFACTS_DIR/Find-Images-${VERSION}-arm64.dmg.zip"
APPCAST_PATH="$ARTIFACTS_DIR/appcast.xml"
NOTES_PATH="$ARTIFACTS_DIR/release-notes-v${VERSION}.md"
CHECKSUM_PATH="$ARTIFACTS_DIR/SHA256SUMS.txt"

if [[ "$DRY_RUN" == true ]]; then
  printf 'Would publish %s to %s with:\n  %s\n  %s\n  %s\n  %s\n' "$TAG" "$GITHUB_REPOSITORY" "$NOTES_PATH" "$DMG_ZIP_PATH" "$APPCAST_PATH" "$CHECKSUM_PATH"
  exit 0
fi

"$GH_BIN" release create "$TAG" "$DMG_ZIP_PATH" "$APPCAST_PATH" "$CHECKSUM_PATH" \
  --repo "$GITHUB_REPOSITORY" \
  --target main \
  --title "Find Images $VERSION" \
  --notes-file "$NOTES_PATH"