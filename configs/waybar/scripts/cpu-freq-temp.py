#!/usr/bin/env python3
"""
Waybar module for displaying CPU frequency and temperature.
"""

import json
from pathlib import Path


def get_frequency() -> str:
    """Get CPU frequency in GHz."""
    # Try sysfs scaling_cur_freq first
    freq_path = Path("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq")
    if freq_path.exists():
        try:
            freq_hz = int(freq_path.read_text().strip())
            freq_ghz = freq_hz / 1_000_000
            return f"{freq_ghz:.1f}"
        except (OSError, ValueError):
            pass

    # Fallback: read from /proc/cpuinfo
    try:
        with open("/proc/cpuinfo") as f:
            for line in f:
                if line.startswith("cpu MHz"):
                    mhz = float(line.split(":")[1].strip())
                    return f"{mhz / 1000:.1f}"
    except (OSError, ValueError, IndexError):
        pass

    return "N/A"


def get_temperature() -> str:
    """Get CPU temperature in Celsius."""
    # Try sysfs thermal zone
    temp_path = Path("/sys/class/thermal/thermal_zone0/temp")
    if temp_path.exists():
        try:
            temp_millicelsius = int(temp_path.read_text().strip())
            temp_celsius = temp_millicelsius // 1000
            if temp_celsius < 50:
                icon = "\uf2cb"
            elif temp_celsius < 70:
                icon = "\uf2c9"
            else:
                icon = "\uf2c7"
            return icon + " " + str(temp_celsius)
        except (OSError, ValueError):
            pass

    return "N/A"


def main() -> None:
    """Main entry point."""
    frequency = get_frequency()
    temperature = get_temperature()

    output = {
        "text": f"\uf4bc   {frequency}GHz  {temperature}°C",
        "tooltip": "CPU Status",
    }

    print(json.dumps(output))


if __name__ == "__main__":
    main()
