# Changelog

Notable changes to this project will be documented in this file.

## Distribution

- **Search Engine Source Code:** [LM Studio Hub](https://lmstudio.ai/ceveyne/find-image)
- **Runtime Engine Source Code:** [GitHub Repository](https://github.com/ceveyne/qwen3-vl-embedding)

---

## [0.1.54-4] - 2026-08-17

### Changed

- Internal code restructuring.

### Fixed

- Fixed a gap where images found via Find Image could still slip back into the search index.

---

## [0.1.54-2] - 2026-08-12

### Changed

- Max Results now goes up to 64 and always caps results exactly, including project/filename searches.
- Raised Max Results default value from 6 to 8.
- Updated README to reflect these changes.

### Fixed

- Index Overview no longer counts RAW images in Total/Embedded/Skipped when RAW Images is disabled.

---

## [0.1.54-1] - 2026-08-12

> **Important Notice:** This version cannot be installed through the built-in updater. Please download and install it manually.

### Added

- Added an Index Overview with per-source embedding, skipped, and total counts.

### Changed

- Updated the built-in auto-updater.
- Enabled Image Formats now highlights formats with repeated indexing errors in yellow.
- Apple Photos albums now expand fully instead of scrolling in a fixed-height list.
- Max Results now goes up to 64 and always caps results exactly, including project/filename searches.
- Raised Max Results default value from 6 to 8.
- Updated README to reflect these changes.

### Fixed

- Runtime update buttons no longer show version numbers.

---

## [0.1.53-2] - 2026-08-10

### Fixed

- App updates no longer trigger search engine changes, and an existing current engine is recognized even when its settings files are missing.

---

## [0.1.53-1] - 2026-08-10

### Added

- Added a setting to control update checks at startup; search engine updates are now signaled through the toolbar Update button, just like app updates.
- New runtime engine v2026.08.10-b9951-376: Vision encoding for Qwen3-VL embedding and reranking now runs fully on the GPU on Apple Silicon; CPU fallback inside the image encoder was removed.
- Settings now shows which search engine version is installed, and update checks detect whether the runtime is an official release, a development build, or a custom one.

### Changed

- Very large images (for example, RAW photos) are now scaled down just enough to still be embeddable when `Use Previews for Image Retrieval` is turned off.

---

## [0.1.52-3] - 2026-08-07

### Added

- New "Enabled Image Formats" setting lets you choose which image formats the indexer processes. File watchers only monitor the selected formats. Native formats (PNG, JPG/JPEG, HEIC, BMP, GIF, HDR, PIC), other macOS formats (HEICS, HEIF, PICT, TIFF, WebP), and RAW formats (DNG, RAW) are enabled by default.
- Added a Privacy section to the README explaining that all search happens locally, with the update check and iCloud Photos exceptions.

### Changed

- Pressing Enter in the Help window's search field now jumps directly to the first match.
- The Help window's next and previous search buttons now highlight when multiple matches are available.

### Fixed

- Reference image previews now work for PSD, HEIC, RAW, and other macOS formats that require normalization. Previously they failed with an "unsupported image format" error.

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
