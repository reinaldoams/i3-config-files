#!/bin/bash
# Disable X screensaver and DPMS blanking (re-apply after xrandr or autostart resets it).
xset s off
xset -dpms
xset s noblank
