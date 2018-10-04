#!/bin/bash
# shellcheck disable=SC2009
USERID="$(/usr/bin/id -u "$(ps -ef | /bin/grep "[p]ulseaudio --start" | /usr/bin/awk '{print $1}')")"
export PULSE_RUNTIME_PATH=/run/user/"$USERID"/pulse
STATUS="$(echo "$@" | /bin/sed -E 's/.*\s((un)?plug).*/\1/')"
case "$STATUS" in
	unplug)
		MUTE=1
		;;
	plug)
		MUTE=0
		;;
	*)
		exit 0
		;;
esac
SINKS=$(/usr/bin/pacmd list-sinks | /bin/sed -n -E 's/^([0-9]+) sink\(s\) available./\1/p')
for ((i=0; i<SINKS; i++)); do
	/usr/bin/pacmd set-sink-mute $i $MUTE
done
