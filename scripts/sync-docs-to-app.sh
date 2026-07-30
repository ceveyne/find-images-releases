#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RELEASE_REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_DIR="$(cd "$RELEASE_REPO_DIR/../find-images" && pwd)"

if [[ "${1:-}" == "--check" ]]; then
  cmp --silent "$RELEASE_REPO_DIR/README.md" "$APP_DIR/README.md"
  diff --recursive --brief --exclude '.DS_Store' "$RELEASE_REPO_DIR/docs" "$APP_DIR/docs"
  echo "Find Images documentation is synchronized."
  exit 0
fi

rsync --archive --delete --exclude '.DS_Store' "$RELEASE_REPO_DIR/docs/" "$APP_DIR/docs/"
cp "$RELEASE_REPO_DIR/README.md" "$APP_DIR/README.md"

echo "Synchronized documentation to $APP_DIR"