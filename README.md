# Downloading

Find and download virtually any digital resource from the internet. Videos, ebooks, music, software, images, fonts, courses — from both English and Chinese internet ecosystems.

Works as a **Claude Code skill**, an **OpenClaw skill**, or a **standalone CLI toolkit**.

## Quick Start

```bash
# Install all tools
bash scripts/install-toolkit.sh

# Download a video
bash scripts/dl-video.sh "https://www.youtube.com/watch?v=..."

# Extract audio as MP3
bash scripts/dl-audio.sh "https://www.youtube.com/watch?v=..." mp3

# Fast file download (16 connections)
bash scripts/dl-file.sh "https://example.com/large-file.zip"

# Batch download images from a gallery
bash scripts/dl-gallery.sh "https://imgur.com/a/ALBUM_ID"

# Download torrent
bash scripts/dl-torrent.sh "magnet:?xt=urn:btih:..."

# Upload to Alibaba Cloud OSS and get share link
bash scripts/oss-upload.sh downloaded-file.zip --sign
```

## Features

**Download anything:**
- Video from 1800+ sites (YouTube, Bilibili, Twitter, TikTok, etc.)
- Audio extraction with format selection (MP3, FLAC, Opus, WAV)
- Batch images from 170+ gallery sites (Pixiv, Reddit, Instagram, etc.)
- Fast multi-thread file downloads (aria2c with 16 connections)
- Torrents and magnet links
- Subtitles (embedded or from subtitle databases)

**Cloud storage (Alibaba Cloud OSS):**
- Upload files/directories to OSS
- Generate time-limited presigned share URLs
- Browse and search stored files

**Resource discovery:**
- 9 curated reference guides covering ebooks, video, music, software, media assets, cloud drive search, education, search techniques, and CLI tools
- Google dork patterns for finding specific file types
- Chinese internet ecosystem coverage (cloud drive search engines, Bilibili, etc.)

## Scripts

| Script | Purpose |
|--------|---------|
| `install-toolkit.sh` | Install all CLI tools (macOS/Linux/Docker) |
| `dl-video.sh` | Download video (yt-dlp, auto Bilibili cookies) |
| `dl-audio.sh` | Extract audio from video URL |
| `dl-gallery.sh` | Batch download images (gallery-dl) |
| `dl-file.sh` | Fast multi-thread download (aria2/wget) |
| `dl-subtitle.sh` | Download or search subtitles |
| `dl-torrent.sh` | Download torrent/magnet (aria2) |
| `oss-upload.sh` | Upload to Alibaba Cloud OSS |
| `oss-share.sh` | Generate presigned download URL |
| `oss-browse.sh` | List/search files in OSS |

## Reference Guides

| Guide | Topics |
|-------|--------|
| [tools-reference.md](references/tools-reference.md) | yt-dlp, gallery-dl, aria2, curl, wget, ossutil — full CLI reference |
| [search-techniques.md](references/search-techniques.md) | Google dorks, direct link extraction, search strategies |
| [ebooks.md](references/ebooks.md) | Shadow libraries, academic papers, audiobooks, manga |
| [video.md](references/video.md) | Torrent sites, DDL, subtitles, anime |
| [music.md](references/music.md) | Free music, Spotify tools, Chinese music, VGM/OST |
| [software.md](references/software.md) | Package managers, archives, Chinese software sites |
| [media-assets.md](references/media-assets.md) | Stock images, video, audio, fonts (EN + CN) |
| [cloud-search.md](references/cloud-search.md) | Chinese cloud drive search engines |
| [education.md](references/education.md) | MOOCs, Bilibili education, downloadable courses |

## Compatibility

| Environment | Status |
|-------------|--------|
| **Claude Code** | Add with `--add-dir` — SKILL.md auto-detected |
| **OpenClaw** | Metadata block in SKILL.md frontmatter for auto-install |
| **Standalone CLI** | Run scripts directly: `bash scripts/dl-video.sh URL` |
| **macOS** | Full support (Homebrew) |
| **Linux** | Full support (apt/dnf + pip) |
| **Docker** | Auto-detects OpenClaw environment |

## Requirements

**Required:** `curl`, `wget`

**Recommended:** `yt-dlp`, `aria2c`, `gallery-dl`, `ffmpeg`

**Optional:** `spotdl`, `jq`, `ossutil`, `webtorrent-cli`

Run `bash scripts/install-toolkit.sh` to install everything.

## License

[MIT](LICENSE)
