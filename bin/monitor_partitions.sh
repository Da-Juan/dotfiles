#!/usr/bin/env bash

if [[ -r ~/.config/partitions_monitor ]]; then
        # shellcheck source=../.config/partitions_monitor.example
        source ~/.config/partitions_monitor
else
	exit 1
fi

if [[ ${#PARTITIONS[@]} -lt 1 || -z "$MAILTO" || -z "$MAILFROM" ]]; then
	exit 1
fi

status_dir="/var/tmp/partitions_monitor"

if [ ! -d "$status_dir" ]; then
	mkdir -p "$status_dir"
fi

function check(){
	name="$1"
	threshold="$2"
	value="$3"
	status="$4"
	# 86400 seconds = 24 hours
	if [ -f "$status" ] && [ $(( "$(stat --format=%Y "$status")" + "${INTERVAL-86400}" )) -le "$(date "+%s")" ]; then
		rm "$status"
	fi
	alert=0
	if [[ "$value" -ge "$threshold" ]]; then
		alert=1
		if [ -f "$status" ] && [ "$value" -eq "$(cat "$status")" ]; then
			alert=0
		fi
		if [ "$alert" -eq 1 ]; then
			echo "$value" > "$status"
			# shellcheck disable=SC2028
			echo "WARNING partition $name usage is ${value}%\\n"
		fi
	else
		[ -f "$status" ] && rm "$status"
	fi
}

messages=""
for partition in "${PARTITIONS[@]}"; do
	read -r PCENT IPCENT <<< "$(df --output=pcent,ipcent "$partition" | sed 1d)"
	messages="${messages}$(check "$partition" "${THRESHOLD-90}" "${PCENT%\%}" "$status_dir/${partition}_pcent")"
	messages="${messages}$(check "$partition" "${ITHRESHOLD-90}" "${IPCENT%\%}" "$status_dir/${partition}_ipcent")"
done

if [[ -n "$messages" ]]; then
	echo -e "$messages" | mail -aFrom:"$MAILFROM" "Disk usage warning!" "$MAILTO"
fi
