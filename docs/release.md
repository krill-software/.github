# Release flow

For an existing app, when the user asks to release a new version:

1. Bump the version in the following files:
   - `package.json`
   - `src-tauri/Cargo.toml`
   - `src-tauri/tauri.conf.json`.
2. `pnpm release` runs `scripts/publish.sh` which builds `AppImage` and `.deb` under `release/v<version>/` with `SHA256SUMS`.
3. Commit and create an annotated tag `vX.Y.Z`. Don't:
   - amend
   - force-push without asking.

4. Pushing the tag triggers `.github/workflows/release.yml` which publishes a GitHub Release directly with the AppImage + .deb attached and `latest.json` uploaded for the in-app updater. No draft step.

The script and workflow do _not_ touch git on their own. Tagging and pushing are deliberate operations.

## First release of an app

A tag alone doesn't put the app on the web. Before (or right after)
the first `v0.1.0`, also:

1. Create the GitHub repo (`gh repo create krill-software/<slug> --public --source .`)
   and make sure `<slug>` is in the `APPS` map of `scripts/render-icons.py`
   in this repo — the release workflow's icon step fails without it.
2. Ship `docs/_config.yml` + `docs/index.html` (see [WEB-STYLE.md](../WEB-STYLE.md))
   and enable GitHub Pages from `main` / `/docs`:
   `gh api -X POST repos/krill-software/<slug>/pages -f 'source[branch]=main' -f 'source[path]=/docs'`.
3. Add the app's card to the org site grid
   ([krill-software.github.io](https://github.com/krill-software/krill-software.github.io)).
4. Remove the app from the proof-of-concept list in CLAUDE.md.

Don't release a [proof-of-concept app](../CLAUDE.md) — check the skip-list in
CLAUDE.md before a "release all apps" sweep.
