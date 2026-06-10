#!/bin/bash

LOG="${XDG_CACHE_HOME:-$HOME/.cache}/connect-wifi.log"
mkdir -p "$(dirname "$LOG")"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"; }

log "started (pid $$)"

for _ in $(seq 1 30); do
  systemctl is-active --quiet NetworkManager && break
  sleep 1
done
if ! systemctl is-active --quiet NetworkManager; then
  log "NetworkManager not ready after 30s"
  exit 1
fi
log "NetworkManager is active"

nmcli networking on 2>/dev/null || true
nmcli radio wifi on 2>/dev/null || true

wifi_dev=""
for _ in $(seq 1 15); do
  wifi_dev=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | awk -F: '$2=="wifi" { print $1; exit }') || true
  [ -n "$wifi_dev" ] && break
  sleep 1
done
if [ -z "$wifi_dev" ]; then
  log "no wifi device found after 15s"
  exit 1
fi
log "wifi device: $wifi_dev"

state=$(nmcli -t -f STATE device status "$wifi_dev" 2>/dev/null) || state="unknown"
log "device state: $state"

if [[ "$state" == "connected" || "$state" == "connecting" ]]; then
  log "already $state, nothing to do"
  exit 0
fi

profiles=$(nmcli -t -f NAME,AUTOCONNECT,AUTOCONNECT-PRIORITY,TYPE connection show 2>/dev/null \
  | awk -F: '$4=="802-11-wireless" && $2=="yes" { printf "%05d:%s\n", $3, $1 }' \
  | sort -r \
  | cut -d: -f2-)

if [ -z "$profiles" ]; then
  log "no autoconnect wifi profiles found"
  exit 1
fi

while IFS= read -r profile; do
  [ -z "$profile" ] && continue
  log "trying $profile"
  if nmcli -w 10 connection up "$profile" ifname "$wifi_dev" 2>>"$LOG"; then
    log "connected via $profile"
    exit 0
  fi
done <<< "$profiles"

log "all profiles failed"
exit 1
