#!/bin/sh
# Simple emoji picker
# Common emojis for quick access
emojis="😀\n😂\n😍\n🤔\n👍\n👎\n🎉\n❤️\n🔥\n✨\n🚀\n💻\n☕\n🍕\n🎮\n🎵\n✅\n❌\n⚡\n💡"
selected=$(echo -e "$emojis" | rofi -dmenu -config ~/.config/rofi/config-short.rasi -p "Emoji" -i || echo "")
if [ -n "$selected" ]; then
    echo -n "$selected" | wl-copy
fi


