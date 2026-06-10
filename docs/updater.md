# In-app updater

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
