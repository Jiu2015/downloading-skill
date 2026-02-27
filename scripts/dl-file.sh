#!/usr/bin/env bash
# Fast multi-thread file download via aria2 (with wget fallback).
# Usage: dl-file.sh URL [OUTPUT_PATH]
#   OUTPUT_PATH: full path or directory (default: current dir, auto-detect filename)
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") URL [OUTPUT_PATH]"
    echo ""
    echo "  OUTPUT_PATH: file path or directory (default: current dir)"
    exit 1
}

# --- Environment detection ---
OPENCLAW_DIR="/home/node/.openclaw"
OPENCLAW_WS="${OPENCLAW_DIR}/workspace"
DEFAULT_DL_DIR=""
if [[ -d "$OPENCLAW_DIR" ]]; then
    DEFAULT_DL_DIR="${OPENCLAW_WS}/downloads"
fi

# --- Args ---
URL="${1:-}"
[[ -z "$URL" ]] && usage

OUTPUT="${2:-$DEFAULT_DL_DIR}"

# --- Download with aria2c (preferred) or wget fallback ---
if command -v aria2c &>/dev/null; then
    ARGS=(
        -x16        # 16 connections per server
        -s16        # 16 splits
        -k1M        # 1MB minimum split size
        --max-tries=3
        --retry-wait=3
        --continue=true
        --auto-file-renaming=false
        --console-log-level=notice
    )

    if [[ -n "$OUTPUT" ]]; then
        if [[ -d "$OUTPUT" ]]; then
            ARGS+=(-d "$OUTPUT")
        else
            mkdir -p "$(dirname "$OUTPUT")"
            ARGS+=(-d "$(dirname "$OUTPUT")" -o "$(basename "$OUTPUT")")
        fi
    fi

    aria2c "${ARGS[@]}" "$URL"
elif command -v wget &>/dev/null; then
    echo "Note: aria2c not found, falling back to wget (single connection)" >&2
    ARGS=(-c)  # resume

    if [[ -n "$OUTPUT" ]]; then
        if [[ -d "$OUTPUT" ]]; then
            ARGS+=(-P "$OUTPUT")
        else
            mkdir -p "$(dirname "$OUTPUT")"
            ARGS+=(-O "$OUTPUT")
        fi
    fi

    wget "${ARGS[@]}" "$URL"
else
    echo "Error: Neither aria2c nor wget found." >&2
    echo "  Install with: brew install aria2  (or)  brew install wget" >&2
    echo "  Or run: bash scripts/install-toolkit.sh" >&2
    exit 1
fi
