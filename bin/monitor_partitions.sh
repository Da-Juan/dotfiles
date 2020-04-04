#!/bin/bash

if [[ -r ~/.config/partitions_monitor ]]; then
        # shellcheck source=../.config/partitions_monitor.example
        source ~/.config/partitions_monitor
else
	exit 1
fi

if [[ ${#PARTITIONS[@]} -lt 1 || -z "$MAILTO" ]]; then
	exit 1
fi

MESSAGES=""
for PARTITION in "${PARTITIONS[@]}"; do
	read -r PCENT IPCENT <<< "$(df --output=pcent,ipcent "$PARTITION" | sed 1d)"
	if [[ "${PCENT%\%}" -ge "${THRESHOLD-90}" ]]; then
		MESSAGES="${MESSAGES}WARNING partition $PARTITION usage is $PCENT\\n"
	fi
	if [[ "${IPCENT%\%}" -ge "${THRESHOLD-90}" ]]; then
		MESSAGES="${MESSAGES}WARNING partition $PARTITION inodes usage is $IPCENT\\n"
	fi
done

if [[ -n "$MESSAGES" ]]; then
	echo -e "$MESSAGES" | mail -s  "Disk usage warning!" "$MAILTO"
fi
