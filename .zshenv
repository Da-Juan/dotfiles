# Hide user from Oh my zsh prompt
export DEFAULT_USER=$USER

# Set default editor
if [ -x /usr/bin/vim ]; then
	export EDITOR="/usr/bin/vim"
fi
if [ -n "$EDITOR" ]; then
	export VISUAL="$EDITOR"
fi

if [ "$(uname -m)" = "Linux" ]; then
	export VDPAU_DRIVER=va_gl
fi

# User's bin
export PATH="$HOME/.local/bin:$PATH"

# pyenv 
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
# pyenv completion
if command -v pyenv 1>/dev/null 2>&1; then
	eval "$(pyenv init -)"
fi

export GPG_TTY="$(tty)"

export TODAY="$(date +"%Y%m%d")"

# Allow X server local connections
if [ -n "$DISPLAY" ]; then
       if ! xhost | grep -q LOCAL:; then
               xhost local:root > /dev/null
       fi
fi
