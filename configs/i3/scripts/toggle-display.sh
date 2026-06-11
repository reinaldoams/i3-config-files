#!/bin/bash

STATE_FILE="$HOME/.cache/i3-display-mode"
LAPTOP="eDP-1"
EXTERNAL="HDMI-1"

mkdir -p "$(dirname "$STATE_FILE")"

mode=$(cat "$STATE_FILE" 2>/dev/null || echo "external")
if [ "$mode" = "laptop" ]; then
  xrandr --output "$EXTERNAL" --primary --mode 2560x1440 --rate 180 --output "$LAPTOP" --off
  notify-send -t 1500 "Display" "External only"
  echo "external" > "$STATE_FILE"
else
  xrandr --output "$LAPTOP" --primary --auto --output "$EXTERNAL" --off
  notify-send -t 1500 "Display" "Laptop only"
  echo "laptop" > "$STATE_FILE"
fi

/home/reinaldo/.config/i3/scripts/set-keyboard-layout.sh
/home/reinaldo/.config/i3/scripts/keep-screen-on.sh
/home/reinaldo/.config/i3/scripts/set-wallpaper.sh
