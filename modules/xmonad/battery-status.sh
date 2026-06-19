#!/usr/bin/env bash
# Get battery percentage and status

BATTERY_DEVICE="/org/freedesktop/UPower/devices/battery_BAT0"
BATTERY_INFO=$(upower -i "$BATTERY_DEVICE" 2>/dev/null)

# Extract percentage
PERCENTAGE=$(echo "$BATTERY_INFO" | grep "percentage:" | awk '{print $2}')

# Extract state (charging/discharging)
STATE=$(echo "$BATTERY_INFO" | grep "state:" | awk '{print $2}')

# Determine icon based on state and percentage
# Using actual UTF-8 characters from Font Awesome via printf
if [ "$STATE" = "charging" ]; then
  ICON=$(printf '\uf0e7')  # Lightning bolt
elif [ "$STATE" = "fully-charged" ]; then
  ICON=$(printf '\uf240')  # Full battery
elif [ -z "$PERCENTAGE" ]; then
  PERCENTAGE="N/A"
  ICON=$(printf '\uf244')  # Unknown
else
  # Convert percentage to number for comparison
  PERC_NUM="${PERCENTAGE%\%}"
  
  if [ "$PERC_NUM" -ge 90 ]; then
    ICON=$(printf '\uf240')  # Full battery
  elif [ "$PERC_NUM" -ge 70 ]; then
    ICON=$(printf '\uf241')  # 3/4 battery
  elif [ "$PERC_NUM" -ge 50 ]; then
    ICON=$(printf '\uf242')  # 1/2 battery
  elif [ "$PERC_NUM" -ge 25 ]; then
    ICON=$(printf '\uf243')  # 1/4 battery
  else
    ICON=$(printf '\uf244')  # Empty battery
  fi
fi

echo "<fn=1>$ICON</fn>  $PERCENTAGE"
