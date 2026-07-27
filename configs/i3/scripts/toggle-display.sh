#!/bin/bash

STATE_FILE="$HOME/.cache/i3-display-mode"
LAPTOP="eDP-1"
EXTERNAL="HDMI-1"

mkdir -p "$(dirname "$STATE_FILE")"

mode=$(cat "$STATE_FILE" 2>/dev/null || echo "external")
if [ "$mode" = "laptop" ]; then
  xrandr --output "$EXTERNAL" --primary --mode 2560x1080 --rate 74.99 --output "$LAPTOP" --off
  echo "external" > "$STATE_FILE"
  gammastep -P -O 3000
else
  xrandr --output "$LAPTOP" --primary --auto --output "$EXTERNAL" --off
  echo "laptop" > "$STATE_FILE"
  gammastep -P -O 3000
fi

/home/reinaldo/.config/i3/scripts/set-keyboard-layout.sh
/home/reinaldo/.config/i3/scripts/keep-screen-on.sh
/home/reinaldo/.config/i3/scripts/set-wallpaper.sh
