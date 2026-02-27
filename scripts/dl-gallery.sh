#!/usr/bin/env bash
# Batch download images/media from a gallery URL.
# Usage: dl-gallery.sh URL [OUTPUT_DIR] [EXTRA_ARGS...]
#   Supports 170+ sites: Pixiv, Twitter, Reddit, Instagram, DeviantArt, Danbooru, etc.
#   Extra args are passed through to gallery-dl (e.g. --range 1-5, --filter, --write-metadata)
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") URL [OUTPUT_DIR] [EXTRA_ARGS...]"
    echo ""
    echo "  OUTPUT_DIR:  directory to save to (default: ./gallery-dl)"
    echo "  EXTRA_ARGS:  passed to gallery-dl (e.g. --range 1-5)"
    exit 1
}

# --- Require gallery-dl ---
if ! command -v gallery-dl &>/dev/null; then
    echo "Error: gallery-dl not found. Install with: pip3 install gallery-dl" >&2
    echo "  Or run: bash scripts/install-toolkit.sh" >&2
    exit 1
fi

# --- Environment detection ---
OPENCLAW_DIR="/home/node/.openclaw"
if [[ -d "$OPENCLAW_DIR" ]]; then
    export PATH="${OPENCLAW_DIR}/pyenv/bin:$PATH"
    export PYTHONPATH="${OPENCLAW_DIR}/pyenv"
fi

# --- Args ---
URL="${1:-}"
[[ -z "$URL" ]] && usage

OUTPUT_DIR="${2:-./gallery-dl}"
shift 2 2>/dev/null || shift $#

mkdir -p "$OUTPUT_DIR"

# --- Download ---
gallery-dl \
    -d "$OUTPUT_DIR" \
    "$@" \
    "$URL"
