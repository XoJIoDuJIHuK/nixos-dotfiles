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

# Extract colors from histogram
histogram=$(magick "$wallpaper" -scale 100x100! +dither -colors 32 -depth 8 -format "%c" histogram:info:)

# Function to get color by rank
get_color_by_rank() {
    rank=$1
    echo "$histogram" | sort -rn -k1,1 | head -"$rank" | tail -1 | sed 's/.*(\([0-9]*\),\([0-9]*\),\([0-9]*\)).*/\1 \2 \3/'
}

# Function to convert rgb to hex with padding
rgb_to_hex() {
    printf "#%02x%02x%02x" "$1" "$2" "$3"
}

# Function to calculate luminance (integer math)
calc_luminance() {
    echo $(( (299 * $1 + 587 * $2 + 114 * $3) / 1000 ))
}

# Function to lighten a color
lighten_color() {
    printf "#%02x%02x%02x" $(($1 + (255 - $1) * 30 / 100)) $(($2 + (255 - $2) * 30 / 100)) $(($3 + (255 - $3) * 30 / 100))
}

# Get background color (most frequent, typically darker)
bg_rgb=$(get_color_by_rank 1)
bg=$(rgb_to_hex $bg_rgb)

# Get accent colors
color1_rgb=$(get_color_by_rank 2)
color1=$(rgb_to_hex $color1_rgb)

color2_rgb=$(get_color_by_rank 3)
color2=$(rgb_to_hex $color2_rgb)

color3_rgb=$(get_color_by_rank 4)
color3=$(rgb_to_hex $color3_rgb)

color4_rgb=$(get_color_by_rank 5)
color4=$(rgb_to_hex $color4_rgb)

color5_rgb=$(get_color_by_rank 6)
color5=$(rgb_to_hex $color5_rgb)

# Calculate luminance for background
bg_r=$(echo $bg_rgb | awk '{print $1}')
bg_g=$(echo $bg_rgb | awk '{print $2}')
bg_b=$(echo $bg_rgb | awk '{print $3}')
luminance=$(calc_luminance $bg_r $bg_g $bg_b)

# Choose foreground based on luminance for readability
if [ "$luminance" -lt 128 ]; then
    fg="#FFFFFF"
else
    fg="#000000"
fi

# Generate palette
color0="#000000"
color6="#00FFFF"
color7=$fg
color8="#808080"
color9=$(lighten_color $bg_r $bg_g $bg_b)
color10="#80FF80"
color11="#FFFF80"
color12="#8080FF"
color13="#FF80FF"
color14="#80FFFF"
color15=$fg

cat > "$WAL_CACHE/colors.sh" <<EOF
background='$bg'
foreground='$fg'
color0='$color0'
color1='$color1'
color2='$color2'
color3='$color3'
color4='$color4'
color5='$color5'
color6='$color6'
color7='$color7'
color8='$color8'
color9='$color9'
color10='$color10'
color11='$color11'
color12='$color12'
color13='$color13'
color14='$color14'
color15='$color15'
EOF

cat > "$WAL_CACHE/colors-kitty.conf" <<EOF
background $bg
foreground $fg
color0 $color0
color1 $color1
color2 $color2
color3 $color3
color4 $color4
color5 $color5
color6 $color6
color7 $color7
color8 $color8
color9 $color9
color10 $color10
color11 $color11
color12 $color12
color13 $color13
color14 $color14
color15 $color15
EOF
