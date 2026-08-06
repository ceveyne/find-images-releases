#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RELEASE_REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_DIR="$(cd "$RELEASE_REPO_DIR/../find-images" && pwd)"

if [[ "${1:-}" == "--check" ]]; then
  cmp --silent "$RELEASE_REPO_DIR/README.md" "$APP_DIR/README.md"
  diff --recursive --brief --exclude '.DS_Store' "$RELEASE_REPO_DIR/docs" "$APP_DIR/docs"
  node "$SCRIPT_DIR/sync-readme-de.mjs" --check "$APP_DIR/README.md" "$RELEASE_REPO_DIR/README.md" "$APP_DIR/README_DE.md"
  echo "Find Images documentation is synchronized."
  exit 0
fi

node "$SCRIPT_DIR/sync-readme-de.mjs" "$APP_DIR/README.md" "$RELEASE_REPO_DIR/README.md" "$APP_DIR/README_DE.md"
rsync --archive --delete --exclude '.DS_Store' "$RELEASE_REPO_DIR/docs/" "$APP_DIR/docs/"
cp "$RELEASE_REPO_DIR/README.md" "$APP_DIR/README.md"

echo "Synchronized documentation to $APP_DIR"