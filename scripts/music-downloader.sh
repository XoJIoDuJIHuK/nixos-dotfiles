#!/bin/sh

# Usage: ./download_song.sh <YouTube_URL>

if [ $# -ne 1 ]; then
  echo "Usage: $0 <YouTube_URL>"
  exit 1
fi

URL="$1"

# Download highest quality audio, apply SponsorBlock, embed thumbnail and metadata,
# download and convert subtitles/lyrics to LRC if available (in any language)
yt-dlp \
  -x \
  -f bestaudio/best \
  --audio-quality 0 \
  --sponsorblock-remove all \
  --embed-thumbnail \
  --embed-metadata \
  --write-subs \
  --write-auto-subs \
  --sub-langs "all,-live_chat" \
  --convert-subs lrc \
  "$URL"
