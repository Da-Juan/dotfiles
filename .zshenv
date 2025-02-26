# Hide user from Oh my zsh prompt
export DEFAULT_USER="$USER"

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

# Homebrew's bin
if [ -d /opt/homebrew/bin ]; then
	export PATH="/opt/homebrew/bin:$PATH"
fi

# Cargo's bin
if [ -d "$HOME/.cargo/bin" ]; then
	export PATH="$HOME/.cargo/bin:$PATH"
fi

# pyenv 
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
# pyenv completion
if [[ $commands[pyenv] ]]; then
	eval "$(pyenv init -)"
fi

# krew
if [ -d "${KREW_ROOT:-$HOME/.krew}" ]; then
	export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
fi

# GOBIN
export GOBIN="${GOPATH:-"$HOME/go"}/bin"
if [ -d "${GOBIN}" ]; then
	export PATH="${GOBIN}:$PATH"
fi

# Set default editor
if [[ $commands[nvim] ]]; then
	export EDITOR="nvim"
fi
if [ -n "$EDITOR" ]; then
	export VISUAL="$EDITOR"
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

# History settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

HISTORY_IGNORE="(ls|pwd|exit)*"

setopt EXTENDED_HISTORY      # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY    # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY         # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS      # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS  # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE     # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS     # Do not write a duplicate event to the history file.
setopt HIST_VERIFY           # Do not execute immediately upon history expansion.
setopt APPEND_HISTORY        # append to history file (Default)
setopt HIST_NO_STORE         # Don't store history commands
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from each command line being added to the history.

export FZF_DEFAULT_COMMAND='rg --hidden -g ""'
