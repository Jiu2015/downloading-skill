#!/usr/bin/env bash
# Download from a torrent file or magnet link via aria2.
# Usage: dl-torrent.sh MAGNET_OR_TORRENT [OUTPUT_DIR]
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") MAGNET_OR_TORRENT [OUTPUT_DIR]"
    echo ""
    echo "  MAGNET_OR_TORRENT: magnet link or path to .torrent file"
    echo "  OUTPUT_DIR:        directory to save to (default: current dir)"
    exit 1
}

# --- Require aria2c ---
if ! command -v aria2c &>/dev/null; then
    echo "Error: aria2c not found. Install with: brew install aria2" >&2
    echo "  Or run: bash scripts/install-toolkit.sh" >&2
    exit 1
fi

# --- Environment detection ---
OPENCLAW_DIR="/home/node/.openclaw"
OPENCLAW_WS="${OPENCLAW_DIR}/workspace"
DEFAULT_DL_DIR="."
if [[ -d "$OPENCLAW_DIR" ]]; then
    DEFAULT_DL_DIR="${OPENCLAW_WS}/downloads"
fi

# --- Args ---
INPUT="${1:-}"
[[ -z "$INPUT" ]] && usage

OUTPUT_DIR="${2:-$DEFAULT_DL_DIR}"

mkdir -p "$OUTPUT_DIR"

# --- Download ---
aria2c \
    -d "$OUTPUT_DIR" \
    --seed-time=0 \
    --max-connection-per-server=16 \
    --split=16 \
    --bt-max-peers=100 \
    --bt-tracker-connect-timeout=10 \
    --bt-tracker-timeout=10 \
    --console-log-level=notice \
    "$INPUT"
