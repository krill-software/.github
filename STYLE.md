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

Fonts ship with [`@krill-software/desktop-ui`](https://github.com/krill-software/desktop-ui) — apps don't bundle their own webfonts or redeclare `@font-face`. The package's `fonts.css` (auto-imported via `import "@krill-software/desktop-ui/styles"`) loads two monos and `palette.css` defines these three CSS variables:

```css
:root {
  --fm-mono:  "JetBrains Mono", "Hasklig", "Source Code Pro", ui-monospace, monospace;
  --fm-sans:  ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif;
  --fm-serif: ui-serif, Georgia, "Source Serif 4", serif;
}
```

| Variable      | Family          | Bundled?               | Use                                                                       |
|---------------|-----------------|------------------------|---------------------------------------------------------------------------|
| `--fm-mono`   | JetBrains Mono  | Yes (4 woff2)          | All chrome (titlebar, menus, status line); default body in non-prose apps |
| `--fm-sans`   | system fallback | No — system-ui chain   | Apps that want a specific sans (Inter, etc.) link a webfont in their HTML and override locally |
| `--fm-serif`  | system fallback | No — ui-serif fallback | Apps that need a serif body link Source Serif 4 / Charter etc. locally    |

**Hasklig is also bundled.** It's available by name (`font-family: "Hasklig"`) for apps that want a calmer text-mono in long-form content (text-editor's editor body uses it). Don't introduce a fourth family or rename the variables.

Body chrome size: **12px**. Status line: **12px**. Titlebar filename: **12px**. Section headers: 11px uppercase, 0.08em letterspacing.

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
│  File Edit View …             photo.jpg •         —   □   ×      │  titlebar (44px)
├──────────────────────────────────────────────────────────────────┤
│              │                                                   │
│   AUX        │       MAIN                                        │
│   (left,     │       (right, primary work view)                  │
│   tools/nav) │                                                   │
│              │                                                   │
├──────────────────────────────────────────────────────────────────┤
│  v0.2.1                                Ln 6 · Col 36 · UTF-8     │  status line (34px)
└──────────────────────────────────────────────────────────────────┘
```

### Titlebar

- **44px tall**, with a **16px symmetric gutter** on each side. Children sit flush against the gutter — no extra container padding.
- Menus on the left (`File`, `Edit`, `Image`, `Filter`, `View`, `Go`, `Help` — only those with registered actions render). Each renders as a **22px-tall rounded box** (4px radius) with 8px internal padding that highlights on hover with `var(--fm-rule)`.
- Window controls (min / max / close) on the right, same 22px rounded-box shape with icon glyphs (no traffic-light dots — those were the v0.7 design and have been retired). The close button gets a soft-red hover; min / max use the same rule-alpha hover as menu triggers.
- **Filename centered on the *full* titlebar** via `position: absolute; left: 50%; transform: translate(-50%, -50%)`. Empty when no file is open. Font: `--fm-mono` at 12px, no letter-spacing tweak.
- **Dirty marker** is an accent `•` hanging to the *right* of the filename — rendered as a `::after` pseudo absolutely positioned `left: 100%; margin-left: 6px` so the title element's box stays exactly the filename and the centering math isn't nudged off. Driven by `body[data-dirty="true"]`; apps set the data attribute, the package owns the marker.
- **Text-edge alignment.** With the 16px gutter + 8px hover-box padding, all glyph text in the titlebar (menu labels, button icons) sits **24px from the window edge**.

### Help menu

Help is the canonical home for app metadata — krill has no macOS-style app menu, and a separate About *window* is the kind of surface the suite avoids. The menu carries exactly two things, in this order:

1. **A static version line** — the first item, non-interactive, muted: `<Product Name> <version>` (e.g. `Image Editor 0.2.1`). Not a link, not an "About…" dialog — just the fact, readable at a glance. The version is the `productName` + `package.json` version, supplied to `mountChrome()` so the package renders the line; apps don't build it themselves.
2. **`Check for updates…`** — the canonical updater action (see CLAUDE.md → In-app updater).

No "About", no credits screen, no license viewer, no "What's new". If a user needs the license it's in the repo.

### Body — main + optional aux

- **AUX (left, 260px fixed)**: tools, navigation, settings, output panels. Created by `mountChrome({ showAuxPane: true })`.
- **MAIN (right, flex)**: the primary work view — canvas, page reader, color wheel, editor.
- Apps without an aux pane (image-viewer, markdown-editor) collapse to a single column.
- rss-reader is a granted exception (3-pane: feeds / items / body inside main).

### Status line

- **34px tall**, with **20px symmetric padding**. `--fm-mono` at 12px, Artichoke text on Ghost White.
- **LEFT (`#status-info`)** — the app's **version**, formatted `vX.Y.Z` (e.g. `v0.2.1`). No product name; the titlebar already carries that. Static across the session; never changes after boot. Apps wire this via `chrome.statusInfo.textContent = \`v${__APP_VERSION__}\`` at mount (`__APP_VERSION__` defined through vite's `define` from `package.json#version`).
- **RIGHT (`#status-state`)** — live state. Position, mode, encoding (e.g. `Ln 6 · Col 36 · UTF-8`). Updates as the user works. Use plain ` · ` separators in a single span — the `.sep::before` pseudo-pattern combined with the flex `gap` doubles up.
- The status line is a **reporting** surface, not a control surface — nothing in it should be clickable. If a piece of state genuinely warrants action (e.g. "resolve merge conflict"), use a banner in the viewport or a menu item, not the status line.

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

**The tile.** A solid circle of Shimmering Blush (`#DD7596`, `--fm-accent`) filling the 1024px master edge-to-edge. No outer border, no drop shadow, no gradient. The circle is rendered supersampled (4×) so its edge is clean at every downscale. A row of krill apps in a launcher reads as a set of pink discs.

**The glyph.** A single [Lucide](https://lucide.dev) icon (MIT) that names the app's domain in one object — `image` for `image-viewer`, `crop` for `image-editor`, `rss` for `rss-reader`, `palette` for `color-editor`, `file-pen-line` for `markdown-editor`. Centered, occupying the inner **~56%** of the tile (≈576px on a 1024px master) so the pink ground has comfortable padding around the glyph. One object, not a scene.

**Color.** **The ground is always Shimmering Blush (`#DD7596` / `--fm-accent`)**, edge-to-edge, no exceptions. The Lucide stroke is recolored to Ghost White (`#FAFAFF` / `--fm-bg`). No fills, no gradients, no second hue — exactly two locked-palette colors per icon. This is what makes a launcher row of krill apps read as a set; treat the pink ground as as load-bearing as the productName itself.

**Stroke.** Lucide ships at 24×24 with `stroke-width: 2`. Scaled to 576px the stroke renders at ~48px, which reads at every required size including 32px. Don't thin the stroke for "elegance" at large sizes — the 32px launcher rendering is the honest test, and a hairline stroke disappears there.

**Picking the glyph.** Browse [lucide.dev/icons](https://lucide.dev/icons) and pick the one that names the app's job in a single noun. If you can't find one in Lucide, the app's purpose is probably broader than a krill app should be — narrow the purpose, not the search. Don't combine two Lucide icons into a composite; don't draw a custom glyph "in Lucide style." One icon, as Lucide drew it.

**Sizes & files.** Master is `src-tauri/icons/icon.png` at 1024×1024. Tauri's other required sizes (`32x32.png`, `128x128.png`, `128x128@2x.png`) are downscaled from it. The render pipeline lives in [scripts/render-icons.py](scripts/render-icons.py) (in this `.github` repo) — edit the `APPS` map at the top to add a new app or change a glyph, then run it with the `krill-software/` parent directory as the argument: `python3 scripts/render-icons.py ~/dev/krill-software`. It writes each app's `src-tauri/icons/` in place. Requires Python with Pillow and ImageMagick's `convert` on PATH.

### Fallback when no Lucide icon fits

If a new app genuinely has no matching Lucide glyph (rare — push back on the app's scope first), ship a typographic placeholder in the same pink circle so the launcher row still feels right. Don't ship the default Tauri icon, and don't borrow another app's glyph.

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
- **Layout:** `[menu bar] [drag region] [min] [max] [close]`. 44px tall, 16px gutter on each side.
- **Min / max / close** as 22×22 rounded-box icon buttons, muted glyph color, hover paints `var(--fm-rule)` and lifts color to ink. Close hover paints a soft red instead. The menu triggers above match this shape exactly.
- **Drag region** double-click toggles maximize.
- **Status line** 34px tall at the bottom: `vX.Y.Z` on the left (static, from `package.json`), live position/mode state on the right (`Ln · Col · UTF-8`, page count, etc.). 20px padding on each side. Always visible; never hidden in non-preview modes.

### Window dimensions

Every app opens at the same default size so a launcher full of krill windows feels like one product family, not a dozen disagreements:

| Setting   | Value         | Rationale                                                                |
|-----------|---------------|--------------------------------------------------------------------------|
| Default   | `1296 × 800`  | Golden ratio (1.62 ≈ φ). Fits on the smallest common laptop after dock + menus. |
| Minimum   | `720 × 445`   | Same ratio, halved. Users can resize freely below the default; this is the floor. |
| Position  | `center: true`| First-launch only. After that, persisted window geometry from `state.json` wins. |

Put these in every app's `tauri.conf.json` under `app.windows[0]`. Apps with a strong reason to deviate (image-editor wanting more vertical room for a tall canvas, etc.) can override — but the deviation should land in the app's SPEC.md so it's a deliberate choice, not drift.

## UX patterns

- **One window per document.** Opening a second file launches a second process.
- **Title format:** `{filename}{ • if dirty} — {productName}`.
- **No popups during normal work.** Save-As, Open, Export are the only modal dialogs.
- **No nested settings dialogs.** Options live in the working view, next to the canvas / editor — see image-editor's right rail.
- **Standard shortcuts** match Win/Mac conventions and must not be reassigned: `Ctrl+O` open, `Ctrl+S` save, `Ctrl+Shift+S` save-as, `Ctrl+N` new, `Ctrl+Z` / `Ctrl+Shift+Z` undo/redo, `Ctrl+Q` quit, `Ctrl+=` / `Ctrl+-` / `Ctrl+0` zoom (or font size).
- **Drag-drop opens files.** CLI-arg also opens.
- **Dirty marker** is a Shimmering Blush bullet (`•`) hanging to the right of the filename in the title bar (see the Titlebar section for the implementation detail). The status line does not duplicate it.

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
