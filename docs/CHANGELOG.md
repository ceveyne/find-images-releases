# Changelog

Notable changes to this project will be documented in this file.

## Distribution

- **Search Engine Source Code:** [LM Studio Hub](https://lmstudio.ai/ceveyne/find-image)
- **Runtime Engine Source Code:** [GitHub Repository](https://github.com/ceveyne/qwen3-vl-embedding)

---

## [0.1.52-3] - 2026-08-07

### Added

- New "Enabled Image Formats" setting lets you choose which image formats the indexer processes. File watchers only monitor the selected formats. Native formats (PNG, JPG/JPEG, HEIC, BMP, GIF, HDR, PIC), other macOS formats (HEICS, HEIF, PICT, TIFF, WebP), and RAW formats (DNG, RAW) are enabled by default.
- Added a Privacy section to the README explaining that all search happens locally, with the update check and iCloud Photos exceptions.

### Changed

- Pressing Enter in the Help window's search field now jumps directly to the first match.
- The Help window's next and previous search buttons now highlight when multiple matches are available.

---

## [0.1.52-1] - 2026-08-06

### Added

- Added in-app updates: a short time after startup the app checks for updates, and a toolbar button appears when an update is available.
- Added a "Check for updates…" item to the app menu.
- The Settings screen shows the installed version and, when an update is available, the new version number and a button to download and install it.
- Added a Help window with the full README and searchable in-page help.
- The macOS Help Viewer is now integrated; searching from the menu bar finds help topics and jumps to them.

---

## [0.1.51-8] - 2026-08-04

### Added

- Added a setting to purge multimodal embeddings for images that are no longer part of the configured sources.
- Apple Photos indexing can now be restricted to selected albums.
- Apple Photos indexing now shows per-image average time and estimated remaining time.
- Searches for an image filename now also match Apple Photos originals by their original filename.
- Added a Copy Log button to copy the current indexer log to the clipboard.

### Changed

- PSD images are now normalized before embedding and search to improve compatibility.
- The Apple Photos authorization status is now logged at indexing time.
- README clarifies that Apple Photos indexing downloads originals from iCloud when necessary.

---

## [0.1.51-5] - 2026-08-02

### Added

- Added support for native PNG, JPG/JPEG, HEIC, TGA, BMP, PSD, GIF, HDR, PIC, PPM, and PGM images.
- Added support for ASTC, AVCI, AVIF, DDS, DCM, EXR, HEICS, HEIF, ICNS, ICO, JP2, JXL, KTX, MPO, PBM, PDF, PICT, PVR, SGI, SVG, TIFF, and WebP images.
- Added optional RAW image indexing for 3FR, ARW, AXR, CR2, CR3, CRW, DCR, DNG, DXO, ERF, FFF, IIQ, MOS, MRW, NEF, NEFX, NRW, ORF, PEF, RAF, RAW, RW2, RWL, SR2, SRF, SRW, and TIF images.
- Added Apple Photos Library support.
- Added context menus, cut/copy/paste for queries, and matching icons across the app.

---

## [0.1.50-1] - 2026-07-31

### Added

- Initial release
- The [Find Images.app](https://github.com/ceveyne/find-images-releases/releases) is for people who either are not particular fans of "agentic" AI or believe they make the best agent themselves anyway.
- Functionally there are no major differences between the [app](https://github.com/ceveyne/find-images-releases/releases) and the [find-image](https://lmstudio.ai/ceveyne/find-image)-plugin.
- But where the plugin lets you continue directly with results in LM Studio (e.g., using [analyse-image](https://lmstudio.ai/ceveyne/analyse-image) to detect objects, or [process-image](https://lmstudio.ai/ceveyne/process-image) / [draw-things-chat](https://lmstudio.ai/ceveyne/draw-things-chat) for edits), [Find Images.app](https://github.com/ceveyne/find-images-releases/releases) skips the agent layer and focuses on its core purpose: _finding images_.
- It is designed for browsing and organizing large image collections — or unearthing forgotten visual treasures from your own archives.
