#!/bin/bash
WHEREAMI="$(cat /tmp/."$USER"-whereami)"
i3-sensible-terminal --working-directory="$WHEREAMI"
