# Working in krill-software

This directory is a collection of small native Linux apps under the **krill** umbrella. Each app is its own crate / project (`markdown-editor`, `image-editor`, `color-editor`).

Before scaffolding a new app or making non-trivial changes to an existing one, read:

- [PHILOSOPHY.md](PHILOSOPHY.md) — what krill apps are and aren't. Read first.
- [STYLE.md](STYLE.md) — engineering and visual conventions every app shares.

The most complete reference template is [document-viewer](https://github.com/krill-software/document-viewer) — Tauri shell, custom titlebar via [`@krill-software/desktop-ui`](https://github.com/krill-software/desktop-ui), palette wired up via the same package, reusable release workflow from [krill-software/.github](https://github.com/krill-software/.github), publish script, all in place. When in doubt, copy from there.

Three shared repos that every app depends on:

- **[`@krill-software/desktop-ui`](https://github.com/krill-software/desktop-ui)** (npm-style git dep, pinned to a tag) — TypeScript: palette CSS bundle, `mountChrome()` (titlebar / menu / status line / aux pane), `buildEmptyState()` / `buildErrorState()` / `showBootError()` helpers, canonical action registry. Apps import this and don't redeclare any of the chrome locally.
- **[`krill-desktop-core`](https://github.com/krill-software/desktop-core)** (Cargo git dep, pinned to a tag) — Rust: `state` module (XDG dir / load+save JSON / `WindowGeometry`), `fs` module (`read_bytes` / `absolute_path` / `format_io_err`), `dev` module (`test_file`). Each app's `src-tauri/src/lib.rs` declares the Tauri commands (the macro needs concrete symbols) but their bodies are one-liners delegating here.
- **[krill-software/.github](https://github.com/krill-software/.github)** — reusable `krill-app-release.yml` workflow. Each app's local `.github/workflows/release.yml` is a 13-line caller that hands off to it.

## When the user asks for a new krill app

1. **Frame it in one sentence.** "Edits markdown files." "Crops and exports raster images." If the purpose can't be said in a sentence, push back before writing code.
2. **Confirm the *design* fits krill's** — calm, familiar, no power-user configurability. The app's *domain* (RSS, music, scratchpad notes, whatever) is fair game even if it's not typically a Win/Mac switcher request; the brand is in how it looks and feels, not in the category. If the user describes something Inkscape-shaped or GIMP-shaped, surface the mismatch — that's a design problem, not a domain one.
3. **Draft `SPEC.md` first** — mirror the existing apps' SPECs (goals, non-goals, stack, model, layout, file format, milestones).
4. **Scaffold by mirroring document-viewer's tree** — same configs, same minimal `index.html`. Add `@krill-software/desktop-ui` as a frontend git dep (chrome / palette / actions / empty state come from there). Add `krill-desktop-core` as a Cargo git dep (state I/O, file helpers, dev fixture probe come from there). The reusable release workflow is referenced from `krill-software/.github`. Three deps, no copy-paste boilerplate.
5. **Implement M1**, stop, and let the user steer the next milestone.

## Binding without checking

Treat these as decided. Don't relitigate them per app.

- The locked palette and CSS variable names (see STYLE.md). Provided by `@krill-software/desktop-ui` — apps don't redeclare these locally.
- Custom titlebar with min / max / close + inline menu bar; native decorations off. Built by `mountChrome()` from the desktop-ui package.
- Rust-side state I/O (XDG state dir, JSON load/save, `WindowGeometry`, dev test-file probe, path canonicalization, IO error formatting). Provided by `krill-desktop-core` — apps don't reimplement any of it.
- Tauri 2 + TypeScript + Vite + pnpm + Rust 1.77+.
- Linux x86_64 only. AppImage + `.deb`. No Flatpak, no Snap, no Windows / macOS code paths.
- MIT license.
- One window per document.
- No telemetry, no accounts, no plugins, no dark mode, no settings panel in v1.
- **Naming.** Slug = directory name under `krill-software/`. Binary, identifier, lib name, state dir, repo, and productName all derive from it. See [STYLE.md](STYLE.md) → Naming. Don't ask the user for any of these — only ask for the directory name (which is the new-app input).

## Always ask the user

These haven't been pinned globally and should be confirmed per app:

- **Directory name** for the new app (becomes the slug; everything else follows).
- **File extension and MIME type** for the app's documents.
- **Whether the app is "quiet" (writing/reading) or "manipulation"** — affects whether the working view should surface controls in a rail (manipulation) or stay chrome-free (quiet). See STYLE.md → Discoverability.

## Don't

- Don't add a settings or preferences panel without asking — the bar is high.
- Don't introduce dark mode, theme support, or custom palettes.
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

## Release flow

For an existing app, when the user asks to release a new version:

1. Bump the version in all three files (`package.json`, `src-tauri/Cargo.toml`, `src-tauri/tauri.conf.json`).
2. `pnpm release` runs `scripts/publish.sh` — builds AppImage + .deb under `release/v<version>/` with `SHA256SUMS`.
3. Commit + annotated tag `vX.Y.Z` (don't amend, don't force-push without asking).
4. Pushing the tag triggers `.github/workflows/release.yml` which creates a draft GitHub Release with the artifacts attached.
5. The user promotes the draft to a real release manually.

The script and workflow do *not* touch git on their own. Tagging and pushing are deliberate operations.
