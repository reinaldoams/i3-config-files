#!/bin/bash
VIDEO="/home/reinaldo/Videos/wallpaper-video.mp4"

get_connected_geometries() {
  xrandr --query | awk '
    / connected/ {
      for (i = 3; i <= NF; i++) {
        if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/) {
          gsub(/\*/, "", $i)
          print $i
          break
        }
      }
    }
  '
}

start_on_geom() {
  xwinwrap -g "$1" -ni -s -st -sp -b -nf -ov -- \
    mpv -wid WID --loop-file --no-audio --no-osc --no-osd-bar \
    --player-operation-mode=cplayer --panscan=1.0 --keepaspect=no "$VIDEO" &
}

mapfile -t geoms < <(get_connected_geometries)

if [ "${#geoms[@]}" -eq 0 ]; then
  exit 1
fi

for geom in "${geoms[@]}"; do
  start_on_geom "$geom"
done

sleep 1
xdotool search --class 'xwinwrap' windowlower 2>/dev/null
