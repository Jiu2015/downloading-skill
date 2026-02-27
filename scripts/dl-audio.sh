#!/usr/bin/env bash
# Extract audio from a URL.
# Usage: dl-audio.sh URL [FORMAT] [OUTPUT_DIR]
#   FORMAT: mp3 (default), opus, flac, wav, best
#   OUTPUT_DIR: directory to save to (default: current dir)
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") URL [FORMAT] [OUTPUT_DIR]"
    echo ""
    echo "  FORMAT:     mp3 (default), opus, flac, wav, best"
    echo "  OUTPUT_DIR: directory to save to (default: current dir)"
    exit 1
}

# --- Require yt-dlp ---
if ! command -v yt-dlp &>/dev/null; then
    echo "Error: yt-dlp not found. Install with: brew install yt-dlp" >&2
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

FORMAT="${2:-mp3}"
OUTPUT_DIR="${3:-.}"

mkdir -p "$OUTPUT_DIR"

# --- Download ---
yt-dlp \
    -x \
    --audio-format "$FORMAT" \
    --audio-quality 0 \
    --embed-metadata \
    --embed-thumbnail \
    -o "$OUTPUT_DIR/%(title)s.%(ext)s" \
    "$URL"
