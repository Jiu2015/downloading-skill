#!/usr/bin/env bash
# Download subtitles for a video.
# Usage: dl-subtitle.sh VIDEO_URL_OR_QUERY [LANG] [OUTPUT_DIR]
#   LANG: en (default), zh, ja, ko, etc. Use comma-separated for multiple: "en,zh"
#   For URLs: downloads embedded subtitles via yt-dlp
#   For search queries: provides search links for manual download
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") VIDEO_URL_OR_QUERY [LANG] [OUTPUT_DIR]"
    echo ""
    echo "  LANG:       en (default), zh, ja, ko, or comma-separated: en,zh"
    echo "  OUTPUT_DIR: directory to save to (default: current dir)"
    exit 1
}

# --- Args ---
INPUT="${1:-}"
[[ -z "$INPUT" ]] && usage

LANG="${2:-en}"
OUTPUT_DIR="${3:-.}"

mkdir -p "$OUTPUT_DIR"

# --- Environment detection ---
OPENCLAW_DIR="/home/node/.openclaw"
if [[ -d "$OPENCLAW_DIR" ]]; then
    export PATH="${OPENCLAW_DIR}/pyenv/bin:$PATH"
    export PYTHONPATH="${OPENCLAW_DIR}/pyenv"
fi

# If input looks like a URL, use yt-dlp
if [[ "$INPUT" =~ ^https?:// ]]; then
    if ! command -v yt-dlp &>/dev/null; then
        echo "Error: yt-dlp not found. Install with: brew install yt-dlp" >&2
        exit 1
    fi

    echo "--> Downloading subtitles from URL via yt-dlp..."
    yt-dlp \
        --write-subs \
        --write-auto-subs \
        --sub-langs "$LANG" \
        --sub-format "srt/ass/vtt" \
        --skip-download \
        -o "$OUTPUT_DIR/%(title)s.%(ext)s" \
        "$INPUT"
    echo "Done: subtitles saved to $OUTPUT_DIR"
else
    # For search queries, provide guidance
    QUERY_PLUS="${INPUT// /+}"
    QUERY_DASH="${INPUT// /-}"
    echo "--> Search for subtitles manually:"
    echo "  SubDL:          https://subdl.com/search?query=${QUERY_PLUS}"
    echo "  OpenSubtitles:  https://www.opensubtitles.com/en/search-all/q-${QUERY_DASH}"
    echo "  assrt.net:      https://assrt.net/sub/?searchword=${QUERY_PLUS}"
    echo "  zimuku:         https://zimuku.org/search?q=${QUERY_PLUS}"
fi
