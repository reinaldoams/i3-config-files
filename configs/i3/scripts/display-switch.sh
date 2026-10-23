#!/usr/bin/env bash
# Switch between DisplayPort and HDMI monitors using each one's maximum
# resolution and refresh rate.
#   display-switch.sh toggle  -> only one monitor active, alternating
#   display-switch.sh both    -> both active, HDMI to the right of DisplayPort

DP=DisplayPort-0
HDMI=HDMI-A-0

# Prints "<mode> <rate>" for the largest resolution and its highest rate.
best_mode() {
    xrandr --query | awk -v out="$1" '
        $1 == out { in_out = 1; next }
        in_out && /^[^ ]/ { exit }
        in_out && $1 ~ /^[0-9]+x[0-9]+/ {
            split($1, wh, "x"); area = wh[1] * wh[2]
            for (i = 2; i <= NF; i++) {
                r = $i; gsub(/[*+]/, "", r)
                if (r == "") continue
                if (area > best_area || (area == best_area && r + 0 > best_rate + 0)) {
                    best_area = area; best_rate = r; best_mode = $1
                }
            }
        }
        END { if (best_mode) print best_mode, best_rate }'
}

# An active output has a geometry ("WxH+X+Y") on its xrandr header line.
is_active() {
    xrandr --query | grep -qE "^$1 connected( primary)? [0-9]+x[0-9]+\+"
}

# Applies the 3000K night-mode temperature to an output's CRTC. Needed because
# a freshly enabled output gets a new CRTC with a default gamma ramp.
apply_temp() {
    local crtc
    crtc=$(xrandr --verbose | awk -v out="$1" '
        $1 == out { in_out = 1; next }
        in_out && /^[^ \t]/ { exit }
        in_out && $1 == "CRTC:" { print $2; exit }')
    [ -n "$crtc" ] && gammastep -P -O 3000 -m randr:crtc="$crtc"
}

read -r DP_MODE DP_RATE <<< "$(best_mode "$DP")"
read -r HDMI_MODE HDMI_RATE <<< "$(best_mode "$HDMI")"

case "$1" in
    both)
        xrandr --output "$DP" --primary --mode "$DP_MODE" --rate "$DP_RATE" --pos 0x0 --rotate normal \
               --output "$HDMI" --mode "$HDMI_MODE" --rate "$HDMI_RATE" --right-of "$DP" --rotate left
        apply_temp "$HDMI"
        ;;
    toggle|*)
        if is_active "$DP" && ! is_active "$HDMI"; then
            xrandr --output "$HDMI" --primary --mode "$HDMI_MODE" --rate "$HDMI_RATE" --pos 0x0 --rotate left \
                   --output "$DP" --off
            apply_temp "$HDMI"
        else
            xrandr --output "$DP" --primary --mode "$DP_MODE" --rate "$DP_RATE" --pos 0x0 --rotate normal \
                   --output "$HDMI" --off
        fi
        ;;
esac

# Repaint the wallpaper so it fills every active monitor's new geometry.
"$HOME/.fehbg"
