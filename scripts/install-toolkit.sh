#!/usr/bin/env bash
# Install all download tools + ossutil. Safe to re-run (skips already installed).
# Usage: install-toolkit.sh
set -euo pipefail

echo "=== Downloading Toolkit Installer ==="

# --- Environment detection ---
OPENCLAW=false
if [[ -d "/home/node/.openclaw" ]]; then
    OPENCLAW=true
    echo "[env] OpenClaw Docker detected"
fi

# --- OS / package manager detection ---
OS="$(uname -s)"
ARCH="$(uname -m)"

if [[ "$OS" == "Darwin" ]]; then
    PKG="brew"
    if ! command -v brew &>/dev/null; then
        echo "Error: Homebrew not found. Install from https://brew.sh" >&2
        exit 1
    fi
elif command -v apt-get &>/dev/null; then
    PKG="apt"
elif command -v dnf &>/dev/null; then
    PKG="dnf"
else
    PKG="none"
fi

echo "[env] OS=$OS ARCH=$ARCH PKG=$PKG"

# --- Helpers ---
install_brew() {
    for pkg in "$@"; do
        if brew list "$pkg" &>/dev/null; then
            echo "  ok  $pkg (already installed)"
        else
            echo "  --> Installing $pkg..."
            brew install "$pkg"
        fi
    done
}

install_pip() {
    local pip_cmd="pip3"
    if $OPENCLAW; then
        pip_cmd="/home/node/.openclaw/pyenv/bin/pip3"
        [[ -x "$pip_cmd" ]] || pip_cmd="pip3"
    fi
    for pkg in "$@"; do
        if "$pip_cmd" show "$pkg" &>/dev/null 2>&1; then
            echo "  ok  $pkg (already installed)"
        else
            echo "  --> Installing $pkg..."
            "$pip_cmd" install "$pkg"
        fi
    done
}

install_npm() {
    for pkg in "$@"; do
        if npm list -g "$pkg" &>/dev/null 2>&1; then
            echo "  ok  $pkg (already installed)"
        else
            echo "  --> Installing $pkg..."
            npm install -g "$pkg"
        fi
    done
}

install_ossutil() {
    if command -v ossutil &>/dev/null; then
        echo "  ok  ossutil (already installed)"
        return
    fi

    echo "  --> Installing ossutil 2.0..."
    local url=""
    case "${OS}-${ARCH}" in
        Darwin-arm64)  url="https://gosspublic.alicdn.com/ossutil/v2/2.0.3/ossutil-2.0.3-darwin-arm64.zip" ;;
        Darwin-x86_64) url="https://gosspublic.alicdn.com/ossutil/v2/2.0.3/ossutil-2.0.3-darwin-amd64.zip" ;;
        Linux-x86_64)  url="https://gosspublic.alicdn.com/ossutil/v2/2.0.3/ossutil-2.0.3-linux-amd64.zip" ;;
        Linux-aarch64) url="https://gosspublic.alicdn.com/ossutil/v2/2.0.3/ossutil-2.0.3-linux-arm64.zip" ;;
        *)
            echo "  !!  Unsupported platform for ossutil: ${OS}-${ARCH}" >&2
            return 1
            ;;
    esac

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' RETURN

    curl -fsSL "$url" -o "$tmp_dir/ossutil.zip"
    unzip -q "$tmp_dir/ossutil.zip" -d "$tmp_dir"

    local bin
    bin="$(find "$tmp_dir" -name 'ossutil' -type f | head -1)"
    if [[ -z "$bin" ]]; then
        echo "  !!  ossutil binary not found in archive" >&2
        return 1
    fi

    chmod +x "$bin"
    local dest="/usr/local/bin/ossutil"
    if [[ -w /usr/local/bin ]]; then
        cp "$bin" "$dest"
    else
        echo "  --> Needs sudo to install to /usr/local/bin"
        sudo cp "$bin" "$dest"
    fi
    echo "  ok  ossutil installed to $dest"
}

# --- Install ---
echo ""
echo "--- Core tools ---"

if [[ "$PKG" == "brew" ]]; then
    install_brew yt-dlp aria2 wget ffmpeg jq
    install_pip gallery-dl spotdl
elif $OPENCLAW; then
    echo "[openclaw] Installing via pip..."
    install_pip yt-dlp gallery-dl spotdl
else
    echo "[linux] Installing via pip + $PKG..."
    install_pip yt-dlp gallery-dl spotdl
    if [[ "$PKG" == "apt" ]]; then
        sudo apt-get install -y aria2 wget ffmpeg jq 2>/dev/null || true
    elif [[ "$PKG" == "dnf" ]]; then
        sudo dnf install -y aria2 wget ffmpeg jq 2>/dev/null || true
    fi
fi

# Optional: webtorrent-cli
if command -v npm &>/dev/null; then
    install_npm webtorrent-cli
else
    echo "  --  npm not found, skipping webtorrent-cli (optional)"
fi

echo ""
echo "--- ossutil ---"
install_ossutil || true

# --- Summary ---
echo ""
echo "=== Installed Tools ==="
for cmd in yt-dlp aria2c gallery-dl spotdl wget curl ffmpeg jq ossutil; do
    if command -v "$cmd" &>/dev/null; then
        printf "  ok  %-12s %s\n" "$cmd" "$(command -v "$cmd")"
    else
        printf "  --  %-12s (not found)\n" "$cmd"
    fi
done
echo "=== Done ==="
