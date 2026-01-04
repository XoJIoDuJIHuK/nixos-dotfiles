#!/usr/bin/env python3
import sys
import subprocess
import json

SERVICE = "sing-box"


def is_active() -> bool:
    """
    Check whether the SERVICE is currently active.
    Returns True if active, False otherwise.
    """
    return (
        subprocess.run(
            ["systemctl", "is-active", "--quiet", SERVICE],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ).returncode
        == 0
    )


def toggle_service() -> None:
    """
    Toggle the SERVICE: if it's running, stop it; otherwise, start it.
    Then send a signal to Waybar so that it refreshes all custom modules.
    """
    if is_active():
        subprocess.run(["systemctl", "stop", SERVICE])
    else:
        subprocess.run(["systemctl", "start", SERVICE])

    # TODO:
    # Signal Waybar to re-run all custom modules
    subprocess.run(["pkill", "-RTMIN+10", "waybar"])

    # this makes waybar disappear and reappear
    # subprocess.run(["/home/Aleh/.config/waybar/launch.sh"])
    # this does not do anything
    # subprocess.run(["pkill", "-SIGRTMIN+10", "waybar"])


def print_status() -> None:
    """
    Print a single line of JSON with 'text', 'tooltip', and 'class' fields
    depending on whether SERVICE is active.
    """
    if is_active():
        status_info = {
            "text": "🕊️✅",
            "tooltip": "Sing-box is running",
            "class": "active",
        }
    else:
        status_info = {
            "text": "🕊️⛔",
            "tooltip": "Sing-box is stopped",
            "class": "inactive",
        }

    print(json.dumps(status_info))


def main() -> None:
    # If first argument is "toggle", toggle the service and exit.
    if len(sys.argv) > 1 and sys.argv[1] == "toggle":
        toggle_service()
        sys.exit(0)

    # Otherwise, print the current status as JSON.
    print_status()


if __name__ == "__main__":
    main()
