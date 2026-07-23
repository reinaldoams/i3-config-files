#!/bin/bash
# Ordered login display setup (i3 exec lines run in parallel, so this keeps sequence).

xrandr --output HDMI-1 --primary --mode 2560x1440 --rate 180 --output eDP-1 --off

mkdir -p "$HOME/.cache"
echo external > "$HOME/.cache/i3-display-mode"

/home/reinaldo/.config/i3/scripts/set-keyboard-layout.sh
/home/reinaldo/.config/i3/scripts/keep-screen-on.sh
/home/reinaldo/.config/i3/scripts/set-wallpaper.sh

i3-msg workspace number 1
