#!/bin/bash
# Read Fn+media keys from BT Consumer Control when they never reach X/xev.
# Fn+F10/F11/F12 on the main keyboard interface should use KEY_VOLUME* scancodes
# and are handled by the XF86Audio* bindsyms in i3 instead.
# Requires: sudo usermod -aG input "$USER"  then log out and back in.

MEDIA_SCRIPT="/home/reinaldo/.config/i3/scripts/media-keys.sh"

find_consumer_event() {
    local path name
    for path in /sys/class/input/event*/device/name; do
        name=$(cat "$path" 2>/dev/null) || continue
        case "$name" in
            *"Consumer Control"*)
                echo "/dev/input/$(basename "$(dirname "$(dirname "$path")")")"
                return
                ;;
        esac
    done
}

EVENT_DEV=$(find_consumer_event)
[ -n "$EVENT_DEV" ] || { echo "media-keys-evdev: no Consumer Control device" >&2; exit 1; }
[ -r "$EVENT_DEV" ] || {
    echo "media-keys-evdev: cannot read $EVENT_DEV — run: sudo usermod -aG input $USER" >&2
    exit 1
}

exec python3 - "$EVENT_DEV" "$MEDIA_SCRIPT" <<'PY'
import struct
import subprocess
import sys
import time

dev, media_script = sys.argv[1], sys.argv[2]
# EV_KEY: KEY_MUTE=113, KEY_VOLUMEDOWN=114, KEY_VOLUMEUP=115
actions = {113: "volume-mute", 114: "volume-down", 115: "volume-up"}

while True:
    try:
        # Keep the fd open — reopening between reads drops EV_KEY after EV_MSC/SYN.
        with open(dev, "rb", buffering=0) as f:
            while True:
                data = f.read(24)
                if len(data) < 24:
                    break
                _sec, _usec, ev_type, code, value = struct.unpack("qqHHi", data)
                if ev_type != 1 or value != 1:  # EV_KEY, key press
                    continue
                action = actions.get(code)
                if action:
                    subprocess.Popen([media_script, action])
    except OSError:
        time.sleep(2)
PY
