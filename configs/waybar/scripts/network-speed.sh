#!/bin/sh

# Auto-detect the primary network interface
INTERFACE=$(ip route | awk '/default/ {print $5; exit}')
if [ -z "$INTERFACE" ]; then
  echo '{"text":"⚠ No network","tooltip":"No active interface"}'
  exit 1
fi

# Paths to network stats
RX_FILE="/sys/class/net/${INTERFACE}/statistics/rx_bytes"
TX_FILE="/sys/class/net/${INTERFACE}/statistics/tx_bytes"

# Temporary file to store previous values
TMP_FILE="/tmp/waybar_network_${INTERFACE}.tmp"

# Read current stats
current_rx=$(<"$RX_FILE")
current_tx=$(<"$TX_FILE")
current_time=$(date +%s)

# Load previous stats if they exist
if [ -f "$TMP_FILE" ]; then
  read prev_rx prev_tx prev_time <"$TMP_FILE"
else
  prev_rx=$current_rx
  prev_tx=$current_tx
  prev_time=$current_time
fi

# Calculate differences
delta_time=$((current_time - prev_time))
[ "$delta_time" -eq 0 ] && delta_time=1 # Prevent division by zero

rx_speed=$(((current_rx - prev_rx) / delta_time)) # in bytes
tx_speed=$(((current_tx - prev_tx) / delta_time))

# Save current stats for next run
echo "$current_rx $current_tx $current_time" >"$TMP_FILE"

# Format speed human-readable
format_speed() {
  echo "$1" | awk '
    function human(s) {
      if (s >= 10^9) {return sprintf("%.1f GiB/s", s/10^9)}
      else if (s >= 10^6) {return sprintf("%.1f MiB/s", s/10^6)}
      else if (s >= 10^3) {return sprintf("%.1f KiB/s", s/10^3)}
      else {return sprintf("%d B/s", s)}
    }
    {print human($1)}'
}

upload=$(format_speed "$tx_speed")
download=$(format_speed "$rx_speed")

# Output for Waybar
echo "{\"text\":\"↑ $upload ↓ $download\", \"tooltip\":\"Upload: $upload\\nDownload: $download\"}"
