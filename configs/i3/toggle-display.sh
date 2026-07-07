#!/bin/bash
STATE_FILE="$HOME/.cache/i3-display-mode"
HDMI="HDMI-A-0"
DP="DisplayPort-0"

mkdir -p "$(dirname "$STATE_FILE")"
mode=$(cat "$STATE_FILE" 2>/dev/null || echo "dp")

if [ "$mode" = "dp" ]; then
  xrandr --output "$HDMI" --primary --mode 1680x1050 --rate 59.95 --output "$DP" --off
  notify-send -t 1500 "Display" "HDMI only"
  echo "hdmi" > "$STATE_FILE"
else
  xrandr --output "$DP" --primary --mode 2560x1440 --rate 180 --output "$HDMI" --off
  notify-send -t 1500 "Display" "DisplayPort only"
  echo "dp" > "$STATE_FILE"
fi
