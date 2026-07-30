# Releasing Find Images

This repository is the public documentation and release home for Find Images.app. It intentionally does not contain application source code or committed binary artifacts.

## Documentation

Edit `README.md` and `docs/` here. Then mirror the canonical documentation into the application repository:

```bash
./scripts/sync-docs-to-app.sh
./scripts/sync-docs-to-app.sh --check
```

## Build And Prepare

1. Set the same version in `../find-images/package.json` and the heading in `docs/CHANGELOG.md`.
2. Build, notarize, staple, and validate the app from `../find-images`:

```bash
npm run dist:mac -- --notarize
```

3. Create the GitHub release here:

```bash
./scripts/publish-release.sh
```

Use `./scripts/publish-release.sh --dry-run` to prepare the local files and show the tag, notes, and assets without making GitHub changes.

The publisher requires `../find-images/release/Find Images-<version>-arm64.dmg`, a clean local `main` branch, and an identical `main` commit already pushed to `ceveyne/find-images-releases`. It creates these ignored files in `artifacts/`:

- `Find-Images-<version>-arm64.dmg.zip`
- `release-notes-v<version>.md`
- `SHA256SUMS.txt`

The publisher creates tag `v<version>`, creates the GitHub release with the Changelog section as its notes, and uploads the ZIP and `SHA256SUMS.txt`. GitHub's automatic source-code archives then contain only this repository's documentation and release scripts, never the Find Images application source.