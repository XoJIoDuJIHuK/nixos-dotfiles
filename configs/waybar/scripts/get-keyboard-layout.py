#!/usr/bin/env python3
import datetime
import json
import subprocess

languages_mapping = {
    "RUSSIAN": "🇷🇺",
    "ENGLISH (US)": "🇺🇸",
    "?": "🏳️",
}


def get_current_layout() -> str:
    # Call hyprctl and parse JSON output
    try:
        out = subprocess.run(
            ["hyprctl", "devices", "-j"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            check=True,
            text=True,
        ).stdout
    except subprocess.CalledProcessError:
        return "?"

    data = json.loads(out)
    # Look for the “main” keyboard first
    for kb in data.get("keyboards", []):
        if kb.get("main", False):
            return kb.get("active_keymap", "?")
    # Fallback to the first one
    if data.get("keyboards"):
        return data["keyboards"][0].get("active_keymap", "?")
    return "?"


if __name__ == "__main__":
    with open("/home/Aleh/lang.log", "+a") as file:
        file.write(datetime.datetime.now().strftime("%d/%m/%Y, %H:%M:%S\n"))

    layout = get_current_layout().upper()
    print(json.dumps({"text": "LMAO POSOSI", "tooltip": "Hello", "class": "active"}))
    # print(languages_mapping.get(layout, "NULL"))
