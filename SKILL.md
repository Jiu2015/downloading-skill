---
name: downloading
description: >
  Find and download virtually any digital resource from the internet — ebooks, academic papers,
  movies, TV shows, music, software, images, fonts, courses, and more. Covers both English and
  Chinese internet ecosystems. Includes CLI tool workflows (yt-dlp, aria2, gallery-dl, spotdl),
  resource site directories, cloud drive search engines, search techniques (Google dorks), and
  Alibaba Cloud OSS integration for uploading and sharing downloaded files. Use when the user
  wants to: (1) download a video, audio, or media from a URL, (2) find and download an ebook or
  academic paper, (3) find and download software, (4) search for any digital resource, (5) batch
  download images or media from a gallery/site, (6) download torrents or magnet links, (7) find
  free stock assets (images, video, audio, fonts), (8) search Chinese cloud drives for resources,
  (9) upload files to OSS and generate share links, or (10) any task involving finding or
  downloading digital content from the internet.
metadata:
  openclaw:
    requires:
      bins: [curl, wget]
      anyBins: [yt-dlp, gallery-dl]
    install:
      - kind: brew
        formula: yt-dlp
        bins: [yt-dlp]
      - kind: brew
        formula: aria2
        bins: [aria2c]
      - kind: brew
        formula: ffmpeg
        bins: [ffmpeg]
      - kind: pip
        package: gallery-dl
        bins: [gallery-dl]
      - kind: pip
        package: spotdl
        bins: [spotdl]
---

# Downloading

Find it. Download it. Any resource, any format. Optionally upload to OSS and share.

## OpenClaw Environment

When running in OpenClaw Docker, all scripts auto-detect the environment and adjust paths:

| Setting | Path |
|---------|------|
| Default download dir | `/home/node/.openclaw/workspace/downloads/` |
| Python tools (yt-dlp, gallery-dl, spotdl) | `/home/node/.openclaw/pyenv/bin/` |
| Bilibili cookies | `/home/node/.openclaw/workspace/.bili_cookies.txt` |
| OSS config | `/home/node/.openclaw/workspace/.ossutilconfig` |

No manual path configuration needed — scripts handle this automatically.

## Toolkit

```bash
# Install all tools at once (macOS / Linux / OpenClaw)
bash scripts/install-toolkit.sh
```

| Tool | Install | Purpose |
|------|---------|---------|
| `yt-dlp` | `brew install yt-dlp` | Video/audio from 1800+ sites |
| `aria2c` | `brew install aria2` | Multi-thread downloads, torrents |
| `gallery-dl` | `pip3 install gallery-dl` | Batch image/media, 170+ sites |
| `spotdl` | `pip3 install spotdl` | Spotify playlists to local files |
| `wget` | `brew install wget` | Recursive downloads, site mirroring |
| `curl` | pre-installed | HTTP requests, API calls |
| `ffmpeg` | `brew install ffmpeg` | Media conversion |
| `jq` | `brew install jq` | JSON parsing for automation |
| `ossutil` | see install-toolkit.sh | Alibaba Cloud OSS management |

## Decision Tree

| Want to... | Tool / Approach |
|------------|----------------|
| Download YouTube / social media video | `scripts/dl-video.sh URL` |
| Extract audio from any video URL | `scripts/dl-audio.sh URL` |
| Download Spotify playlist/album/track | `spotdl URL` |
| Batch download images from a gallery | `scripts/dl-gallery.sh URL` |
| Download a direct file URL (fast) | `scripts/dl-file.sh URL` (aria2, 16 connections) |
| Download a torrent or magnet link | `scripts/dl-torrent.sh "magnet:..."` |
| Download subtitles for a video | `scripts/dl-subtitle.sh URL_OR_QUERY` |
| Upload downloaded files to OSS | `scripts/oss-upload.sh FILE [OSS_PATH]` |
| Generate a share link for OSS file | `scripts/oss-share.sh OSS_PATH [DURATION]` |
| Browse files stored in OSS | `scripts/oss-browse.sh [OSS_PATH]` |
| Find an ebook or paper | see [references/ebooks.md](references/ebooks.md) |
| Find a movie or TV show | see [references/video.md](references/video.md) |
| Find music / game soundtracks / OST | see [references/music.md](references/music.md) |
| Find software or an app | see [references/software.md](references/software.md) |
| Find stock images/video/audio/fonts | see [references/media-assets.md](references/media-assets.md) |
| Search Chinese cloud drives | see [references/cloud-search.md](references/cloud-search.md) |
| Find online courses | see [references/education.md](references/education.md) |
| Something else / not sure | see [references/search-techniques.md](references/search-techniques.md) |

## Scripts

All in `scripts/`. Each does one thing. Compose as needed.

| Script | What it does | Key args |
|--------|-------------|----------|
| `install-toolkit.sh` | Install all CLI tools + ossutil | -- |
| `dl-video.sh URL [QUALITY]` | Download video (auto cookies for Bilibili) | `best`/`1080`/`720`/`480` |
| `dl-audio.sh URL [FORMAT]` | Extract audio | `mp3`/`opus`/`flac`/`best` |
| `dl-file.sh URL [OUTPUT]` | Fast multi-thread download | aria2 16x, wget fallback |
| `dl-gallery.sh URL [DIR] [ARGS...]` | Batch download images | extra args to gallery-dl |
| `dl-torrent.sh MAGNET [DIR]` | Download torrent/magnet | via aria2 |
| `dl-subtitle.sh QUERY [LANG]` | Search & download subtitles | `en`/`zh`/`ja` etc. |
| `oss-upload.sh FILE [OSS_PATH]` | Upload to Alibaba Cloud OSS | `-u` incremental, `--sign` |
| `oss-share.sh OSS_PATH [DURATION]` | Generate presigned URL | `1h`/`6h`/`12h`/`1d`/`7d` |
| `oss-browse.sh [OSS_PATH]` | List/search files in OSS | `--du` for storage usage |

## Quick One-Liners

```bash
# Best quality video
yt-dlp -f "bv*+ba/b" "URL"

# 1080p video + subtitles
yt-dlp -f "bv[height<=1080]+ba/b" --write-subs --sub-langs "en,zh" "URL"

# Extract audio as MP3
yt-dlp -x --audio-format mp3 "URL"

# Download YouTube playlist
yt-dlp --yes-playlist "URL"

# Fast file download (16 connections)
aria2c -x16 -s16 -k1M "URL"

# Download magnet
aria2c --seed-time=0 "magnet:?xt=..."

# Batch images from gallery
gallery-dl "URL"

# Spotify album to local MP3s
spotdl "SPOTIFY_URL"

# All PDFs from a page
wget -r -l1 -A "*.pdf" "URL"

# Video metadata as JSON (automation)
yt-dlp -j "URL"

# Get direct URL without downloading
yt-dlp -g "URL"

# Upload and get share link
scripts/oss-upload.sh file.zip --sign

# Browse OSS storage
scripts/oss-browse.sh oss://bucket/downloads/
```

## Agent Automation Patterns

**Video pipeline:** `yt-dlp -j URL` -> parse JSON -> select format -> `yt-dlp -f FORMAT URL -o OUTPUT`

**Ebook search:** Search Anna's Archive / Z-Library -> get download page -> extract link -> `aria2c`

**Bulk media:** `gallery-dl --dump-json URL` -> review items -> `gallery-dl -d OUTPUT URL`

**Music:** `spotdl SPOTIFY_URL` (auto YouTube match + metadata) or `yt-dlp -x --audio-format mp3 YOUTUBE_URL`

**Download + Share:** Download file -> `oss-upload.sh FILE --sign` -> share presigned URL with user

**Batch upload:** Download multiple files -> `oss-upload.sh ./downloads/ oss://bucket/batch/ -u`

## Domain Instability

Many resource sites rotate domains. When a URL fails:
1. Search: `[site name] mirror 2026` or `[site name] new domain`
2. Check Reddit/Twitter for community mirror lists
3. Anna's Archive = most resilient ebook meta-search
4. For Chinese cloud search: check the navigation sites listed in `cloud-search.md`

## References

| File | Content |
|------|---------|
| [ebooks.md](references/ebooks.md) | Ebook sites, academic papers, audiobooks, manga, Chinese books |
| [video.md](references/video.md) | Torrent sites, DDL, subtitles, anime, Chinese video |
| [music.md](references/music.md) | Free music, download tools, Chinese music, podcasts |
| [software.md](references/software.md) | Software archives, package managers, Chinese sites |
| [media-assets.md](references/media-assets.md) | Stock images, video, audio, fonts |
| [cloud-search.md](references/cloud-search.md) | Chinese cloud drive search engines |
| [education.md](references/education.md) | Free courses and MOOCs |
| [tools-reference.md](references/tools-reference.md) | Detailed CLI syntax, advanced flags, ossutil |
| [search-techniques.md](references/search-techniques.md) | Google dorks, search strategies |
