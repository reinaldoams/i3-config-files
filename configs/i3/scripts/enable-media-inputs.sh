#!/bin/bash
# BT keyboards expose volume/media keys on separate "Consumer Control" devices.
# libinput often disables them; without this, xev/i3 never see XF86 key presses.
export DISPLAY="${DISPLAY:-:0}"

enable_input() {
    local pattern=$1
    local line id

    while IFS= read -r line; do
        id=$(echo "$line" | grep -oP 'id=\K[0-9]+' | head -1)
        [ -n "$id" ] || continue
        # 0 0 = send events (enabled). 1 0 = disabled — do not invert this.
        xinput set-prop "$id" "libinput Send Events Mode Enabled" 0 0 2>/dev/null || true
    done < <(xinput list | grep -iF "$pattern")
}

enable_input 'Consumer Control'
enable_input 'System Control'
enable_input 'WMI hotkeys'
enable_input 'Intel HID 5 button'

# Do not also run media-keys-evdev.service: it listens to the same Consumer
# Control keys as the XF86Audio* i3 bindsyms and double-toggles mute/volume.
systemctl --user disable --now media-keys-evdev.service 2>/dev/null || true
