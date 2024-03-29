# Hide user from Oh my zsh prompt
export DEFAULT_USER="$USER"

# Set default editor
if [[ "$(uname -s)" == "Darwin" ]] && [[ -x /usr/local/bin/vim ]]; then
	export EDITOR="/usr/local/bin/vim"
elif [ -x /usr/bin/vim ]; then
	export EDITOR="/usr/bin/vim"
fi
if [ -n "$EDITOR" ]; then
	export VISUAL="$EDITOR"
fi

if [ "$(uname -m)" = "Linux" ]; then
	export VDPAU_DRIVER=va_gl
fi

# Add /usr/local/bin to PATH if needed
if [[ ":$PATH:" != *:"/usr/local/bin":* ]]; then
	export PATH="/usr/local/bin:$PATH"
fi

# User's bin
export PATH="$HOME/.local/bin:$PATH"

# Snap's bin
export PATH="$PATH:/var/lib/snapd/snap/bin"

# pyenv 
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
# pyenv completion
if command -v pyenv 1>/dev/null 2>&1; then
	eval "$(pyenv init -)"
fi

# krew
if [ -d "${KREW_ROOT:-$HOME/.krew}" ]; then
	export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
fi

export GPG_TTY="$(tty)"

export TODAY="$(date +"%Y%m%d")"

# Allow X server local connections
if [ -n "$DISPLAY" ]; then
       if ! xhost | grep -q LOCAL:; then
               xhost local:root > /dev/null
       fi
fi

precmd() {
	pwd > /tmp/."$USER"-whereami
}

setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
#setopt inc_append_history
setopt share_history
