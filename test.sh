#!/bin/bash
#
# Inspired from the script by @jessfraz
#
set -e
set -o pipefail

ERRORS=()
# find all executables and run `shellcheck`
for f in $(find . -type f -not \( -ipath "*.git*" -o -ipath "*.oh-my-zsh*" \)| sort -u); do
	if file "$f" | grep --quiet shell; then
		{
			shellcheck "$f" && echo "[OK]: sucessfully linted $f"
		} || {
			# add to errors
			ERRORS+=("$f")
		}
	fi
done

if [ ${#ERRORS[@]} -eq 0 ]; then
	echo "No errors found."
else
	echo "These files failed shellcheck:"
	for ERROR in ${ERRORS[*]}; do
		echo "$ERROR"
	done
	exit 1
fi
