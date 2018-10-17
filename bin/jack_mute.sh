#!/bin/bash
# shellcheck disable=SC2009
PULSEUSER="$(ps -ef | /bin/grep "[p]ulseaudio --start" | /usr/bin/awk '{print $1}')"
PULSEUSERID="$(/usr/bin/id -u "$PULSEUSER")"
PULSE_RUNTIME_PATH=/run/user/"$PULSEUSERID"/pulse
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
SINKS=( $(/bin/su "$PULSEUSER" /bin/bash -c "PULSE_RUNTIME_PATH=$PULSE_RUNTIME_PATH /usr/bin/pacmd list-sinks" | /bin/sed -n -E 's/^\s+\*?\s+index:\s([0-9]+)/\1/p') )
for i in "${SINKS[@]}"; do
	/bin/su "$PULSEUSER" /bin/bash -c "PULSE_RUNTIME_PATH=$PULSE_RUNTIME_PATH /usr/bin/pacmd set-sink-mute $i $MUTE"
done
