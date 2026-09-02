#!/bin/bash
# Shared HDMI geometry, sourced by dual-display.sh and toggle-display.sh.
#
# The HDMI panel is 27" 2560x1440. We keep its native mode (so the panel never
# upscales) and shrink the desktop inside it with a transform: 0.851064 = 1920/2256,
# which makes 1920 logical px cover 2256 native px. 2256x1269 native px = 23.79"
# diagonal, matching a 23.8" screen.
#
# A transform always lights the whole panel, so the output footprint is the full
# 2179x1226. To keep i3 out of the leftover margin we declare a logical RandR
# monitor covering only the right-aligned 1920x1080 region; the margin is then
# never assigned to a workspace and just shows the wallpaper.
HDMI=HDMI-A-0
HDMI_TRANSFORM=0.851064,0,0,0,0.851064,0,0,0,1   # 1920/2256
HDMI_MONITOR=HDMI-right

# Footprint the transform produces, and the usable region inside it.
HDMI_FB_W=2179
HDMI_FB_H=1226
HDMI_W=1920
HDMI_H=1080
HDMI_MM_W=526   # 2256/2560 * 597mm
HDMI_MM_H=296   # 1269/1440 * 336mm

# Bottom-right aligned, relative to the output origin.
HDMI_OFF_X=$(( HDMI_FB_W - HDMI_W ))
HDMI_OFF_Y=$(( HDMI_FB_H - HDMI_H ))

# $1 = the output's --pos x, $2 = its --pos y
set_hdmi_monitor() {
  xrandr --setmonitor "$HDMI_MONITOR" \
    "${HDMI_W}/${HDMI_MM_W}x${HDMI_H}/${HDMI_MM_H}+$(( $1 + HDMI_OFF_X ))+$(( $2 + HDMI_OFF_Y ))" \
    "$HDMI"
}

del_hdmi_monitor() {
  xrandr --delmonitor "$HDMI_MONITOR" 2>/dev/null
}
