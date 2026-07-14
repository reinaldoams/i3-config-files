#!/bin/bash
xrandr --output DisplayPort-0 --mode 2560x1440 --rate 165 --left-of HDMI-A-0 \
  --output HDMI-A-0 --mode 1680x1050 --rate 59.95

pkill xwinwrap 2>/dev/null
pkill -f 'mpv.*wallpaper-video\.mp4' 2>/dev/null
feh --bg-fill "$HOME/Pictures/wallpaper-i3.png"
