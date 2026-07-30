# Find Images.app

> **Standalone desktop application for local image search**
>
> Find Images.app is the standalone version of the [find-image](https://lmstudio.ai/ceveyne/find-image) LM Studio plugin. It gives you the same multimodal search engine — visual, text-based, and metadata-driven — without requiring LM Studio or an AI agent.

The app is for people who either are not fans of "agentic" AI or believe they make the best agent themselves. Functionally there are no major differences between the app and the plugin. But where the plugin lets you continue directly with results in LM Studio (e.g., using **[analyse-image](https://lmstudio.ai/ceveyne/analyse-image)** to detect objects, or **[process-image](https://lmstudio.ai/ceveyne/process-image)** / **[draw-things-chat](https://lmstudio.ai/ceveyne/draw-things-chat)** for edits), **Find Images.app** skips the agent layer and focuses on its core purpose: _finding images_.

It is designed for browsing and organizing large image collections — or unearthing forgotten visual treasures from your own archives.

## Contents

- [What It Does](#what-it-does)
  - [Search Sources](#search-sources)
- [Setup](#setup)
- [Using Find Images.app](#using-find-imagesapp)
  - [Interface Layout](#interface-layout)
  - [Searching](#searching)
  - [Result Views](#result-views)
  - [Result Details](#result-details)
  - [Structured Filters from Details](#structured-filters-from-details)
  - [Tag Management](#tag-management)
  - [Projects and Queries](#projects-and-queries)
- [Settings](#settings)
  - [General](#general)
  - [Search](#search)
  - [Indexing](#indexing)
- [Use cases](#use-cases)
- [Behind the Scenes: Fusion Embedding](#behind-the-scenes-fusion-embedding)
- [Comparing App vs Plugin](#comparing-app-vs-plugin)
- [Persistent Data](#persistent-data)
- [Staying Up to Date](#staying-up-to-date)
- [License](#license)

## What It Does

**Find Images.app** searches local image stores using a combination of metadata search and multimodal embedding search powered by [Qwen3-VL-Embedding](https://github.com/QwenLM/Qwen3-VL-Embedding).

The search is **multimodal**. This means: results are not only found because they carry matching tags or contain parts of your query in their metadata. Search also works purely visually. Natural language descriptions find images, reference images find similar images, tags find images, filenames find images — and you can combine all of these signals. You can use metadata to search, apply hard filters on structured fields, and much more.

Although both the app and its plugin sibling originated in [Draw Things](https://drawthings.ai/) projects (.sqlite3, PNG), analog photos (JPEG) now receive the same attention through EXIF metadata support as AI-generated images do.

### Search Sources

The local index can include:

- **Image directories** — any folders you add containing image files
- **Draw Things generations** created by draw-things-chat or process-image
- **Saved Draw Things / ComfyUI images** with PNG metadata
- **LM Studio chat attachments** with metadata sidecars (optional)
- **Images from LM Studio working directories** (optional)
- **Draw Things project files** with generation history and thumbnails
- **Plain saved images** without any metadata

The multimodal index accepts PNG, JPG/JPEG, TGA, BMP, PSD, GIF, HDR, PIC, PPM, and PGM.
⚠️ WebP, TIFF/TIF, HEIC, and HEIF are _not_ supported.

## Setup

First launch triggers a guided onboarding wizard:

1. **Check** — the app inspects whether a search engine binary and embedding model are already installed
2. **Search engine** — point to (or download) the llama-server runtime binary
3. **Embedding model** — select or download a Qwen3-VL-Embedding GGUF model
4. **Verify** — downloaded files are integrity-checked
5. **Folders** — choose which image directories to index
6. **Index** — the app builds the local search index

💡 The app's onboarding wizard will download the model for you by default to an appropriate location.

![onboarding-welcome](docs/images/onboarding-welcome.jpeg)

![onboarding-everything-is-ready](docs/images/onboarding-everything-is-ready.jpeg)

> ⚠️ Do **not** place Qwen3-VL-Embedding models in `~/.lmstudio/models`. LM Studio does not support them yet and may interfere with regular Qwen3-VL models.

After onboarding, you can change all settings in-app at any time.

## Using Find Images.app

### Interface Layout

The app has a three-panel layout:

- **Left sidebar** — projects and saved queries, organized hierarchically with drag-and-drop reordering
- **Center** — search bar (with optional reference image) and results in tiles, list, or table view
- **Right sidebar** — result details panel or settings

![text-query-analogue-photography](docs/images/text-query-analogue-photography.jpeg)

All panels are resizable. Layout state is persisted between sessions.

### Searching

The search bar accepts:

- **Text queries** — natural language descriptions like `golden retriever on a beach at sunset`
- **Reference images** — drag and drop an image, or use the file picker button, to find visually similar results
- **Structured filters** — hard AND filters using syntax like `Model: flux_2`, `Size: 1024x1024`, `Origin: draw-things-chat`, `Timestamp: 2026-07`

Two toggle options modify how reference images are used:

| Option               | Effect                                                                                    |
| -------------------- | ----------------------------------------------------------------------------------------- |
| **Include metadata** | Adds the reference image's generation metadata as a ranking signal across the full corpus |
| **Ignore image**     | Uses only prompt/metadata similarity, deliberately omitting visual pixels from the search |

![reference-image-query-settings](docs/images/reference-image-query-settings.jpeg)

![reference-image-query-include-metadata](docs/images/reference-image-query-include-metadata.jpeg)

![reference-image-query-include-metadata-ignore-image](docs/images/reference-image-query-include-metadata-ignore-image.jpeg)

### Result Views

Three view modes let you navigate results differently:

- **Preview size** — adjustable thumbnail dimensions in the result grid
- **Tiles** — grid of image previews with score badges and source indicators
- **List** — compact vertical list showing filename, prompt snippet, model, and date
- **Table** — sortable columns for size, model, origin, created date, match type, and score
- **Open preview** - Navigate through query results by opening a large preview by <space>, using arrow keys to browse the results.

![reference-image-query-include-metadata-open-preview](docs/images/reference-image-query-include-metadata-open-preview.jpeg)

### Result Details

Click any result to open the detail panel on the right. It shows:

- An image preview
- Prompt / generation parameters (size, model, LoRAs, match score, source, origin)
- EXIF camera metadata (lens, exposure, aperture, ISO, focal length, GPS, etc.)
- Existing Tags and tools to manage them and/or apply them to a query
- "Use as reference", "Open preview", "Reveal in Finder", and "Copy prompt" actions

### Structured Filters from Details

Any structured field in the detail panel can be dragged into the search bar as a "hard" filter. For example, dragging the `Model` value creates a `Model: flux_2_klein_9b_q8p.ckpt` clause that restricts results to images taken with that model.

![structured-filter-use-as-reference](docs/images/structured-filter-use-as-reference.jpeg)

### Tag Management

Images can be tagged for organization:

- **Add / remove tags** from individual results via the detail panel
- **Drag tag sets** between results to copy tags across multiple images
- **Filter by tags** using `Tags: illustration, 2d` syntax in the query bar
- Tags persist in the index until explicitly removed
  ⚠️ A single tag cannot contain spaces

![query-by-tag](docs/images/query-by-tag.jpeg)

### Projects and Queries

Queries are organized into projects. Each project holds a list of saved searches with their full context (query text, reference image, filters, settings). You can:

- Create, rename, move, and delete projects
- Create, rename, move, and delete queries
- Transfer queries between projects (copy or move)
- Reorder projects and queries via drag-and-drop

## Settings

General Settings are accessible from the left sidebar. They mirror the plugin's configuration options.
Search-based Settings are accessible from the right sidebar. They are stored individually with every query.
The settings are mostly self-explanatory. Here are a few highlights:

### General

- **Embedding model path** — location of the GGUF model
- **Runtime engine path** — location of the llama-server binary
- This is the place to manage your **Image directories** — folders to scan and index.
- `Search Working Directories` adds LM Studio Chat Working Directories as a search source. This is especially useful if these contain generated images from tools like **[draw-things-chat](https://lmstudio.ai/ceveyne/draw-things-chat)**.
- As a Draw **Things User** you may want to enable `Search Draw Things Projects`.
- **Projects Directory** allows you to change the default directory containing Draw Things project files.

![general-settings](docs/images/general-settings.jpeg)

💡 To add more directories containing Draw Things project files, simply add them as **Image directories**.

### Search

- **Allow byte-identical duplicates** — show all matching files including exact copies
- **Max results** — how many results to display per query (25 = all)

💡 All settings in this section are saved per query. `New query` resets all these to the default values. To store and re-use your personal default settings, simply copy or rename your favourite queries in your project and click on it to restore all its settings instead of clicking `New query`.

![query-settings](docs/images/query-settings.jpeg)

### Indexing

Indexing is started and stopped on demand.

- **Refresh index** — starts indexing.
- **Stop indexing** — stops indexing.

> 💡 Text metadata indexes in milliseconds; image embeddings take seconds per image depending on model size and GPU. Start small with a test folder before indexing large collections.

By default, `Use Previews for Image Retrieval` is `active` in General Settings. This setting increases embedding speed noticeably, but may affect retrieval precision.

## Behind the Scenes: Fusion Embedding

What makes Find Images.app different from a plain filename or prompt search is its use of **multimodal fusion embeddings**.

When an image is indexed, both its visual content (pixels) and its metadata (prompt, model, EXIF data) are combined into a single embedding vector — a point in a high-dimensional space. Similar images cluster together. When you search, your query (text, reference image, or both) becomes another point, and the app finds the nearest neighbors using cosine similarity.

This means:

- An image of a cat found by text description sits near other cat images, even if their prompts say nothing about cats
- A reference photo of a sunset ranks warm-toned landscapes first, regardless of how they were created
- Generation metadata and visual content reinforce each other when both are available

> **Score ≠ Quality. Score = Embedding Coverage.**
>
> A lower score does not necessarily mean worse results. Different search signals change what ranks first; structured filters determine which candidates are eligible at all.

<a id="use-cases"></a>

## Use Cases

The **Find Images.app** queries allow you to combine multiple criteria:

- an attached reference image or absolute image path; use it for "like this image", style references, or changes to a shown image
- text query: with an attached reference image, positively describe additions or changes; without an attached reference image, write a complete description. `Model:`, `LoRAs:`, `Size:`, `Source:`, `Origin:`, and `Timestamp:` are hard AND filters.
- `Include metadata`: add reference image generation metadata as a ranking signal across the full corpus, not an identical-metadata filter
- `Ignore image`: ignore reference image pixels; use only for prompt or metadata similarity without visual similarity

Use one, two, three, or all four criteria in each search, depending on what you want to find or achieve.

| Goal                                                          | Recommended Criteria                                                            | Why?                                                                                                                    |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **"Find visually similar images"**                            | `reference image`                                                               | The reference image ranks the complete corpus by visual similarity.                                                     |
| **"Same style, but different subject or scene"**              | `reference image + text query`                                                  | Keep the reference as the visual anchor; positively describe the change, for example `people in front of a brick wall`. |
| **"More from this creative direction"**                       | `reference image + Include metadata`                                            | Image pixels and target metadata jointly rank the complete corpus by visual and generation-context similarity.          |
| **"Reference style plus a specific new concept"**             | `reference image + query + Include metadata`                                    | Combines visual reference, requested changes, and target metadata as ranking signals.                                   |
| **"Thematic search without a reference image"**               | `text query`                                                                    | Uses a complete descriptive text query across the full collection.                                                      |
| **"Require specific generation metadata"**                    | `query` with `Model:`, `LoRAs:`, `Size:`, `Source:`, `Origin:`, or `Timestamp:` | These hard AND filters limit candidates before retrieval and reranking.                                                 |
| **"Prompt or metadata similarity without visual similarity"** | `reference image + Include metadata + Ignore image`                             | Uses reference metadata as a text-based similarity signal while deliberately omitting image pixels.                     |

The `Tags` section allows you to manage persistent tags for indexed images:

- You can list all existing tags by clicking into the `Add tag` field, add, or remove one or more tags for indexed images shown within the current query.
- Tags persist for indexed images until removed. They can be used with your query as a distinct filter to help you organize your image collection.

## Comparing App vs Plugin

| Feature                                   | Find Images.app | find-image (plugin) |
| ----------------------------------------- | --------------- | ------------------- |
| Multimodal visual search                  | ✅              | ✅                  |
| Text-based queries                        | ✅              | ✅                  |
| Metadata / EXIF filters                   | ✅              | ✅                  |
| Reference image search                    | ✅              | ✅                  |
| Tag management                            | ✅              | ✅                  |
| Project organization                      | ✅              | ✅                  |
| Standalone (no LM Studio)                 | ✅              | ❌                  |
| Continue with results in chat             | ❌              | ✅                  |
| analyse-image / process-image integration | ❌              | ✅                  |

**Use the plugin** if you want to find images and then immediately work with them in LM Studio — analyze, edit, generate variations.

**Use Find Images.app** if you want a dedicated search tool for browsing, organizing, and discovering images without any agent layer.

![reference-image-query-details](docs/images/reference-image-query-details.jpeg)

## Persistent Data

```
~/.find-images/data/generation_index_cache.json         # Generation metadata index
~/.find-images/data/multimodal_embeddings.sqlite3       # Multimodal embedding vectors
~/.find-images/.internal/global-plugin-configs.json     # General settings
```

These files survive app updates.

## Staying Up to Date

Download new releases from the [releases page](https://github.com/ceveyne/find-images-releases/releases). Your settings and embeddings persist across versions.

💡 Watch this repository on GitHub to get notified about updates. 👀

## License

Find Images.app is free to use for personal and commercial purposes. It is distributed as a compiled application (DMG bundle).

The underlying search engine, `find-image`, remains available as open source under the [MIT License](https://opensource.org/licenses/MIT). The integrated llama-server runtime engine is also included under its respective terms.
