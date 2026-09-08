# Working in krill-software

This directory is a collection of small native Linux apps under the **krill** umbrella. Each app is its own crate / project (`markdown-editor`, `image-editor`, `color-editor`).

Before scaffolding a new app or making non-trivial changes to an existing one, read:

- [PHILOSOPHY.md](PHILOSOPHY.md) — what krill apps are and aren't. Read first.
- [STYLE.md](STYLE.md) — engineering and visual conventions every app shares.
- [WEB-STYLE.md](WEB-STYLE.md) — design language for landing pages + the org site.

The most complete reference template is [pdf-reader](https://github.com/krill-software/pdf-reader) — Tauri shell, custom titlebar via [`@krill-software/desktop-ui`](https://github.com/krill-software/desktop-ui), palette wired up via the same package, reusable release workflow from [krill-software/.github](https://github.com/krill-software/.github), publish script, all in place. When in doubt, copy from there.

Three shared repos that every app depends on:

- **[`@krill-software/desktop-ui`](https://github.com/krill-software/desktop-ui)** (npm-style git dep, pinned to a tag) — TypeScript: palette CSS bundle, `mountChrome()` (titlebar / menu / status line / aux pane), `buildEmptyState()` / `buildErrorState()` / `showBootError()` helpers, canonical action registry. Apps import this and don't redeclare any of the chrome locally.
- **[`krill-desktop-core`](https://github.com/krill-software/desktop-core)** (Cargo git dep, pinned to a tag) — Rust: `state` module (XDG dir / load+save JSON / `WindowGeometry`), `fs` module (`read_bytes` / `absolute_path` / `format_io_err`), `dev` module (`test_file`). Each app's `src-tauri/src/lib.rs` declares the Tauri commands (the macro needs concrete symbols) but their bodies are one-liners delegating here.
- **[krill-software/.github](https://github.com/krill-software/.github)** — reusable `krill-app-release.yml` workflow. Each app's local `.github/workflows/release.yml` is a 13-line caller that hands off to it.

This file is the always-loaded guardrail layer: the rules that apply to *every*
session. Task-specific procedures live in the guides below — **read the matching
guide before you start that task.**

## Guides — read the matching file before the task

- **Creating a new app** — framing, scaffolding, what to ask, no-copy-paste → [docs/new-app.md](docs/new-app.md)
- **Sharing code or UI between apps** → [docs/shared-code.md](docs/shared-code.md)
- **Wiring the in-app updater** → [docs/updater.md](docs/updater.md)
- **Releasing a version** → [docs/release.md](docs/release.md)
- **Status line convention** → [STYLE.md](STYLE.md) → Status line
- **App landing page** (`docs/index.html`) → [WEB-STYLE.md](WEB-STYLE.md)

## Proof-of-concept apps (not ready for publish)

These apps live in the krill-software directory but are still
proof-of-concept — they should **not** be released, included on the
org site, or pointed at from documentation as exemplars:

- `launcher`
- `photo-importer`
- `screenshots`
- `svg-editor`
- `terminal`
- `video-player`

When asked to "release all apps" or "update every krill app", **skip
this list**. They may have working scaffolding and even some
implemented features, but they haven't passed the design / scope bar
to be part of the shipped suite yet. If the user explicitly names
one, work on it — just don't release it until they confirm it's
graduated. When one does graduate, remove it from this list.

## Binding without checking

Treat these as decided. Don't relitigate them per app.

- The locked palette and CSS variable names (see STYLE.md). Provided by `@krill-software/desktop-ui` — apps don't redeclare these locally.
- Custom titlebar with light/dark toggle + min / max / close + inline menu bar; native decorations off. Built by `mountChrome()` from the desktop-ui package.
- Rust-side state I/O (XDG state dir, JSON load/save, `WindowGeometry`, dev test-file probe, path canonicalization, IO error formatting). Provided by `krill-desktop-core` — apps don't reimplement any of it.
- Tauri 2 + TypeScript + Vite + pnpm + Rust 1.77+.
- Linux x86_64 only. AppImage + `.deb`. No Flatpak, no Snap, no Windows / macOS code paths.
- MIT license.
- One window per document.
- No telemetry, no accounts, no plugins, no settings panel in v1.
- Dark mode: a titlebar light/dark toggle built into `mountChrome()`. It defaults to system-following via `prefers-color-scheme` and persists a per-app manual override (localStorage). The locked palette inverts background and ink only — the toggle switches between those two locked modes, nothing more. No theme picker, no user palettes.
- **Naming.** Slug = directory name under `krill-software/`. Binary, identifier, lib name, state dir, repo, and productName all derive from it. See [STYLE.md](STYLE.md) → Naming. Don't ask the user for any of these — only ask for the directory name (which is the new-app input).
- **App icon.** A single Lucide glyph in Ghost White on a Shimmering Blush (`#DD7596` / `--fm-accent`) circular ground, edge-to-edge — every app, no exceptions. Generated by `scripts/render-icons.py`; the `APPS` map at the top of that script is the source of truth. See [STYLE.md](STYLE.md) → Iconography. Never ship the default Tauri icon, never use a different ground color, never composite two glyphs.
- **Window dimensions.** Every app opens at the same default — **1296 × 800** (golden ratio) with min **720 × 445** and `center: true`. Put these in every app's `tauri.conf.json` under `app.windows[0]`. Users can resize freely; this is just the first-launch default so a launcher full of krill windows feels like one product family. Deviations need a SPEC.md justification. See [STYLE.md](STYLE.md) → Window dimensions.

## Start with the simplest viable solution

Solve the literal request with the smallest thing that works. Don't
add flags, abstractions, configuration, or capabilities the user
didn't ask for. If they want more later, they'll ask. The smell to
watch for: designing a "good" version of something instead of
implementing the thing that was asked for.

## Shared code, never duplicated

Generic, reusable code belongs in the shared packages, not copied
between apps — Rust in [`krill-desktop-core`](https://github.com/krill-software/desktop-core),
TypeScript / CSS in [`@krill-software/desktop-ui`](https://github.com/krill-software/desktop-ui).
Before you build a UI primitive (loader, banner, modal, filter input…)
or copy a helper / struct / CSS block from one app to another, check the
shared package first; if it's generic, hoist it there and consume it.
Two apps with the same non-trivial code is a copy-paste smell. Full
guidance — how to decide what's generic, how to hoist and bump — in
[docs/shared-code.md](docs/shared-code.md).

## Don't

- Don't add a settings or preferences panel without asking — the bar is high.
- Don't introduce a theme picker or user-authored palettes. (Dark mode is a single light/dark toggle between the two locked modes, built into `mountChrome()` — there's nothing else to configure.)
- Don't add cross-platform conditionals (`#[cfg(target_os = "windows")]`, `process.platform === "darwin"`, etc.).
- Don't add telemetry, analytics, error reporting, "anonymous usage stats", or any network call the user didn't ask for.
- Don't add a plugin / extension / scripting surface.
- Don't change the locked palette or CSS variable names.
- Don't hide essential actions behind keyboard-only shortcuts in a manipulation-style app.

## The palette is the palette

The five locked colors in [STYLE.md](STYLE.md) → Palette **are** the palette. No other colors anywhere in the app — not in CSS, not in SVG, not in canvas fills, not in icon assets bundled with the app.

| Role             | Hex       | Use                                                       |
|------------------|-----------|-----------------------------------------------------------|
| Ghost White      | `#FAFAFF` | Background                                                |
| Space Cadet      | `#30343F` | Body text, primary ink                                    |
| Artichoke        | `#878472` | Muted text, status line, secondary labels                 |
| Shimmering Blush | `#DD7596` | Accent — cursor, selection, dirty marker, focus borders   |
| Brilliant Rose   | `#FF82BF` | Strong accent — hover state, primary CTAs                 |

What's allowed alongside these:
- **Alpha derivations of Space Cadet** for rules and shadows (`rgba(48, 52, 63, 0.08)`, `0.16`, etc.). These are not new colors — they're the ink at lower opacity.
- **Pure black or pure white** *only* when forced by external content (a PDF's own page color, a bundled icon's stroke we can't recolor). Document the reason inline if it ever comes up.

What's not allowed:
- New named greys, off-whites, or "panel" tints. If the chrome needs separation from the background, use a 1px Space-Cadet-alpha rule (`--fm-rule` / `--fm-rule-strong`), not a different fill.
- Webview/Tauri default colors leaking through (set `backgroundColor` in `tauri.conf.json` to Ghost White).
- "Just for this one component" colors — no exceptions.

If you find yourself wanting a sixth color, **stop and ask the user.** Adding to the palette is the user's decision, not Claude's. Calmness is the product, and the palette discipline is what makes it feel calm; extending the palette quietly erodes the brand.

If you find an off-palette color in existing code (including older krill apps), treat it as a bug, not a precedent. Surface it before fixing — there may be context for why it was added.

### Two narrow exceptions

**Domain-essential colors.** If your app genuinely needs colors the palette can't represent — syntax-highlighting categories, status colors on a dashboard, file-type indicators — declare them as app-specific named tokens (e.g. `--hl-keyword`) in the app's local `styles.css` with a comment explaining the reason. The chrome stays palette-strict; only the domain content uses these tokens. When a second krill app needs the same kind of colors, hoist the tokens into [`@krill-software/desktop-ui`](https://github.com/krill-software/desktop-ui) so all apps using that concept share the same set.

**The palette is for UI, not output.** The five locked colors govern what's painted on the running app's screen. They do *not* govern what the app *produces*: print stylesheets (`@media print`), exported PDFs, rendered or generated images, or content the app is displaying (a PDF's own page color, an image's pixels). Output follows whatever conventions make the output good — white paper, white page background, accurate content reproduction.
