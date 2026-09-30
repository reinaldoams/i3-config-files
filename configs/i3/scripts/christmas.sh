#!/bin/bash
frames=("🌲" "🎄")
i=0

(
  read line && echo "$line"
  read line && echo "$line"
  read line && echo "$line"
  while :; do
    read line || exit 1
    frame="${frames[$((i % ${#frames[@]}))]}"
    i=$((i + 1))
    echo "${line%\]},{\"name\":\"arvore\",\"full_text\":\"$frame\"}]"
  done
)
