#!/usr/bin/env bash

# Get focused output from niri
# Ret: output
get_focused_output() {
  niri msg --json focused-output | jq -r '.name'
}

# Send to waybar
# 1: focused output
send() {
  local focused_output=$1
  local css=""

  if [[ $WAYBAR_OUTPUT_NAME != "$focused_output" ]]; then
    css+="dimmed"
  fi
  echo $css
}

while true; do
  focused_output=$(get_focused_output)
  send "$focused_output"
  sleep 0.1
done
