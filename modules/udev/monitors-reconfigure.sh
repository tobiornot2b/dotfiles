#!/bin/bash

export XDG_RUNTIME_DIR="/run/user/1000"
export PATH=/run/current-system/sw/bin:$PATH

sleep 1

MONITORS=$(hyprctl monitors | grep 'Monitor' | awk '{print $2}')

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
															
