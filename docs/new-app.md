# Creating a new krill app

Read [PHILOSOPHY.md](../PHILOSOPHY.md) and [STYLE.md](../STYLE.md) first. The
most complete reference template is
[pdf-reader](https://github.com/krill-software/pdf-reader) — when in
doubt, copy its structure.

## The steps

1. **Frame it in one sentence.** "Edits markdown files." "Crops and exports raster images." If the purpose can't be said in a sentence, push back before writing code.
2. **Confirm the *design* fits krill's** — calm, familiar, no power-user configurability. The app's *domain* (RSS, music, scratchpad notes, whatever) is fair game even if it's not typically a Win/Mac switcher request; the brand is in how it looks and feels, not in the category. If the user describes something Inkscape-shaped or GIMP-shaped, surface the mismatch — that's a design problem, not a domain one.
3. **Draft `SPEC.md` first** — mirror the existing apps' SPECs (goals, non-goals, stack, model, layout, file format, milestones).
4. **Scaffold by mirroring pdf-reader's tree** — same configs, same minimal `index.html`. Add `@krill-software/desktop-ui` as a frontend git dep (chrome / palette / actions / empty state come from there). Add `krill-desktop-core` as a Cargo git dep (state I/O, file helpers, dev fixture probe come from there). The reusable release workflow is referenced from `krill-software/.github`. Three deps, no copy-paste boilerplate.
5. **Implement M1**, stop, and let the user steer the next milestone.

## Always ask the user

These haven't been pinned globally and should be confirmed per app:

- **Directory name** for the new app (becomes the slug; everything else follows).
- **File extension and MIME type** for the app's documents.
- **Whether the app is "quiet" (writing/reading) or "manipulation"** — affects whether the working view should surface controls in a rail (manipulation) or stay chrome-free (quiet). See [STYLE.md](../STYLE.md) → Discoverability.

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

## After cutting the app

- Ship the per-app landing page — see [WEB-STYLE.md](../WEB-STYLE.md).
- Add a card to the org site
  ([krill-software.github.io](https://github.com/krill-software/krill-software.github.io)).
  The org site deliberately carries no app-count copy (no `N apps` /
  `N tools` numbers) — the suite grows, so don't reintroduce a hardcoded
  count that would go stale.
- Wire the in-app updater — see [docs/updater.md](updater.md).
