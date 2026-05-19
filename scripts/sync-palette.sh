#!/usr/bin/env bash
# Sync the krill palette from the apps' canonical copy (in desktop-ui)
# to the web mirror (in krill-software.github.io).
#
# Run from anywhere — paths are resolved relative to the krill-software
# parent directory.
#
# This is the only acceptable way the palette diverges between apps and
# web; do not hand-edit the mirror copy.

set -eu

PARENT="${KRILL_SOFTWARE_DIR:-$HOME/dev/krill-software}"
SRC="$PARENT/desktop-ui/src/styles/palette.css"
DST="$PARENT/krill-software.github.io/palette.css"

if [[ ! -f "$SRC" ]]; then
  echo "palette source not found at: $SRC" >&2
  exit 1
fi
if [[ ! -d "$(dirname "$DST")" ]]; then
  echo "web mirror dir not found: $(dirname "$DST")" >&2
  exit 1
fi

if cmp -s "$SRC" "$DST"; then
  echo "palette is already in sync."
  exit 0
fi

cp "$SRC" "$DST"
echo "==> Synced palette: $SRC -> $DST"
echo "    Commit + push both repos to publish."
