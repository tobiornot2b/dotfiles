#!/bin/bash

export XDG_RUNTIME_DIR="/run/user/1000"
export PATH=/run/current-system/sw/bin:$PATH

sleep 1

MONITORS_JSON=$(hyprctl monitors -j)
EXT_COUNT=$(echo "$MONITORS_JSON" | jq '[.[] | select(.name != "eDP-1")] | length')

if [ "$EXT_COUNT" -eq 1 ]; then
  # Single external monitor: place it above, eDP-1 centered below
  EXT_NAME=$(echo "$MONITORS_JSON" | jq -r '[.[] | select(.name != "eDP-1")] | .[0].name')
  EXT_W=$(echo "$MONITORS_JSON"    | jq -r '[.[] | select(.name != "eDP-1")] | .[0].width')
  EXT_H=$(echo "$MONITORS_JSON"    | jq -r '[.[] | select(.name != "eDP-1")] | .[0].height')
  EXT_HZ=$(echo "$MONITORS_JSON"   | jq -r '[.[] | select(.name != "eDP-1")] | .[0].refreshRate | round')

  EDP_W=$(echo "$MONITORS_JSON" | jq -r '.[] | select(.name == "eDP-1") | .width')
  EDP_H=$(echo "$MONITORS_JSON" | jq -r '.[] | select(.name == "eDP-1") | .height')
  EDP_HZ=$(echo "$MONITORS_JSON" | jq -r '.[] | select(.name == "eDP-1") | .refreshRate | round')

  # Center eDP-1 horizontally below the external monitor (clamp to 0)
  EDP_X=$(( (EXT_W - EDP_W) / 2 ))
  if [ "$EDP_X" -lt 0 ]; then EDP_X=0; fi

  hyprctl keyword monitor "$EXT_NAME,${EXT_W}x${EXT_H}@${EXT_HZ},0x0,1"
  hyprctl keyword monitor "eDP-1,${EDP_W}x${EDP_H}@${EDP_HZ},${EDP_X}x${EXT_H},1"

elif [ "$EXT_COUNT" -ge 2 ]; then
  # Multiple external monitors: assign workspaces
  MONITORS=$(echo "$MONITORS_JSON" | jq -r '.[].name')

  for MON in $MONITORS; do
    case "$MON" in
      DVI-I-1)
        hyprctl dispatch moveworkspacetomonitor 1 DVI-I-1
        hyprctl dispatch moveworkspacetomonitor 3 DVI-I-1
        hyprctl dispatch moveworkspacetomonitor 5 DVI-I-1
        ;;
      DVI-I-2)
        hyprctl dispatch moveworkspacetomonitor 4 DVI-I-2
        hyprctl dispatch moveworkspacetomonitor 2 DVI-I-2
        hyprctl dispatch moveworkspacetomonitor 6 DVI-I-2
        ;;
      DVI-I-3)
        hyprctl dispatch moveworkspacetomonitor 1 DVI-I-3
        hyprctl dispatch moveworkspacetomonitor 3 DVI-I-3
        hyprctl dispatch moveworkspacetomonitor 5 DVI-I-3
        ;;
      DVI-I-4)
        hyprctl dispatch moveworkspacetomonitor 4 DVI-I-4
        hyprctl dispatch moveworkspacetomonitor 2 DVI-I-4
        hyprctl dispatch moveworkspacetomonitor 6 DVI-I-4
        ;;
    esac
  done
fi
