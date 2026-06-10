# Shared code and shared UI

The headline rule lives in [CLAUDE.md](../CLAUDE.md): generic, reusable code
belongs in the shared packages, never duplicated across apps. This is the
detail.

## Shared code lives in the shared packages

Two krill apps duplicating the same non-trivial code is a
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
