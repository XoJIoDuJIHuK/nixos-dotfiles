#!/bin/sh

# Usage: ./download_song.sh <YouTube_URL>

if [ $# -ne 1 ]; then
  echo "Usage: $0 <YouTube_URL>"
  exit 1
fi

URL="$1"
OUTPUT_TEMPLATE="%(title)s.%(ext)s"

# Temporary directory to check if subtitles were downloaded
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Function to run yt-dlp with specific subtitle options and check if subs were downloaded
download_with_subs() {
  local sub_langs="$1"
  local auto_flag="$2"

  yt-dlp \
    -x \
    -f bestaudio/best \
    --audio-quality 0 \
    --sponsorblock-remove all \
    --embed-thumbnail \
    --embed-metadata \
    --write-subs $auto_flag \
    --sub-langs "$sub_langs" \
    --convert-subs lrc \
    --output "$OUTPUT_TEMPLATE" \
    --download-archive "$TMP_DIR/archive.txt" \
    --cookies-from-browser firefox \
    "$URL" >/dev/null 2>&1

  # Return 0 if any .lrc file was created, 1 otherwise
  [ -n "$(find . -maxdepth 1 -name '*.lrc' -print -quit)" ]
}

echo "Attempting to download with Russian subtitles/lyrics..."
if download_with_subs "ru" "--write-auto-subs"; then
  echo "Russian subtitles/lyrics downloaded."
  exit 0
fi

echo "No Russian subtitles found. Trying English..."
if download_with_subs "en" "--write-auto-subs"; then
  echo "English subtitles/lyrics downloaded."
  exit 0
fi

echo "No Russian or English subtitles found. Downloading first available language..."
yt-dlp \
  -x \
  -f bestaudio/best \
  --audio-quality 0 \
  --sponsorblock-remove all \
  --embed-thumbnail \
  --embed-metadata \
  --write-subs --write-auto-subs \
  --sub-langs "all,-live_chat" \
  --convert-subs lrc \
  --output "$OUTPUT_TEMPLATE" \
  --cookies-from-browser firefox \
  "$URL"

echo "Download complete (subtitles in first available language)."
