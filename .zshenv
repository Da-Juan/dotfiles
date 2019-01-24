# Hide user from Oh my zsh prompt
export DEFAULT_USER=$USER

if [ "$(uname -m)" = "Linux" ]; then
	export VDPAU_DRIVER=va_gl
fi

# pyenv 
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Allow X server local connections
if [ ! -z "$DISPLAY" ]; then
       if ! xhost | grep -q LOCAL:; then
               xhost local:root > /dev/null
       fi
fi
