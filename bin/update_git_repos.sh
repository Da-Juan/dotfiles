#! /usr/bin/env bash

COLORS="$(tput colors)"
if (( COLORS >= 8 && COLORS < 256 )); then
        BOLD="\033[1m"
        END="\033[0m"
        GREEN="\033[32m"
        RED="\033[31m"
        YELLOW="\033[33m"
elif (( COLORS >= 256 )); then
        BOLD="\033[1m"
        END="\033[0m"
        GREEN="\033[38;5;82m"
        RED="\033[38;5;196m"
        YELLOW="\033[38;5;220m"
fi

function error {
        MSG="${BOLD}${RED}ERROR:${END} $1"
        echo -e "$MSG" 1>&2
        echo -e "$(date "+[%FT%T%z]") $MSG"
        echo
}

function warning {
        MSG="${BOLD}${YELLOW}WARNING:${END} $1"
        echo -e "$MSG" 1>&2
        echo -e "$(date "+[%FT%T%z]") $MSG"
        echo
}

function msg {
        echo -e "${BOLD}${GREEN}->${END} $1"
}


while read -r directory; do
    if [ -d "${directory}/.git" ] && [ -f "${directory}/.git/config" ]; then
        msg "Updating ${directory}"
        (
        cd "$directory" || exit
        current_branch="$(git rev-parse --abbrev-ref HEAD)"
        default_branch="$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"
        if [ "$current_branch" != "$default_branch" ]; then
            if ! git checkout "$default_branch"; then
                warning "Cannot switch to $default_branch, skipping..."
                exit
            fi
        fi
        git pull || error "Cannot pull $default_branch"
        git remote prune origin || error "Cannot prune merged branches"
        )
    fi
done < <(find ~/Git -maxdepth 5 -type d)
