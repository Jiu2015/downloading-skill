#!/usr/bin/env bash
# Download video from URL.
# Usage: dl-video.sh URL [QUALITY] [OUTPUT_DIR]
#   QUALITY: best (default), 2160, 1080, 720, 480, or raw yt-dlp format string
#   OUTPUT_DIR: directory to save to (default: current dir)
#   Output: MP4 (H.264/H.265 + AAC) for maximum compatibility
#   Auto-detects Bilibili and uses browser cookies when needed.
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") URL [QUALITY] [OUTPUT_DIR]"
    echo ""
    echo "  QUALITY:    best (default), 2160, 1080, 720, 480"
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
OPENCLAW_WS="${OPENCLAW_DIR}/workspace"
DEFAULT_DL_DIR="."
if [[ -d "$OPENCLAW_DIR" ]]; then
    export PATH="${OPENCLAW_DIR}/pyenv/bin:$PATH"
    export PYTHONPATH="${OPENCLAW_DIR}/pyenv"
    DEFAULT_DL_DIR="${OPENCLAW_WS}/downloads"
fi

# --- Args ---
URL="${1:-}"
[[ -z "$URL" ]] && usage

QUALITY="${2:-best}"
OUTPUT_DIR="${3:-$DEFAULT_DL_DIR}"

mkdir -p "$OUTPUT_DIR"

# --- Format selection ---
# Prefer H.264/H.265 video + AAC audio for universal playback (QuickTime, iOS, browsers).
# AV1/VP9/Opus won't play on macOS QuickTime. Fallback to any format if preferred codecs unavailable.
case "$QUALITY" in
    best) FORMAT="bv[vcodec~='^(avc|hev)'][ext=mp4]+ba[acodec~='^(mp4a)'][ext=m4a]/bv[ext=mp4]+ba[ext=m4a]/bv*+ba/b" ;;
    2160) FORMAT="bv[height<=2160][vcodec~='^(avc|hev)'][ext=mp4]+ba[acodec~='^(mp4a)'][ext=m4a]/bv[height<=2160][ext=mp4]+ba[ext=m4a]/bv[height<=2160]+ba/b" ;;
    1080) FORMAT="bv[height<=1080][vcodec~='^(avc|hev)'][ext=mp4]+ba[acodec~='^(mp4a)'][ext=m4a]/bv[height<=1080][ext=mp4]+ba[ext=m4a]/bv[height<=1080]+ba/b" ;;
    720)  FORMAT="bv[height<=720][vcodec~='^(avc|hev)'][ext=mp4]+ba[acodec~='^(mp4a)'][ext=m4a]/bv[height<=720][ext=mp4]+ba[ext=m4a]/bv[height<=720]+ba/b" ;;
    480)  FORMAT="bv[height<=480][vcodec~='^(avc|hev)'][ext=mp4]+ba[acodec~='^(mp4a)'][ext=m4a]/bv[height<=480][ext=mp4]+ba[ext=m4a]/bv[height<=480]+ba/b" ;;
    *)    FORMAT="$QUALITY" ;;  # allow raw format string
esac

EXTRA_ARGS=()

# --- Bilibili cookie auto-detection ---
if [[ "$URL" =~ bilibili\.com|b23\.tv ]]; then
    # Check for OpenClaw cookie file first
    if [[ -d "$OPENCLAW_DIR" && -f "${OPENCLAW_DIR}/workspace/.bili_cookies.txt" ]]; then
        EXTRA_ARGS+=(--cookies "${OPENCLAW_DIR}/workspace/.bili_cookies.txt")
    else
        # Try browser cookies: Bilibili returns HTTP 412 without cookies
        for browser in chromium chrome firefox edge; do
            if yt-dlp --cookies-from-browser "$browser" -j "$URL" &>/dev/null 2>&1; then
                EXTRA_ARGS+=(--cookies-from-browser "$browser")
                break
            fi
        done
        if [[ ${#EXTRA_ARGS[@]} -eq 0 ]]; then
            echo "Warning: Bilibili requires login cookies. Log in via Chrome/Firefox first." >&2
            echo "  Or export cookies: yt-dlp --cookies cookies.txt ..." >&2
        fi
    fi
fi

# --- Download ---
yt-dlp \
    -f "$FORMAT" \
    --merge-output-format mp4 \
    --embed-metadata \
    --embed-thumbnail \
    --write-subs --sub-langs "en,zh" \
    "${EXTRA_ARGS[@]}" \
    -o "$OUTPUT_DIR/%(title)s.%(ext)s" \
    "$URL"
