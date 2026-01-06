# Notification wrapper for caelestia-shell toaster IPC
# Usage: notify.sh <type> <title> <message> [icon]
# Types: info, success, error, warn

TYPE=${1:-info}
TITLE="$2"
MESSAGE="$3"
ICON="${4:-}"

caelestia-shell ipc --any-display call toaster "$TYPE" "$TITLE" "$MESSAGE" "$ICON"
