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

# Function to rename external lrc files (e.g., "Song.en.lrc" -> "Song.lrc")
# This ensures Musicolet sees the external file if the embedded tags fail.
fix_lrc_filename() {
  # Find any lrc file matching the pattern (ignoring the specific language code)
  # We look for files created in the last minute to avoid renaming old library files
  found_lrc=$(find . -maxdepth 1 -name "*.lrc" -type f -newermt "-1 minute" -print -quit)

  if [ -n "$found_lrc" ]; then
    # Get the base filename without extension from the audio file (assuming only one was just dl'd)
    # However, relying on the lrc file itself is safer.
    # Logic: Strip the .ru.lrc or .en.lrc and replace with .lrc

    # Determine intended name based on the lrc file prefix
    # This strips the last extension (.lrc) and the second to last (.en, .ru)
    new_name="$(echo "$found_lrc" | sed -E 's/\.[a-z]{2,3}\.lrc$/.lrc/')"

    if [ "$found_lrc" != "$new_name" ] && [ -n "$new_name" ]; then
      mv "$found_lrc" "$new_name"
    fi
  fi
}

# Function to run yt-dlp with specific subtitle options
download_with_subs() {
  local sub_langs="$1"
  local auto_flag="$2"

  yt-dlp \
    -x \
    --audio-format mp3 \
    --audio-quality 0 \
    --sponsorblock-remove all \
    --embed-thumbnail \
    --embed-metadata \
    --embed-subs \
    --write-subs $auto_flag \
    --sub-langs "$sub_langs" \
    --convert-subs lrc \
    --output "$OUTPUT_TEMPLATE" \
    --download-archive "$TMP_DIR/archive.txt" \
    --cookies-from-browser firefox \
    "$URL" >/dev/null 2>&1

  # Return 0 if any .lrc file was created, 1 otherwise
  if [ -n "$(find . -maxdepth 1 -name '*.lrc' -print -quit)" ]; then
    fix_lrc_filename
    return 0
  else
    return 1
  fi
}

echo "Attempting to download with Russian subtitles/lyrics..."
if download_with_subs "ru" "--write-auto-subs"; then
  echo "Russian subtitles/lyrics downloaded (Embedded & External)."
  exit 0
fi

echo "No Russian subtitles found. Trying English..."
if download_with_subs "en" "--write-auto-subs"; then
  echo "English subtitles/lyrics downloaded (Embedded & External)."
  exit 0
fi

echo "No Russian or English subtitles found. Downloading first available language..."
yt-dlp \
  -x \
  --audio-format mp3 \
  --audio-quality 0 \
  --sponsorblock-remove all \
  --embed-thumbnail \
  --embed-metadata \
  --embed-subs \
  --write-subs --write-auto-subs \
  --sub-langs "all,-live_chat" \
  --convert-subs lrc \
  --output "$OUTPUT_TEMPLATE" \
  --cookies-from-browser firefox \
  "$URL"

fix_lrc_filename
echo "Download complete."
