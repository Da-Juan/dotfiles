#!/bin/bash

SCREENS_ORDER=()
if [[ -r ~/.config/screens ]]; then
	# shellcheck source=../.config/screens.example
	source ~/.config/screens
fi
if [[ (${#SCREENS_ORDER[@]} -lt 1 || ${#SCREENS_SIZES[@]} -lt 1) || ${#SCREENS_ORDER[@]} -ne ${#SCREENS_SIZES[@]} ]];then
	exit 1
fi

PULSEAUDIO="/usr/bin/pulseaudio"
WALLPAPER="$HOME/.config/i3/scripts/wallpaper"
XRANDR="/usr/bin/xrandr"

get_index () {
        local seeking="$1"
        shift
        local array=( "$@" )
        local index=-1
        for ((i=0; i < ${#array[@]}; i++)); do
                if [[ "${array[$i]}" == "$seeking" ]]; then
                        index=$i
                        break
                fi  
        done
        echo "$index"
}

setup_screens () {
	mapfile -t CONNECTED_SCREENS < <($XRANDR | grep " connected " | cut -f1 -d" ")

	local POS=0
	for SCREEN in "${SCREENS_ORDER[@]}"; do
		if [[ " ${CONNECTED_SCREENS[*]} " == *" $SCREEN "* ]]; then
			SCREEN_SIZE=${SCREENS_SIZES[$(get_index "$SCREEN"  "${SCREENS_ORDER[@]}")]}
			"$XRANDR" --output "$SCREEN" --mode "$SCREEN_SIZE" --pos "$POS"x0
			((POS+=$(echo "$SCREEN_SIZE" | cut -d"x" -f1)))
		else
			"$XRANDR" --output "$SCREEN" --off
		fi
	done
}

restart_pulseaudio () {
	if [ -x $PULSEAUDIO ]; then
		$PULSEAUDIO -k
	fi
}

setup_wallpapers () {
	if [ -x "$WALLPAPER" ]; then
		"$WALLPAPER"
	fi
}

setup_screens
sleep 2
setup_wallpapers
