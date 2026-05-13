#!/bin/sh
# Convenience installer for krill apps. Fetches the latest .deb from
# GitHub Releases and installs it via apt (which marks the package
# correctly so it survives `apt update` / `autoremove`).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/krill-software/.github/main/install.sh | sh -s <slug>
#
# Examples:
#   curl -fsSL https://raw.githubusercontent.com/krill-software/.github/main/install.sh | sh -s text-editor
#   curl -fsSL https://raw.githubusercontent.com/krill-software/.github/main/install.sh | sh -s markdown-editor
#
# Requires: curl, sudo, apt. Linux x86_64 only.

set -eu

SLUG="${1:-}"
if [ -z "$SLUG" ]; then
    cat >&2 <<'EOF'
usage: install.sh <slug>

Slug is the krill app's repository name (e.g. text-editor, markdown-editor).
EOF
    exit 2
fi

REPO="krill-software/$SLUG"
API="https://api.github.com/repos/$REPO/releases/latest"

echo "==> Looking up latest release of $REPO"
ASSET_URL=$(curl -fsSL "$API" 2>/dev/null \
    | grep -o '"browser_download_url": *"[^"]*_amd64\.deb"' \
    | head -1 \
    | sed 's/.*"\(https[^"]*\)"/\1/')

if [ -z "$ASSET_URL" ]; then
    echo "error: no amd64 .deb asset found in the latest release of $REPO" >&2
    echo "       check https://github.com/$REPO/releases" >&2
    exit 1
fi

VERSION=$(echo "$ASSET_URL" | sed -n 's|.*/download/\([^/]*\)/.*|\1|p')
TMP=$(mktemp --suffix=.deb)
trap 'rm -f "$TMP"' EXIT

echo "==> Downloading $VERSION"
curl -fsSL --progress-bar "$ASSET_URL" -o "$TMP"

echo "==> Installing (sudo required so apt can register the package)"
sudo apt install -y "$TMP"

echo "==> Installed $SLUG $VERSION"
