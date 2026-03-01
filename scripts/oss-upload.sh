#!/usr/bin/env bash
# Upload file or directory to Alibaba Cloud OSS.
# Usage: oss-upload.sh FILE_OR_DIR [OSS_PATH] [-u] [--sign]
#   FILE_OR_DIR: local file or directory to upload
#   OSS_PATH:    destination (default: oss://BUCKET/downloads/FILENAME)
#   -u:          incremental upload (skip unchanged files)
#   --sign:      generate presigned URL after upload (12h default)
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") FILE_OR_DIR [OSS_PATH] [-u] [--sign]"
    echo ""
    echo "  FILE_OR_DIR  local file or directory to upload"
    echo "  OSS_PATH     OSS destination (e.g. oss://bucket/path/)"
    echo "  -u           incremental upload (skip unchanged files)"
    echo "  --sign       generate presigned URL after upload"
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
OSS_CONFIG_FILE=""
OSS_CONFIG_ARGS=()
for cfg in "${OPENCLAW_WS}/.ossutilconfig" "$HOME/.ossutilconfig"; do
    if [[ -f "$cfg" ]]; then
        OSS_CONFIG_FILE="$cfg"
        OSS_CONFIG_ARGS=(--config-file "$cfg")
        break
    fi
done

# --- Parse args ---
LOCAL_PATH=""
OSS_PATH=""
INCREMENTAL=false
SIGN_AFTER=false

for arg in "$@"; do
    case "$arg" in
        -u)     INCREMENTAL=true ;;
        --sign) SIGN_AFTER=true ;;
        -h|--help) usage ;;
        *)
            if [[ -z "$LOCAL_PATH" ]]; then
                LOCAL_PATH="$arg"
            elif [[ -z "$OSS_PATH" ]]; then
                OSS_PATH="$arg"
            else
                echo "Error: unexpected argument: $arg" >&2
                usage
            fi
            ;;
    esac
done

[[ -z "$LOCAL_PATH" ]] && usage

# Verify local path exists
if [[ ! -e "$LOCAL_PATH" ]]; then
    echo "Error: $LOCAL_PATH does not exist" >&2
    exit 1
fi

# --- Default OSS path ---
if [[ -z "$OSS_PATH" ]]; then
    # Try to read cached default bucket from config, then fall back to listing
    DEFAULT_BUCKET=""
    if [[ -n "$OSS_CONFIG_FILE" ]]; then
        DEFAULT_BUCKET=$(grep -oP '^defaultBucket\s*=\s*\K\S+' "$OSS_CONFIG_FILE" 2>/dev/null || true)
    fi
    if [[ -z "$DEFAULT_BUCKET" ]]; then
        # List buckets and use first one
        DEFAULT_BUCKET=$(ossutil "${OSS_CONFIG_ARGS[@]}" ls -s 2>/dev/null | grep '^oss://' | head -1 | sed 's|/$||' || true)
        # Cache it into config file for next time
        if [[ -n "$DEFAULT_BUCKET" && -n "$OSS_CONFIG_FILE" ]]; then
            echo "defaultBucket = ${DEFAULT_BUCKET}" >> "$OSS_CONFIG_FILE"
            echo "Note: saved defaultBucket=${DEFAULT_BUCKET} to $OSS_CONFIG_FILE"
        fi
    fi
    if [[ -z "$DEFAULT_BUCKET" ]]; then
        echo "Error: no OSS_PATH specified and no default bucket found." >&2
        echo "  Usage: $(basename "$0") FILE_OR_DIR oss://bucket/path/" >&2
        exit 1
    fi
    FILENAME="$(basename "$LOCAL_PATH")"
    OSS_PATH="${DEFAULT_BUCKET}/downloads/${FILENAME}"
    echo "Using default path: $OSS_PATH"
fi

# --- Build command ---
ARGS=(cp)

if [[ -d "$LOCAL_PATH" ]]; then
    ARGS+=(-r)
fi

if $INCREMENTAL; then
    ARGS+=(-u)
fi

ARGS+=(-j 10)  # 10 concurrent threads

ARGS+=("$LOCAL_PATH" "$OSS_PATH")

# --- Upload ---
echo "--> Uploading $LOCAL_PATH to $OSS_PATH ..."
ossutil "${OSS_CONFIG_ARGS[@]}" "${ARGS[@]}"
echo "Done: uploaded to $OSS_PATH"

# --- Optional: generate presigned URL ---
if $SIGN_AFTER; then
    if [[ -d "$LOCAL_PATH" ]]; then
        echo ""
        echo "Note: --sign with directories is not supported. Use oss-share.sh on individual files."
    else
        echo ""
        echo "--> Generating presigned URL (12h, force download)..."
        SIGN_FNAME="$(basename "$OSS_PATH")"
        ossutil "${OSS_CONFIG_ARGS[@]}" sign --timeout 43200 \
            --query-param "response-content-disposition=attachment;filename=${SIGN_FNAME}" \
            "$OSS_PATH"
    fi
fi
