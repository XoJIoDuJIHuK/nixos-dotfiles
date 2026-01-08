#!/usr/bin/env nix-shell
#! nix-shell -p libnotify -i bash
# Persistent notification sender for caelestia-shell
# Usage: persistent-notify.sh [options] <summary> [body]
# Options:
#   -a, --app-name APP_NAME    Application name (default: "Persistent Notifier")
#   -i, --icon ICON            Icon to display
#   -u, --urgency LEVEL        Urgency level: low, normal, critical (default: normal)
#   -t, --expire-time TIME     Timeout in ms (0 for infinite, default: 0)
#   -h, --hint TYPE:NAME:VALUE Extra data hint
#   -p, --print-id             Print notification ID
#   -w, --wait                 Wait for notification to be closed

APP_NAME="Persistent Notifier"
URGENCY="normal"
EXPIRE_TIME="0"
PRINT_ID=false
WAIT=false
HINTS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--app-name)
            APP_NAME="$2"
            shift 2
            ;;
        -i|--icon)
            ICON="$2"
            shift 2
            ;;
        -u|--urgency)
            URGENCY="$2"
            shift 2
            ;;
        -t|--expire-time)
            EXPIRE_TIME="$2"
            shift 2
            ;;
        -h|--hint)
            HINTS+=(-h "$2")
            shift 2
            ;;
        -p|--print-id)
            PRINT_ID=true
            shift
            ;;
        -w|--wait)
            WAIT=true
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            SUMMARY="$1"
            shift
            BODY="$@"
            break
            ;;
    esac
done

if [[ -z "$SUMMARY" ]]; then
    echo "Error: No summary provided" >&2
    echo "Usage: $0 [options] <summary> [body]" >&2
    exit 1
fi

# Build notify-send command
CMD=("notify-send" "-a" "$APP_NAME" "-u" "$URGENCY" "-t" "$EXPIRE_TIME")
[[ -n "$ICON" ]] && CMD+=("-i" "$ICON")
[[ "$PRINT_ID" == true ]] && CMD+=("-p")
[[ "$WAIT" == true ]] && CMD+=("-w")
[[ ${#HINTS[@]} -gt 0 ]] && CMD+=("${HINTS[@]}")
CMD+=("$SUMMARY")
[[ -n "$BODY" ]] && CMD+=("$BODY")

# Execute
"${CMD[@]}"
