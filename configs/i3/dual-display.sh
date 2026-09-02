#!/bin/bash
source "$HOME/.config/i3/hdmi-mode.sh"

del_hdmi_monitor
xrandr --output DisplayPort-0 --primary --mode 2560x1440 --rate 179.85 --rotate normal --pos 0x0 --scale 1x1 \
  --output "$HDMI" --set "scaling mode" "None" --mode 2560x1440 --rate 144.00 --rotate normal \
  --transform $HDMI_TRANSFORM --pos 2560x0
set_hdmi_monitor 2560 0

pkill xwinwrap 2>/dev/null
pkill -f 'mpv.*wallpaper-video\.mp4' 2>/dev/null
feh --bg-fill "$HOME/Pictures/wallpaper-i3.png"
