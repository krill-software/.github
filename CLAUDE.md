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

## Proof-of-concept apps (not ready for publish)

These apps live in the krill-software directory but are still
proof-of-concept — they should **not** be released, included on the
org site, or pointed at from documentation as exemplars:

- `audio-editor`
- `color-editor`
- `launcher`
- `photo-importer`
- `svg-editor`
- `terminal`
- `video-player`

When asked to "release all apps" or "update every krill app", **skip
this list**. They may have working scaffolding and even some
implemented features, but they haven't passed the design / scope bar
to be part of the shipped suite yet. If the user explicitly names
one, work on it — just don't release it until they confirm it's
graduated. When one does graduate, remove it from this list.

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
- No telemetry, no accounts, no plugins, no settings panel in v1.
- Dark mode: system-following only (no in-app toggle) via `prefers-color-scheme`; the locked palette inverts background and ink only.
- **Naming.** Slug = directory name under `krill-software/`. Binary, identifier, lib name, state dir, repo, and productName all derive from it. See [STYLE.md](STYLE.md) → Naming. Don't ask the user for any of these — only ask for the directory name (which is the new-app input).
- **App icon.** A single Lucide glyph in Ghost White on a Shimmering Blush (`#DD7596` / `--fm-accent`) circular ground, edge-to-edge — every app, no exceptions. Generated by `scripts/render-icons.py`; the `APPS` map at the top of that script is the source of truth. See [STYLE.md](STYLE.md) → Iconography. Never ship the default Tauri icon, never use a different ground color, never composite two glyphs.
- **Window dimensions.** Every app opens at the same default — **1296 × 800** (golden ratio) with min **720 × 445** and `center: true`. Put these in every app's `tauri.conf.json` under `app.windows[0]`. Users can resize freely; this is just the first-launch default so a launcher full of krill windows feels like one product family. Deviations need a SPEC.md justification. See [STYLE.md](STYLE.md) → Window dimensions.

## No copy-paste of app-specific details

When scaffolding a new app by mirroring an existing one, copy the
*structure* (file tree, build wiring, capabilities, shared
dependencies) — never the app-specific identity. Every name, every
piece of copy, every URL, every example filename must derive from
the new app's own SPEC.md and slug. Carrying over the source app's
productName / brand / hero copy / feature names / example file
extension is the most common krill scaffolding bug, and it surfaces
on the live site months later as a deployed page describing the
wrong app.

**Inconsistency is a smell.** If you ever notice productName,
brand line, page title, or any user-facing string drifting from
the app's directory slug (e.g. `text-editor/` with `productName:
"Markdown"`), surface it to the user as a likely copy-paste
artifact before doing anything else with it. Don't just propagate
the wrong name — the inconsistency itself is information.

When in doubt, the SPEC.md's "Identity" table is canonical. If the
SPEC contradicts what's in `tauri.conf.json` / `Cargo.toml` /
`package.json` / `docs/`, the SPEC wins and the code is stale.

## Shared code lives in the shared packages

Two krill apps duplicating the same non-trivial code is also a
copy-paste smell. Generic, reusable code belongs in the shared
packages, not in each app:

- **Rust shared code** → [`krill-desktop-core`](https://github.com/krill-software/desktop-core).
  XDG state I/O, window geometry, file path helpers, dev-fixture
  probing, IO error formatting, updater builder extension — all the
  cross-app Rust primitives live here.
- **TypeScript / CSS shared code** → [`@krill-software/desktop-ui`](https://github.com/krill-software/desktop-ui).
  Chrome (titlebar / menu / status line / aux pane), palette CSS,
  action registry, empty-state helpers, boot-error helper,
  checkForUpdates wrapper.

If you're tempted to copy a Rust struct, a helper function, a CSS
block, or a TS module from one app to another, **stop and ask**:
is this app-specific or generic? If it's generic, lift it into
the shared package and reference it from both apps. The bar for
"generic enough" is "would a third krill app written tomorrow want
this too?" — if yes, share.

The opposite is also a rule: don't put app-specific things into the
shared packages. `desktop-ui` should never know what file-drop's
contact card looks like; `desktop-core` should never grow code that
only photo-importer needs.

## Shared UI components

Before you build a UI primitive — loader / spinner, filter or
search input, banner, badge, modal, confirm dialog, breadcrumb,
keybinding hint, kbd cap, list row, dropdown, segmented control,
anything visual a second app could plausibly want — **check
[`@krill-software/desktop-ui`](https://github.com/krill-software/desktop-ui)
first**. If it exists, use it. If it doesn't and the primitive
isn't tied to one app's domain, add it to `desktop-ui` *first*,
then consume it from the app. A one-off `<div class="loader">`
inside an app becomes drift the moment the next app reaches for
the same shape and builds it slightly differently.

How to tell what belongs where:

- Visual / behavior that any other krill app could plausibly want →
  **`desktop-ui`**. (Loader, filter input, confirm-banner, "open
  in file manager" link, generic empty/error states.)
- Tightly bound to one app's domain (CSV grid cell, markdown
  syntax decoration, photo thumbnail, peer card) → **app-local**.

**Interfaces should match across apps.** The loader rendered for
activity-monitor's storage scan should be the same component, with
the same API, as the spinner shown during photo-importer's device
probe. Don't let two apps invent two different loader shapes.

**Discovery.** Browse `desktop-ui/src/` for `build*.ts` /
`mount*.ts` exports and the CSS modules under `desktop-ui/src/styles/`.
If you're unsure whether a primitive belongs, bias toward shared —
the cost of one extra desktop-ui export is small; the cost of N
apps with N slightly-different spinners is real.

When you DO hoist something into `desktop-ui`, bump it (minor
bump for additive APIs, major for breaking changes), update every
consumer that has a local equivalent, and delete the local copy.
Half-migrations are worse than no migration — they imply the
shared one is optional.

## Start with the simplest viable solution

Solve the literal request with the smallest thing that works. Don't
add flags, abstractions, configuration, or capabilities the user
didn't ask for. If they want more later, they'll ask. The smell to
watch for: designing a "good" version of something instead of
implementing the thing that was asked for.

## Always ask the user

These haven't been pinned globally and should be confirmed per app:

- **Directory name** for the new app (becomes the slug; everything else follows).
- **File extension and MIME type** for the app's documents.
- **Whether the app is "quiet" (writing/reading) or "manipulation"** — affects whether the working view should surface controls in a rail (manipulation) or stay chrome-free (quiet). See STYLE.md → Discoverability.

## Don't

- Don't add a settings or preferences panel without asking — the bar is high.
- Don't introduce a dark-mode toggle, a theme picker, or user-authored palettes. (The palette inverts automatically via `prefers-color-scheme`; that's the entire dark-mode surface.)
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

## Status line

Every krill app that mounts the status line follows the same convention
for what goes where, so the same eye-movement habits work across apps:

- **Left half (`chrome.statusInfo`)** is reserved for the app's
  version, formatted as `vX.Y.Z`. No product name — the titlebar
  already carries that. Read from `package.json` / `Cargo.toml` at
  build time. Static across the session; never changes after boot.
- **Right half (`chrome.statusState`)** holds whatever live meta-info
  the app wants to surface — file position, document size, peer count,
  cursor coords, current mode. Changes as the user works. Put the
  whole right-hand string in a **single span** with literal ` · `
  separators (e.g. `Ln 6 · Col 36 · UTF-8`). Splitting it into
  multiple spans + relying on the `.sep::before` pseudo for the dot
  doubles up against the flex container's `gap` and renders an extra
  separator with a wide whitespace gap.

The status line is a **reporting** surface, not a control surface. The
version label is intentionally non-interactive — "check for updates" is
already a menu action, and putting a click target into the status area
breaks the implicit contract that nothing down there does anything when
you tap it. If a piece of state genuinely warrants action (e.g.
"resolve merge conflict"), use a banner in the viewport or a menu
item, not the status line.

## In-app updater

Every krill app ships with a `Help → Check for updates…` entry that
downloads + installs a newer **AppImage** when one is available. On `.deb`
installs the helper instead explains "update with apt." There is no
boot-time check, no status-line indicator, no toast banner — quietness is
the brand.

Three pieces, all already wired in the shared infrastructure:

- **Frontend.** `mountChrome({ updater: true })` from
  `@krill-software/desktop-ui` (v0.5.0+) auto-includes the menu entry
  and points it at the package's shared `checkForUpdates()` helper.
- **Backend.** `tauri::Builder::default().with_updater()` from
  `krill_desktop_core::updater::BuilderExt` (v0.2.0+) registers
  `tauri-plugin-updater` and `tauri-plugin-process`.
- **CI.** The shared `krill-app-release.yml` signs the AppImage and
  publishes `latest.json` as a release asset so the updater can find it.

Per-app wiring (5 small things):

1. `package.json`: add `@tauri-apps/plugin-updater` + `-process` to deps.
2. `src-tauri/Cargo.toml`: add `tauri-plugin-updater = "2"` and
   `tauri-plugin-process = "2"` as **direct** deps (Tauri's permission
   scanner only sees direct deps).
3. `src-tauri/capabilities/default.json`: add `updater:default`,
   `process:default` to `permissions`.
4. `src-tauri/tauri.conf.json` → `plugins.updater`:
   ```json
   {
     "pubkey": "<org-wide minisign pubkey>",
     "endpoints": ["https://github.com/krill-software/<slug>/releases/latest/download/latest.json"]
   }
   ```
5. `src/main.ts`: pass `updater: true` to `mountChrome(...)`.

The signing keypair is **org-wide** — generated once via
`pnpm dlx @tauri-apps/cli signer generate -w ~/.tauri/krill-updater.key`,
the private key + password live as org-level GitHub secrets
(`TAURI_SIGNING_PRIVATE_KEY`, `TAURI_SIGNING_PRIVATE_KEY_PASSWORD`), and
the public key string is baked into each app's `tauri.conf.json`. New
apps just paste the same pubkey; nothing per-app to generate.

## Per-app landing page (`docs/`)

Every krill app ships a single-page GitHub Pages site at
`krill-software.github.io/<slug>/` from the repo's `docs/index.html`.
The page follows the **same design language as the org site** — same
fonts (Inter / Source Serif 4 / JetBrains Mono), same palette tokens,
same nav with the dotted brand, hero with eyebrow + serif h1 (one
italic `<em>` accent word) + lede + CTA buttons + meta line.

**Use the most recent polished app as your template** — currently any
of [text-editor](https://github.com/krill-software/text-editor/blob/main/docs/index.html),
[image-editor](https://github.com/krill-software/image-editor/blob/main/docs/index.html),
or [markdown-editor](https://github.com/krill-software/markdown-editor/blob/main/docs/index.html).
Do **not** copy from the older 60-line single-screen template
(csv-editor / document-viewer still have that one — those are stragglers
to be upgraded, not patterns to mirror).

Required sections, in order:

1. **`nav.top`** with brand `krill / <slug>` (or `krill / <product>`).
2. **`header.hero`** — eyebrow, serif h1 with one italic accent,
   serif lede, AppImage + .deb download buttons pointing at the
   current release, meta line (`vX.Y.Z · Linux x86_64 · Free & open source`).
3. **`.preview-frame`** — a static mock of the live UI (a slice that
   shows what the app actually looks like). Keep it hand-rolled HTML,
   no screenshots — they get stale, hi-DPI is a pain, and the locked
   palette makes mocks easy.
4. **`section#features`** — 6 tagged features (`.tag` + `h3` + `p`).
5. **`section#principles`** — 4 borderleft-accent principles
   summarizing what the app *isn't*.
6. **`section#install`** — copy on the left, `.install-box` on the
   right with shell commands for AppImage and `.deb` install paths.
7. **`footer`** — © krill · MIT line, GitHub + issues links.

**Version bumping is automatic.** The shared `krill-app-release.yml`
workflow runs a `Bump docs/index.html` step on every tag push that
sed-updates the hero `<strong>v…</strong>`, the `/v…/` path segment in
download URLs, and the `_X.Y.Z_amd64` version segment in artifact
filenames, then commits the result to `main` as a `github-actions[bot]`
commit. Don't hand-bump those strings — they'll be overwritten on the
next release anyway. The bot also rewrites the `ASSET_PREFIX` (from
`productName` with spaces → dots) so productName renames propagate.

After cutting a new app, also add a card to the org site
([krill-software.github.io](https://github.com/krill-software/krill-software.github.io)).
The org site deliberately carries no app-count copy (no `N apps` /
`N tools` numbers) — the suite grows, so don't reintroduce a hardcoded
count that would go stale.

## Release flow

For an existing app, when the user asks to release a new version:

1. Bump the version in all three files (`package.json`, `src-tauri/Cargo.toml`, `src-tauri/tauri.conf.json`).
2. `pnpm release` runs `scripts/publish.sh` — builds AppImage + .deb under `release/v<version>/` with `SHA256SUMS`.
3. Commit + annotated tag `vX.Y.Z` (don't amend, don't force-push without asking).
4. Pushing the tag triggers `.github/workflows/release.yml` which publishes a GitHub Release directly with the AppImage + .deb attached and `latest.json` uploaded for the in-app updater. No draft step.

The script and workflow do *not* touch git on their own. Tagging and pushing are deliberate operations.
