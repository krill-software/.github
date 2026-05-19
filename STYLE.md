# krill — Style guide

Engineering and visual conventions every krill app shares. If you find yourself making one of these decisions per-app, it should probably be here instead.

This document is binding for v1 apps unless explicitly noted.

## Stack

- **Shell:** Tauri 2 (Rust backend + system webview).
- **Frontend:** TypeScript + Vite, no framework.
- **Package manager:** pnpm.
- **Rust:** 1.77+.

If a future app genuinely needs a different stack, document why in its `SPEC.md`.

## Naming

The **slug is the directory name** under `krill-software/`. Pick the directory and everything else is derived. No abbreviations, no per-app debates.

For an app whose directory is `{slug}` (e.g. `markdown-editor`, `image-editor`, `color-editor`, `rss-reader`):

| Where                | Pattern                                | Example (`image-editor`)                                        |
|----------------------|----------------------------------------|-----------------------------------------------------------------|
| Binary               | `krill-{slug}`                        | `krill-image-editor`                                           |
| Cargo package name   | `krill-{slug}`                        | `krill-image-editor`                                           |
| Cargo lib name       | `krill_{slug_with_underscores}_lib`   | `krill_image_editor_lib`                                       |
| `package.json` name  | `krill-{slug}`                        | `krill-image-editor`                                           |
| Bundle identifier    | `software.krill.{slug}`                    | `software.krill.image-editor`                                       |
| State dir            | `$XDG_STATE_HOME/krill-{slug}/`       | `$XDG_STATE_HOME/krill-image-editor/`                          |
| User-Agent (network apps) | `krill-{slug}/<version> (+<repo url>)` | `krill-rss-reader/0.1.0 (+https://github.com/krill-software/rss-reader)` |
| GitHub repo          | `krill-software/{slug}`                        | `krill-software/image-editor`                                           |

The **productName** (window title, bundle metadata) is the slug rendered as Title Case, replacing hyphens with spaces. Acronyms stay uppercase:

| Slug             | productName       |
|------------------|-------------------|
| `markdown-editor`| `Markdown Editor` |
| `image-editor`   | `Image Editor`    |
| `color-editor`   | `Color Editor`    |
| `rss-reader`     | `RSS Reader`      |

This is the only place where capitalization differs from the slug. Don't second-guess it later.

## Palette

Single locked palette in five named colors. **System-following dark mode** (only): the background and ink invert into the Space-Cadet hue family, the two pinks stay put. **No in-app toggle, no theme picker, no user themes.** The webview follows `prefers-color-scheme` automatically.

| Role             | Hex       | Usage                                                       |
|------------------|-----------|-------------------------------------------------------------|
| Ghost White      | `#FAFAFF` | Background                                                  |
| Space Cadet      | `#30343F` | Body text, primary ink                                      |
| Artichoke        | `#878472` | Muted text, status line, secondary labels                   |
| Shimmering Blush | `#DD7596` | Accent — cursor, selection, dirty marker, focus borders     |
| Brilliant Rose   | `#FF82BF` | Strong accent — hover state, primary CTAs                   |

CSS variable names every app uses, exposed via [`@krill-software/desktop-ui`](https://github.com/krill-software/desktop-ui) — apps don't redeclare these locally; they `import "@krill-software/desktop-ui/styles"` and inherit:

```css
:root {
  --fm-bg: #FAFAFF;
  --fm-text: #30343F;
  --fm-muted: #878472;
  --fm-accent: #DD7596;
  --fm-accent-strong: #FF82BF;
  --fm-rule: rgba(48, 52, 63, 0.08);
  --fm-rule-strong: rgba(48, 52, 63, 0.16);
}
```

The app's local `styles.css` should only carry app-specific tokens (font-family stacks, layout dimensions like `--rail-w`). Redeclaring the palette tokens locally is a smell — it means the app drifted from the package, not that the package is wrong.

## Typography

Every krill app bundles the same three webfonts so the look is identical across machines. They live in `src/assets/fonts/` (woff2 only) with the licenses next to them, and each app's `styles.css` opens with the `@font-face` block plus these three CSS variables:

```css
:root {
  --fm-sans:  "Inter",   ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
  --fm-serif: "Charter", Georgia, "Liberation Serif", serif;
  --fm-mono:  "Hasklig", "Source Code Pro", "JetBrains Mono", ui-monospace, monospace;
}
```

| Variable      | Family    | Weights bundled    | Use                                                           |
|---------------|-----------|--------------------|---------------------------------------------------------------|
| `--fm-sans`   | Inter     | 400, 600, 700      | UI chrome (titlebar, lists, buttons, status line); body text in non-prose apps |
| `--fm-serif`  | Charter   | 400/700, italic+bold-italic | Long-form prose (markdown preview, rss article body) |
| `--fm-mono`   | Hasklig   | 400/700, italic+bold-italic | Code, hex values, dates, numeric labels, file paths   |

The fonts in `markdown-editor/src/assets/fonts/` are the source of truth — copy from there when scaffolding a new app. Don't introduce a fourth family or rename the variables.

Body chrome size: 13px. Status line: 11px. Section headers: 11px uppercase, 0.08em letterspacing.

### Always pick whole-pixel font sizes

Use integer pixel sizes — `11px`, `13px`, `14px` — never `10.5px` or `12.5px`. Half-pixel sizes force WebKit on Linux into subpixel hinting, which produces visibly fuzzy / grainy text edges, especially on light backgrounds. The fix is whole pixels, not more font-smoothing CSS.

Also include these four declarations on `html, body` so text renders the same way across apps:

```css
html, body {
  font-family: var(--fm-sans);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  font-feature-settings: "calt" 1, "liga" 1;
  text-rendering: optimizeLegibility;
}
```

If text looks "off" but no obvious bug stands out — check for `.5px` sizes and the smoothing block first.

## Body layout (opinionated, all apps)

Every krill app uses the same 3-row body shape. The package
[`@krill-software/desktop-ui`](https://github.com/krill-software/desktop-ui) builds it for you via `mountChrome()` — apps don't recreate it.

```
┌──────────────────────────────────────────────────────────────────┐
│ [☰] File Edit View …       •photo.jpg        [_] [□] [✕]         │  titlebar (32px)
├──────────────────────────────────────────────────────────────────┤
│              │                                                   │
│   AUX        │       MAIN                                        │
│   (left,     │       (right, primary work view)                  │
│   tools/nav) │                                                   │
│              │                                                   │
├──────────────────────────────────────────────────────────────────┤
│ status-info (file identity)         status-state (position/mode) │  status line (24px)
└──────────────────────────────────────────────────────────────────┘
```

### Titlebar

- Menus on the left (`File`, `Edit`, `Image`, `Filter`, `View`, `Go`, `Help` — only those with registered actions render).
- **Filename centered on the *full* titlebar** (not on the middle flex slot — `position: absolute` on `#titlebar`). Empty when no file is open.
- Dirty marker is a `•` accent prefix on the filename, driven by `body[data-dirty="true"]`. Apps set the body data attribute; the package owns the prefix CSS.
- Window controls (min / max / close) on the right.

### Body — main + optional aux

- **AUX (left, 260px fixed)**: tools, navigation, settings, output panels. Created by `mountChrome({ showAuxPane: true })`.
- **MAIN (right, flex)**: the primary work view — canvas, page reader, color wheel, editor.
- Apps without an aux pane (image-viewer, markdown-editor) collapse to a single column.
- rss-reader is a granted exception (3-pane: feeds / items / body inside main).

### Status line

- **LEFT (`#status-info`)** — file identity. Type, size, structural dimensions. Doesn't change as the user works.
- **RIGHT (`#status-state`)** — position / state. Page X/Y, word count, zoom %, mode. Changes constantly.
- Pixel size is *file identity* (left). Word count and page position are *state* (right) — they're different categories.

### Empty + error placeholders

When no file is open, every file-app shows a centered "drop a file here, or press `Ctrl+O`" hint. Identical styling across apps — built via `buildEmptyState({ primary, hint })` from desktop-ui:

```ts
import { buildEmptyState, buildErrorState } from "@krill-software/desktop-ui";

const empty = buildEmptyState({
  primary: "No document open.",
  hint: 'Drop a PDF here, or press <kbd>Ctrl</kbd>+<kbd>O</kbd>.',
});
chrome.viewport.appendChild(empty);

const error = buildErrorState({ primary: "Can't open this PDF." });
chrome.viewport.appendChild(error.element);
// later: error.setFilename("broken.pdf");
```

The placeholder is positioned `absolute` over the working viewport, centered both axes, in `--fm-muted` text. App copy varies (PDF vs image vs document) but the shape is fixed.

### Fullscreen

Hides everything except `#viewport` (and any sub-panes inside it that aren't separately hidden). Driven by `body[data-fullscreen="true"]` — package-owned CSS.

## Iconography

Every app ships a single icon in the same shape language so a row of krill apps in a launcher reads as a set, not as five unrelated installs.

**The tile.** iOS-style squircle (rounded square, ~22% corner radius on a 1024px master). Solid Ghost White (`#FAFAFF`) ground — the same color as the app background, so the icon feels continuous with the window it opens. No outer border, no drop shadow, no gradient on the tile itself.

**The glyph.** A single [Lucide](https://lucide.dev) icon (MIT) that names the app's domain in one object — `image` for `image-viewer`, `crop` for `image-editor`, `rss` for `rss-reader`, `palette` for `color-editor`, `file-pen-line` for `markdown-editor`. Centered, occupying the inner ~70% of the tile (≈720px on a 1024px master). One object, not a scene.

**Color.** Lucide stroke recolored to Space Cadet (`#30343F`). No fills, no gradients, no second hue. The window chrome and the icon share one ink color — a krill app is monochrome from the launcher tile inward. The locked palette stays locked everywhere.

**Stroke.** Lucide ships at 24×24 with `stroke-width: 2`. Scaled to 720px the stroke renders at ~60px, which reads at every required size including 32px. Don't thin the stroke for "elegance" at large sizes — the 32px launcher rendering is the honest test, and a hairline stroke disappears there.

**Picking the glyph.** Browse [lucide.dev/icons](https://lucide.dev/icons) and pick the one that names the app's job in a single noun. If you can't find one in Lucide, the app's purpose is probably broader than a krill app should be — narrow the purpose, not the search. Don't combine two Lucide icons into a composite; don't draw a custom glyph "in Lucide style." One icon, as Lucide drew it.

**Sizes & files.** Master is `src-tauri/icons/icon.png` at 1024×1024. Tauri's other required sizes (`32x32.png`, `128x128.png`, `128x128@2x.png`) are downscaled from it. The render pipeline lives in [scripts/render-icons.py](scripts/render-icons.py) at the repo root — edit the `APPS` map at the top to add a new app or change a glyph, then run `python3 scripts/render-icons.py .` from the repo root.

### Fallback when no Lucide icon fits

If a new app genuinely has no matching Lucide glyph (rare — push back on the app's scope first), ship a typographic placeholder in the same tile so the launcher row still feels right. Don't ship the default Tauri icon, and don't borrow another app's glyph.

```
+--------------+
|              |
|    IMAGE     |
|    VIEWER    |
|              |
+--------------+
```

- Same Ghost White squircle tile.
- The productName, split into one word per line, centered, all-caps.
- `--fm-sans` at heavy weight (700), Space Cadet ink. Letterspacing `0.04em`.
- Type sized so two lines comfortably fill the inner ~70% — for a 1024px tile, around 180–200px cap height per line.
- Single-word productNames (rare) sit on one line. Three-word names are a sign the productName is wrong; fix the name, not the icon.

The fallback is meant to be replaced. Treat it like a TODO that's visible every time the user opens their launcher.

## Window chrome

- **Custom titlebar.** Native window decorations off (`"decorations": false` in `tauri.conf.json`).
- **Layout:** `[menu bar] [drag region] [min] [max] [close]`. 32px tall.
- **Min / max / close** as 36×32 SVG buttons, muted color, hover lifts to ink color, close hover goes accent.
- **Drag region** double-click toggles maximize.
- **Status line** 22–24px tall at the bottom: filename · dirty marker · one or two app-specific values (word count, dimensions, slot mode). Always visible; never hidden in non-preview modes.

## UX patterns

- **One window per document.** Opening a second file launches a second process.
- **Title format:** `{filename}{ • if dirty} — {productName}`.
- **No popups during normal work.** Save-As, Open, Export are the only modal dialogs.
- **No nested settings dialogs.** Options live in the working view, next to the canvas / editor — see image-editor's right rail.
- **Standard shortcuts** match Win/Mac conventions and must not be reassigned: `Ctrl+O` open, `Ctrl+S` save, `Ctrl+Shift+S` save-as, `Ctrl+N` new, `Ctrl+Z` / `Ctrl+Shift+Z` undo/redo, `Ctrl+Q` quit, `Ctrl+=` / `Ctrl+-` / `Ctrl+0` zoom (or font size).
- **Drag-drop opens files.** CLI-arg also opens.
- **Dirty marker** is a Shimmering Blush bullet (`•`) next to the filename in title bar and status line.

## Discoverability

A krill app is **discoverable for the task at hand**:

- A *manipulation* app (image, palette) surfaces its controls in the working view — sliders, buttons, mode toggles right next to the canvas.
- A *quiet* app (writing, reading) keeps the canvas calm. Controls live in the menu bar; the keyboard is enough.

Neither kind hides essential actions behind keyboard chords with no visible counterpart.

## Persistence

Persist only what's truly invisible:

- Window geometry — `$XDG_STATE_HOME/krill-{slug}/state.json`.
- Recent files list.
- Font size if the app has one.

No "Preferences" panel in v1. If you find yourself adding settings, ask whether they should be hard-coded defaults instead. The bar for "needs to be configurable" is high.

## Shipping

- **Architecture:** Linux x86_64. (No aarch64 in v1.)
- **Bundles:** AppImage primary, `.deb` secondary. No Flatpak, no Snap, no PPAs.
- **Distribution:** GitHub Releases. No other channels.
- **Versioning:** SemVer. Three files must agree on every bump: `package.json`, `src-tauri/Cargo.toml`, `src-tauri/tauri.conf.json`.
- **License:** MIT.

## Anti-patterns — never do these

- **System-following dark mode, no toggle.** The webview follows `prefers-color-scheme`. The five named colors stay the same; only the background, ink, and rule tokens flip. Never introduce an in-app theme switcher — that's the kind of settings-panel surface krill rejects.
- **No plugins, themes, or skins.**
- **No multi-window** for a single document.
- **No accounts, sign-in, or cloud sync.**
- **No telemetry, analytics, or crash reporters.** Of any kind.
- **No Windows or macOS port.** No conditionals for them either.
- **No nested settings dialogs.**
- **No invented metaphors** when a familiar Win/Mac one exists.
- **No "advanced mode"** toggles. If the feature is too complex for the default view, the feature is too complex for krill.
