#!/bin/bash

SCREENS_ORDER=()
if [[ -r ~/.config/screens ]]; then
	# shellcheck source=../.config/screens.example
	source ~/.config/screens
fi
if [[ ${#SCREENS_ORDER[@]} -lt 1 ]]; then
	exit 1
fi

PULSEAUDIO="/usr/bin/pulseaudio"
WALLPAPER="$HOME/.config/i3/scripts/wallpaper"
XRANDR="/usr/bin/xrandr"

array_contains () { 
	local array="$1[@]"
	local seeking="$2"
	local in=1
	for element in "${!array}"; do
		if [[ "$element" == "$seeking" ]]; then
			in=0
			break
		fi
	done
	return $in
}

setup_screens () {
	# shellcheck disable=SC2034
	local CONNECTED_SCREENS=(  $($XRANDR | grep " connected " | cut -f1 -d" ") )

	local SETUP_SCREENS="${XRANDR} "
	local POS=0
	for SCREEN in "${SCREENS_ORDER[@]}"; do
		if array_contains CONNECTED_SCREENS "$SCREEN"; then
			SETUP_SCREENS+="--output $SCREEN --mode 1920x1080 --pos ${POS}x0 "
			((POS+=1920))
		else
			SETUP_SCREENS+="--output $SCREEN --off "
		fi
	done
	
	$SETUP_SCREENS
}

restart_pulseaudio () {
	if [ -x $PULSEAUDIO ]; then
		$PULSEAUDIO -k
	fi
}

setup_wallpapers () {
	if [ -x "$WALLPAPER" ]; then
		DISPLAY=:0.0 $WALLPAPER
	fi
}

setup_screens
sleep 1
setup_wallpapers
restart_pulseaudio
