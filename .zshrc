### ZSH startup profiling
if [ -n "${ZSH_PROFILE_STARTUP:+x}" ]; then
	zmodload zsh/zprof
fi
### ZSH startup profiling


# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="agnoster"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.oh-my-zsh-custom

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(docker fzf git jq ssh-agent wd zsh-autosuggestions zsh-syntax-highlighting)

# User configuration

if [[ -d "$HOME/Scripts/bin" ]]; then
	export PATH="$PATH:$HOME/Scripts/bin"
fi
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# Disable path highliting
# See: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]='none'

# Set lighter zsh-autosuggestions foreground color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
if [[ -f $HOME/.aliases ]]; then
	source $HOME/.aliases
fi
if [[ -f $HOME/.local_aliases ]]; then
	source $HOME/.local_aliases
fi

if [[ -f $HOME/.profile ]]; then
	source $HOME/.profile
fi

# kubectl completion
if [[ $commands[kubectl] ]]; then
	alias k=kubectl
	source <(kubectl completion zsh)
	compdef k='kubectl'
fi

# flux
[[ $commands[flux] ]] && source <(flux completion zsh)

if [[ "$(uname -s)" == "Darwin" ]]; then
	h=()
	# SSH hostname completion for Mac OS X
	if [[ -r ~/.ssh/config ]]; then
		h=($h ${${${(@M)${(f)"$(cat ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
	fi
	if [[ -r ~/.ssh/known_hosts ]]; then
		h=($h ${${${(f)"$(cat ~/.ssh/known_hosts{,2} || true)"}%%\ *}%%,*}) 2>/dev/null
	fi
	if [[ $#h -gt 0 ]]; then
		zstyle ':completion:*:ssh:*' hosts $h
		zstyle ':completion:*:slogin:*' hosts $h
		zstyle ':completion:*:scp:*' hosts $h
		zstyle ':completion:*:rsync:*' hosts $h
	fi
	# Force gsed usage if installed
	if command -v gsed 1>/dev/null 2>&1; then
		alias sed=gsed
	fi
fi

eval "$(starship init zsh)"

### ZSH startup profiling
if [ -n "${ZSH_PROFILE_STARTUP:+x}" ]; then
	zprof
fi
### ZSH startup profiling
