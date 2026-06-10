#!/usr/bin/env bash
#
# Bump the @krill-software/desktop-ui git-dep pin across every shipped krill
# app — and optionally reinstall, build-gate, commit, and push each.
#
#   bump-desktop-ui.sh <version> [--install] [--build] [--commit] [--push] [--include-poc]
#
#   bump-desktop-ui.sh v0.13.1
#       Rewrite the pin in every shipped app's package.json. Nothing else.
#
#   bump-desktop-ui.sh v0.13.1 --install --build
#       ...then `pnpm install` + `pnpm run build` each, reporting pass/fail.
#
#   bump-desktop-ui.sh v0.13.1 --install --build --commit --push
#       Full sweep. Only apps whose build PASSES are committed + pushed
#       (build is the gate); a failed build leaves that app's pin bumped
#       but uncommitted, and is reported.
#
# Proof-of-concept apps (not shipped) are skipped unless --include-poc.
# Each app is its own git repo; commits/pushes target its `main`. Only
# package.json + pnpm-lock.yaml are staged, so unrelated working-tree
# changes are left alone.
set -uo pipefail

VERSION="${1:-}"
case "$VERSION" in
  v[0-9]*) ;;
  *) echo "usage: $(basename "$0") <version e.g. v0.13.1> [--install] [--build] [--commit] [--push] [--include-poc]" >&2; exit 1 ;;
esac
shift

INSTALL= BUILD= COMMIT= PUSH= INCLUDE_POC=
for f in "$@"; do
  case "$f" in
    --install) INSTALL=1 ;;
    --build)   BUILD=1 ;;
    --commit)  COMMIT=1 ;;
    --push)    PUSH=1 ;;
    --include-poc) INCLUDE_POC=1 ;;
    *) echo "unknown flag: $f" >&2; exit 1 ;;
  esac
done

# Repo root = the dir that holds the app repos (this script lives in
# <root>/.github/scripts/).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
[ -d "$ROOT/desktop-ui" ] || { echo "no desktop-ui/ under $ROOT — wrong location?" >&2; exit 1; }

# Not shipped — skipped by default. Keep in sync with .github/CLAUDE.md.
POC=" color-editor launcher photo-importer svg-editor terminal video-player "

results=()
fail=0
for pkg in "$ROOT"/*/package.json; do
  app="$(basename "$(dirname "$pkg")")"
  [ "$app" = "desktop-ui" ] && continue
  grep -q '"@krill-software/desktop-ui"' "$pkg" || continue
  if [ -z "$INCLUDE_POC" ] && [[ "$POC" == *" $app "* ]]; then
    results+=("· $app — skipped (PoC)"); continue
  fi

  sed -i -E "s|(desktop-ui#)v[0-9][0-9.]*|\1$VERSION|" "$pkg"

  ( cd "$(dirname "$pkg")"
    [ -n "$INSTALL" ] && { pnpm install >/dev/null 2>&1 || exit 11; }
    [ -n "$BUILD" ]   && { pnpm run build >/dev/null 2>&1 || exit 12; }
    if [ -n "$COMMIT" ]; then
      if ! git diff --quiet -- package.json pnpm-lock.yaml 2>/dev/null; then
        git add package.json pnpm-lock.yaml
        git commit -q -m "Bump desktop-ui to $VERSION"
        [ -n "$PUSH" ] && { git push -q origin main || exit 13; }
      fi
    fi
  )
  case $? in
    0)  results+=("✓ $app — $VERSION$([ -n "$PUSH" ] && echo ' (pushed)')") ;;
    11) results+=("✗ $app — install failed"); fail=1 ;;
    12) results+=("✗ $app — BUILD FAILED (pin bumped, not committed)"); fail=1 ;;
    13) results+=("✗ $app — push failed (committed locally)"); fail=1 ;;
    *)  results+=("✗ $app — error"); fail=1 ;;
  esac
done

echo
echo "=== bump-desktop-ui → $VERSION ==="
printf '  %s\n' "${results[@]}"
exit $fail
