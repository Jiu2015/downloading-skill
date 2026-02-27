#!/usr/bin/env bash
# Generate presigned download URL for OSS objects.
# Usage: oss-share.sh OSS_PATH [DURATION] [--download]
#   OSS_PATH:   oss://bucket/path/to/file
#   DURATION:   1h, 6h, 12h (default), 1d, 7d
#   --download: force browser to download instead of preview
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") OSS_PATH [DURATION] [--download]"
    echo ""
    echo "  OSS_PATH    oss://bucket/path/to/file"
    echo "  DURATION    1h, 6h, 12h (default), 1d, 7d"
    echo "  --download  force download (not preview) in browser"
    exit 1
}

# --- Require ossutil ---
if ! command -v ossutil &>/dev/null; then
    echo "Error: ossutil not found. Install with: bash scripts/install-toolkit.sh" >&2
    exit 1
fi

# --- Environment detection ---
OPENCLAW_DIR="/home/node/.openclaw"
OPENCLAW_WS="${OPENCLAW_DIR}/workspace"
OSS_CONFIG_ARGS=()
for cfg in "${OPENCLAW_WS}/.ossutilconfig" "$HOME/.ossutilconfig"; do
    if [[ -f "$cfg" ]]; then
        OSS_CONFIG_ARGS=(--config-file "$cfg")
        break
    fi
done

# --- Args ---
OSS_PATH=""
DURATION="12h"
FORCE_DOWNLOAD=false

for arg in "$@"; do
    case "$arg" in
        --download) FORCE_DOWNLOAD=true ;;
        -h|--help)  usage ;;
        oss://*)    OSS_PATH="$arg" ;;
        *)          DURATION="$arg" ;;
    esac
done

[[ -z "$OSS_PATH" ]] && usage

# --- Parse duration to seconds ---
parse_duration() {
    local input="$1"
    local num="${input%[hHdD]}"
    local unit="${input: -1}"

    case "$unit" in
        h|H) echo $((num * 3600)) ;;
        d|D) echo $((num * 86400)) ;;
        *)
            # Try as raw seconds
            if [[ "$input" =~ ^[0-9]+$ ]]; then
                echo "$input"
            else
                echo "Error: invalid duration '$input'. Use format: 1h, 6h, 12h, 1d, 7d" >&2
                return 1
            fi
            ;;
    esac
}

TIMEOUT=$(parse_duration "$DURATION")

# --- Generate presigned URL ---
SIGN_ARGS=("${OSS_CONFIG_ARGS[@]}" sign --timeout "$TIMEOUT")

if $FORCE_DOWNLOAD; then
    # Extract filename from OSS path for Content-Disposition header
    FILENAME="$(basename "$OSS_PATH")"
    SIGN_ARGS+=(--query-param "response-content-disposition=attachment;filename=${FILENAME}")
fi

ossutil "${SIGN_ARGS[@]}" "$OSS_PATH"
