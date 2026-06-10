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

Don't release a [proof-of-concept app](../CLAUDE.md) — check the skip-list in
CLAUDE.md before a "release all apps" sweep.
