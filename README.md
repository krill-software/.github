# krill-software / .github

Org-wide GitHub configuration for [krill-software](https://github.com/krill-software).

## What lives here

### Reusable workflows — `.github/workflows/`

| File | Purpose |
|---|---|
| `krill-app-release.yml` | Build & publish a krill app on tag push. AppImage + `.deb` for Linux x86_64, drafted on GitHub Releases. |

Each app's local `.github/workflows/release.yml` is a thin caller that passes a couple of display strings; everything else (Linux system deps, Rust toolchain, pnpm setup, tauri-action, draft release body template) is centralized here so the apps don't drift.

Calling pattern:

```yaml
name: Release
on:
  push:
    tags: ['v*']
  workflow_dispatch:
jobs:
  release:
    uses: krill-software/.github/.github/workflows/krill-app-release.yml@main
    with:
      product-name: "Document Viewer"
      example-file: "paper.pdf"
    permissions:
      contents: write
```

## Versioning

Consumers reference `@main` for now. If we ever need stability pins (e.g. some app is pinned while others adopt a workflow change), tag this repo `v1`, `v2` etc. and consumers can switch to `@v1`.

## License

MIT — same as the rest of krill-software.
