#!/bin/sh
# Generate terminal colors from current wallpaper using ImageMagick

CACHE_FILE="$HOME/.config/hypr/cache/current_wallpaper"
WAL_CACHE="$HOME/.cache/wal"

if [ ! -f "$CACHE_FILE" ]; then
    exit 0
fi

wallpaper=$(cat "$CACHE_FILE")

if [ ! -f "$wallpaper" ]; then
    exit 0
fi

mkdir -p "$WAL_CACHE"

bg=$(magick "$wallpaper" -scale 1x1 -depth 8 -format "#%[hex:p{0,0}]" info:-)
fg=$(magick "$wallpaper" -scale 1x1 -depth 8 -negate -format "#%[hex:p{0,0}]" info:-)

cat > "$WAL_CACHE/colors.sh" <<EOF
background='$bg'
foreground='$fg'
color0='$bg'
color1='$bg'
color2='$bg'
color3='$bg'
color4='$bg'
color5='$bg'
color6='$bg'
color7='$fg'
color8='$bg'
color9='$bg'
color10='$bg'
color11='$bg'
color12='$bg'
color13='$bg'
color14='$bg'
color15='$fg'
EOF
