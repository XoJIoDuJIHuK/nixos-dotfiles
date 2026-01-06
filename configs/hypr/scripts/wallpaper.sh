#!/bin/sh
#                _ _
# __      ____ _| | |_ __   __ _ _ __   ___ _ __
# \ \ /\ / / _` | | | '_ \ / _` | '_ \ / _ \ '__|
#  \ V  V / (_| | | | |_) | (_| | |_) |  __/ |
#   \_/\_/ \__,_|_|_| .__/ \__,_| .__/ \___|_|
#                   |_|         |_|

# Simple wallpaper setter without ML4W cache dependencies

# -----------------------------------------------------
# Configuration
# -----------------------------------------------------
DEFAULT_WALLPAPER="$HOME/wallpaper/default.jpg"
CACHE_FILE="$HOME/.config/hypr/cache/current_wallpaper"

# -----------------------------------------------------
# Get wallpaper to use
# -----------------------------------------------------
if [ -z "$1" ]; then
    if [ -f "$CACHE_FILE" ]; then
        wallpaper=$(cat "$CACHE_FILE")
    else
        wallpaper="$DEFAULT_WALLPAPER"
    fi
else
    wallpaper="$1"
fi

echo ":: Setting wallpaper: $wallpaper"

# -----------------------------------------------------
# Save wallpaper to cache
# -----------------------------------------------------
mkdir -p "$(dirname "$CACHE_FILE")"
echo "$wallpaper" > "$CACHE_FILE"

# -----------------------------------------------------
# Set wallpaper with waypaper
# -----------------------------------------------------
waypaper --wallpaper "$wallpaper"

# -----------------------------------------------------
# Execute pywal for color generation
# -----------------------------------------------------
if command -v wal >/dev/null 2>&1; then
    echo ":: Generating pywal colors"
    wal -q -i "$wallpaper"
    if [ -f "$HOME/.cache/wal/colors.sh" ]; then
        source "$HOME/.cache/wal/colors.sh"
    fi
fi

# -----------------------------------------------------
# Reload Waybar
# -----------------------------------------------------
if pgrep -x waybar >/dev/null; then
    echo ":: Reloading Waybar"
    killall -SIGUSR2 waybar
fi

# -----------------------------------------------------
# Pywalfox (optional)
# -----------------------------------------------------
if type pywalfox >/dev/null 2>&1; then
    pywalfox update
fi

# -----------------------------------------------------
# Create square wallpaper for hyprlock
# -----------------------------------------------------
square_wallpaper="$HOME/.config/hypr/cache/square_wallpaper.png"
mkdir -p "$(dirname "$square_wallpaper")"
if command -v magick >/dev/null 2>&1; then
    magick "$wallpaper" -gravity Center -extent 1:1 "$square_wallpaper"
fi
