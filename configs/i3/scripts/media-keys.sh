#!/bin/bash
# Media keys: volume, brightness, playback. Called from i3 bindsym.
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

notify() {
    command -v notify-send >/dev/null && notify-send "$@"
}

volume_pct() {
    pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null \
        | grep -oP '\d+(?=%)' | head -1
}

brightness_set() {
    local delta_pct=$1
    local dev max cur new

    if command -v brightnessctl >/dev/null; then
        if [ "$delta_pct" -lt 0 ]; then
            brightnessctl set "$((-delta_pct))%-" >/dev/null
        else
            brightnessctl set "${delta_pct}%+" >/dev/null
        fi
        local cur max pct
        cur=$(brightnessctl get)
        max=$(brightnessctl max)
        pct=$((cur * 100 / max))
        notify -t 800 "Brightness" "${pct}%"
        return
    fi

    dev=$(ls /sys/class/backlight/ 2>/dev/null | head -1)
    [ -n "$dev" ] || return
    max=$(cat "/sys/class/backlight/$dev/max_brightness")
    cur=$(cat "/sys/class/backlight/$dev/brightness")
    new=$((cur + delta_pct * max / 100))
    [ "$new" -lt 0 ] && new=0
    [ "$new" -gt "$max" ] && new=$max

    if [ -n "${XDG_SESSION_ID:-}" ]; then
        busctl --system call org.freedesktop.login1 \
            "/org/freedesktop/login1/session/$XDG_SESSION_ID" \
            org.freedesktop.login1.Session SetBrightness \
            ssu backlight "$dev" "$new" >/dev/null 2>&1
    fi

    local pct=$((new * 100 / max))
    notify -t 800 "Brightness" "${pct}%"
}

mpris_cmd() {
    local playerctl_cmd=$1 dbus_method=$2
    if command -v playerctl >/dev/null; then
        playerctl "$playerctl_cmd" 2>/dev/null && return
    fi
    local player
    for player in $(dbus-send --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus \
        org.freedesktop.DBus.ListNames 2>/dev/null \
        | sed -n 's/.*"\(org.mpris.MediaPlayer2[^"]*\)".*/\1/p'); do
        dbus-send --print-reply --dest="$player" /org/mpris/MediaPlayer2 \
            "org.mpris.MediaPlayer2.Player.$dbus_method" >/dev/null 2>&1 && return
    done
}

case "$1" in
    volume-up)
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        notify -t 800 -h int:value:"$(volume_pct)" "Volume" ""
        ;;
    volume-down)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        notify -t 800 -h int:value:"$(volume_pct)" "Volume" ""
        ;;
    volume-mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        notify -t 800 "Volume" "Mute toggled"
        ;;
    mic-mute)
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        killall -SIGUSR1 i3status 2>/dev/null || true
        ;;
    brightness-up)   brightness_set 5 ;;
    brightness-down) brightness_set -5 ;;
    play-pause)      mpris_cmd play-pause PlayPause ;;
    next)            mpris_cmd next Next ;;
    prev)            mpris_cmd previous Previous ;;
    stop)            mpris_cmd stop Stop ;;
esac
