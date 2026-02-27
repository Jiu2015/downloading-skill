#!/usr/bin/env bash
# List and search files in Alibaba Cloud OSS.
# Usage: oss-browse.sh [OSS_PATH] [--du]
#   No args:      list all buckets
#   With path:    list objects at path
#   --du:         show storage usage instead of listing
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") [OSS_PATH] [--du]"
    echo ""
    echo "  OSS_PATH  oss://bucket/ or oss://bucket/prefix/"
    echo "  --du      show storage usage"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")                    # list all buckets"
    echo "  $(basename "$0") oss://bucket/      # list objects in bucket"
    echo "  $(basename "$0") oss://bucket/ --du # check storage usage"
    exit 1
}

# --- Require ossutil ---
if ! command -v ossutil &>/dev/null; then
    echo "Error: ossutil not found. Install with: bash scripts/install-toolkit.sh" >&2
    exit 1
fi

# --- Parse args ---
OSS_PATH=""
DU_MODE=false

for arg in "$@"; do
    case "$arg" in
        --du)       DU_MODE=true ;;
        -h|--help)  usage ;;
        oss://*)    OSS_PATH="$arg" ;;
        *)
            echo "Error: unexpected argument: $arg" >&2
            usage
            ;;
    esac
done

# --- Execute ---
if $DU_MODE; then
    if [[ -z "$OSS_PATH" ]]; then
        echo "Error: --du requires an OSS_PATH" >&2
        usage
    fi
    ossutil du "$OSS_PATH"
elif [[ -z "$OSS_PATH" ]]; then
    # List all buckets
    ossutil ls
else
    # List objects at path
    ossutil ls "$OSS_PATH"
fi
