#!/usr/bin/env bash
# shellcheck disable=SC2317

CLONE_DIR="${1:-$HOME/Git/github.com/Da-juan}"
CLONE_DIR="${CLONE_DIR%/}"

LOG_FILE="$HOME/dotfiles-setup$(date "+%s").log"

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

SETUP_ZSH=0
SETUP_PYTHON=0
SETUP_VIM=0
SETUP_NEOVIM=0
SETUP_I3=0
SETUP_PKG=1

use_sudo=0

# mapfile implementation for bash 3.x because macOS...
if ! (enable | grep -q 'enable mapfile'); then
  function mapfile() {
    local    DELIM="${DELIM-$'\n'}";     opt_d() {    DELIM="$1"; }
    local    COUNT="${COUNT-"0"}";       opt_n() {    COUNT="$1"; }
    local   ORIGIN="${ORIGIN-"0"}";      opt_O() {   ORIGIN="$1"; }
    local     SKIP="${SKIP-"0"}";        opt_s() {     SKIP="$1"; }
    local    STRIP="${STRIP-"0"}";       opt_t() {    STRIP=1;    }
    local  FROM_FD="${FROM_FD-"0"}";     opt_u() {  FROM_FD="$1"; }
    local CALLBACK="${CALLBACK-}";       opt_C() { CALLBACK="$1"; }
    local  QUANTUM="${QUANTUM-"5000"}";  opt_c() {  QUANTUM="$1"; }

    unset OPTIND; local extra_args=()
    while getopts ":d:n:O:s:tu:C:c:" opt; do
      case "$opt" in
        :)  echo "${FUNCNAME[0]}: option '-$OPTARG' requires an argument" >&2; exit 1 ;;
       \?)  echo "${FUNCNAME[0]}: ignoring unknown argument '-$OPTARG'" >&2 ;;
        ?)  "opt_${opt}" "$OPTARG" ;;
      esac
    done

    shift "$((OPTIND - 1))"; set -- ${extra_args[@]+"${extra_args[@]}"} "$@"

    local var="${1:-MAPFILE}"

    # Bash 3.x doesn't have `declare -g` for "global" scope...
    eval "$(printf "%q" "$var")=()" 2>/dev/null || { echo "${FUNCNAME[0]}: '$var': not a valid identifier" >&2; exit 1; }

    local __skip="${SKIP:-0}" __counter="${ORIGIN:-0}"  __count="${COUNT:-0}"  __read="0"

    # `while read; do...` has trouble when there's no final newline,
    # and we use `$REPLY` rather than providing a variable to preserve
    # leading/trailing whitespace...
    while true; do
      if read -d "$DELIM" -r <&"$FROM_FD"
         then [[ ${STRIP:-0} -ge 1 ]] || REPLY="$REPLY$DELIM"
         elif [[ -z $REPLY ]]; then break
      fi

      (( __skip-- <= 0 )) || continue
      ((  COUNT <= 0 || __count-- > 0 )) || break

      # Yes, eval'ing untrusted content is insecure, but `mapfile` allows it...
      if [[ -n $CALLBACK ]] && (( QUANTUM > 0 && ++__read % QUANTUM == 0 ))
         then eval "$CALLBACK $__counter $(printf "%q" "$REPLY")"; fi

      # Bash 3.x doesn't allow `printf -v foo[0]`...
      # and `read -r foo[0]` mucks with whitespace
      eval "${var}[$((__counter++))]=$(printf "%q" "$REPLY")"
    done
  }

  # Alias `readarray` as well...
  readarray() { mapfile "$@"; }
fi

function error {
	MSG="${BOLD}${RED}ERROR:${END} $1"
	echo -e "$MSG" 1>&2
	echo -e "$(date "+[%FT%T%z]") $MSG" >> "$LOG_FILE"
	echo
}

function warning {
	MSG="${BOLD}${YELLOW}WARNING:${END} $1"
	echo -e "$MSG" 1>&2
	echo -e "$(date "+[%FT%T%z]") $MSG" >> "$LOG_FILE"
	echo
}

function msg {
	echo -e "${BOLD}${GREEN}->${END} $1"
}

function query_yes_no {
	local default
	local question
	local ret

	if [ "$1" = "--default" ]; then
		if [[ "$(echo "$2" | awk '{print tolower($0)}')" =~ [yn] ]];then
			case "$(echo "$2" | awk '{print tolower($0)}')" in
				"y")
					default="[Y/n] "
					ret=0
					;;
				"n")
					default="[y/N] "
					ret=1
					;;
			esac
			shift
		fi
		shift
	fi
	question="$*"

	while true; do
		echo -ne "${BOLD}${GREEN}->${END} $question $default"
		read -n 1 -r choice < /dev/tty
		echo
		if [ -z "$choice" ] && [ -n "$default" ]; then
			return "$ret"
		fi
		case "$(echo "$choice" | awk '{print tolower($0)}')" in
			"y")
				return 0
				;;
			"n")
				return 1
				;;
			"*")
				continue
		esac
	done
}

function is_git_repo {
	local git_dir="$1"
	cd "$git_dir" || return 1
	[ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1
	return $?
}

function git_clone_or_pull {
	local repo="$1"
	local dest_dir="$2"
	local branch="${3:-master}"

	if [ ! -d "$dest_dir" ]; then
		git clone --recurse-submodules --branch "$branch" "$repo" "$dest_dir"
	else
		if is_git_repo "$dest_dir"; then
			cd "$dest_dir" || return 1
			git checkout "$branch"
			git pull
			return $?
		else
			error "$dest_dir is not empty and is not a git repository"
			return 1
		fi
	fi
}

function setup_ohmyzsh {
	# From Oh My Zsh install script
	local ohmyzsh_path="$HOME/.oh-my-zsh"
	local remote="https://github.com/ohmyzsh/ohmyzsh.git"
	local branch="master"
	if [ -d "$ohmyzsh_path" ]; then
		query_yes_no "--default" "y" "Update Oh My Zsh?" && zsh -ic "omz update"
	else
		msg "Cloning Oh My Zsh repository..."
		git clone -c core.eol=lf -c core.autocrlf=false \
			-c fsck.zeroPaddedFilemode=ignore \
			-c fetch.fsck.zeroPaddedFilemode=ignore \
			-c receive.fsck.zeroPaddedFilemode=ignore \
			-c oh-my-zsh.remote=origin \
			-c oh-my-zsh.branch="$branch" \
			--depth=1 --branch "$branch" "$remote" "$ohmyzsh_path" || {
				warning "git clone of oh-my-zsh repo failed"
				return 1
			}
	fi
	zsh_plugins_path="$HOME/.oh-my-zsh-custom/plugins"
	zsh_themes_path="$HOME/.oh-my-zsh-custom/themes"
	mkdir -p "$zsh_plugins_path" "$zsh_themes_path"
	zsh_plugins=("zsh-autosuggestions" "zsh-syntax-highlighting")
	msg "Cloning Oh My Zsh plugins repositories..."
	for plugin in "${zsh_plugins[@]}"; do
		remote="https://github.com/zsh-users/${plugin}.git"
		git_clone_or_pull "$remote" "$zsh_plugins_path/$plugin"
	done
	git_clone_or_pull https://github.com/reegnz/jq-zsh-plugin.git "$zsh_plugins_path/jq"

	return 0
}

function setup_vim {
	msg "Setting up vim plugins..."
	local vim_path="$HOME/.vim"
	git_clone_or_pull https://github.com/VundleVim/Vundle.vim.git "$vim_path"/bundle/Vundle.vim

	vim_setup_file="$(mktemp --suffix=vimsetup)"
	sed -n '1,/^" END Vundle/{p}' "$CLONE_DIR"/dotfiles/.vim/vimrc > "$vim_setup_file"
	vim -u "$vim_setup_file" +PluginInstall +qall
	rm "$vim_setup_file"

	if [ -d "$vim_path"/bundle/YouCompleteMe ]; then
		cd "$vim_path"/bundle/YouCompleteMe || return
		./install.py --clang-completer
		cd - > /dev/null || return
	fi

	vim_venv_path="$HOME/.virtualenvs/vim"
	if [ "$SETUP_PYTHON" -eq 1 ] && [ ! -d "$vim_venv_path" ]; then
		python3 -m venv "$vim_venv_path"
	fi
	"$vim_venv_path"/bin/pip install black powerline-status
}

function setup_links {
	local src_dir="$1"
	shift
	local dest_dir="$1"
	shift
	local links=("$@")
	for link in "${links[@]}"; do
		sub_dirs="$(dirname "$link" | sed -E 's/^\.$//')"
		file_name="$(basename "$link")"
		if [ -n "$sub_dirs" ] && [ ! -e "$dest_dir/$sub_dirs" ]; then
			mkdir -p "$dest_dir/$sub_dirs"
		fi
		if [ ! -e "$dest_dir/$link" ]; then
			ln -s "$src_dir/$link" "$dest_dir/$sub_dirs/$file_name"
			continue
		fi
		if [ -L "$dest_dir/$link" ] && [ "$(readlink -f "$dest_dir/$link")" = "$src_dir/$link" ]; then
			continue
		fi
		error "Path $dest_dir/$link already exists"
	done
}

function sudo {
	[ "$use_sudo" -eq 1 ] && set -- command sudo "$@"
	"$@"
}

function install_yay {
	sudo pacman -S --needed --noconfirm base-devel fakeroot
	yay_tmp_dir="$(mktemp -d --suffix=yay)"
	git clone https://aur.archlinux.org/yay.git "$yay_tmp_dir"
	cd "$yay_tmp_dir" || return
	makepkg --noconfirm -si
	cd - > /dev/null || return
}

[ ! -d "$CLONE_DIR" ] && mkdir -p "$CLONE_DIR"

# Pre-flight checks
if [ "$OSTYPE" = "linux-gnu" ]; then
	if [ "$EUID" -ne 0 ]; then
		if query_yes_no "--default" "y" "You are not root, should I use sudo?"; then
			use_sudo=1
		else
			if command -v git >/dev/null; then
				warning "No root permissions, no packages will be installed"
				SETUP_PKG=0
			else
				error "No minimal requirements found, exiting"
				exit 1
			fi
		fi
	fi
elif [[ "$OSTYPE" =~ ^darwin.* ]]; then
	if ! command -v brew > /dev/null; then
		if query_yes_no "--default" "y" "Install brew?"; then
			msg "Installing brew..."
			## Don't prompt for confirmation when installing homebrew
			/usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		else
			if command -v git; then
				warning "No packages will be installed"
				SETUP_PKG=0
			else
				error "No minimal requirements found, exiting"
				exit 1
			fi
		fi
	fi
else
	error "This OS type ($OSTYPE) is not managed by this script"
	exit 1
fi

# command-line
query_yes_no "--default" "y" "Setup zsh and tools?" && SETUP_ZSH=1
# python
query_yes_no "--default" "y" "Install python?" && SETUP_PYTHON=1
# vim
query_yes_no "--default" "y" "Setup vim?" && SETUP_VIM=1
# neovim
query_yes_no "--default" "y" "Setup neovim?" && SETUP_NEOVIM=1
# i3 (Linux only)
[ "$OSTYPE" = "linux-gnu" ] && query_yes_no "--default" "y" "Setup i3wm?" && SETUP_I3=1

# Packages installation
if [ $SETUP_PKG -eq 1 ]; then
	PREREQUISITES=("git")
	TOOLS=("zsh" "fzf" "htop" "httpie" "ncdu" "ripgrep" "shellcheck" "tig" "xclip")
	NEOVIM=("neovim")

	if [ "$OSTYPE" = "linux-gnu" ]; then
		# Default to Debian type OS
		DISTRO="debian"
		PKG_MANAGER="apt-get"
		PKG_UPDATE=("$PKG_MANAGER" "update")
		PKG_INSTALL=("$PKG_MANAGER" "install" "-y")
		if [ -f "/etc/os-release" ]; then
			source "/etc/os-release"
			case "$ID" in
				"arch")
					DISTRO="arch"
					PKG_MANAGER="pacman"
					PKG_UPDATE=("$PKG_MANAGER" "-Sy")
					PKG_INSTALL=("$PKG_MANAGER" "-S" "--noconfirm" "--needed")
					AUR_INSTALL=("yay" "-S" "--noconfirm" "--needed")
					;;
			esac
		fi

		I3=("i3-wm" "i3blocks" "i3lock" "rofi" "thunar" "lxappearance"
		    "pavucontrol" "terminator" "dunst" "feh" "numlockx"
	    	)
		I3_AUR=("moka-icon-theme-git" "faba-icon-theme-git")
		VIM=("cmake" "make" "gcc" "powerline")
		NEOVIM+=("npm")
		case "$DISTRO" in
			"arch")
				TOOLS+=("starship")
				PYTHON=("python" "python-pip")
				VIM+=("powerline-fonts" "python" "vim")
				NEOVIM+=("tree-sitter")
				I3+=("arc-gtk-theme" "python" "python-pillow")
				;;
			"debian")
				#TODO: Add starship install
				PYTHON=("python3" "python3-dev" "python3-pip" "python3-venv")
				VIM+=("fonts-powerline" "python3" "vim-nox")
				NEOVIM+=("libtree-sitter0")
				I3+=("arc-theme" "python3" "python3-pil")
				;;
			*)
				error "Unsupported distribution $DISTRO"
				exit 1
				;;
		esac
	elif [[ "$OSTYPE" =~ ^darwin.* ]]; then
		PKG_MANAGER="brew"
		PKG_UPDATE=("$PKG_MANAGER" "update")
		PKG_INSTALL=("$PKG_MANAGER" "install")

		TOOLS+=("starship")
		PYTHON=("python")
		VIM=("vim")
		NEOVIM+=("tree-sitter" "node")
	fi

	declare -a AUR_PKGS
	declare -a PKGS
	[ $SETUP_ZSH -eq 1 ] && PKGS+=("${TOOLS[@]}")
	[ $SETUP_PYTHON -eq 1 ] && PKGS+=("${PYTHON[@]}")
	[ $SETUP_VIM -eq 1 ] && PKGS+=("${VIM[@]}")
	[ $SETUP_NEOVIM -eq 1 ] && PKGS+=("${NEOVIM[@]}")
	[ $SETUP_I3 -eq 1 ] && {
		PKGS+=("${I3[@]}")
		AUR_PKGS+=("${I3_AUR[@]}")
	}

	msg "Updating packages database..."
	sudo "${PKG_UPDATE[@]}" 2>> "$LOG_FILE" || error "Packages database update failed"

	msg "Installing prerquisites..."
	sudo "${PKG_INSTALL[@]}" "${PREREQUISITES[@]}" 2>> "$LOG_FILE" || error "Errors occured during packages installation"
	[ "${#AUR_PKGS}" -ne 0 ] && ! command -v yay > /dev/null && install_yay

	msg "Installing packages..."
	sudo "${PKG_INSTALL[@]}" "${PKGS[@]}" 2>> "$LOG_FILE" || error "Errors occured during packages installation"
	[ "${#AUR_PKGS}" -ne 0 ] && {
		"${AUR_INSTALL[@]}" "${AUR_PKGS[@]}" 2>> "$LOG_FILE" || error "Errors occured during packages installation"
	}
fi

msg "Cloning repositories..."
git_clone_or_pull "https://github.com/Da-Juan/dotfiles.git" "$CLONE_DIR/dotfiles" || {
	error "git clone of dotfiles repo failed"
	exit 1
}

# Oh My Zsh repos cloning
[ $SETUP_ZSH -eq 1 ] && setup_ohmyzsh


if [ -d "$CLONE_DIR/dotfiles"  ]; then
	msg "Setting up symbolic links..."
	if cd "$CLONE_DIR/dotfiles"; then
		# Links in $HOME
		LINKS=(".aliases")
		[ $SETUP_ZSH -eq 1 ] && LINKS+=(".zshenv" ".zshrc")
		[ $SETUP_VIM -eq 1 ] && LINKS+=(".vim")
		[ $SETUP_I3 -eq 1 ] && LINKS+=(".local/share/fonts" ".xsessionrc")
		setup_links "$CLONE_DIR/dotfiles" "$HOME" "${LINKS[@]}"

		# Links in $HOME/.config
		FIND_ARGS=("-maxdepth" "1" "-mindepth" "1" "-not" "-name" "*.example")
		[ $SETUP_PYTHON -ne 1 ] && FIND_ARGS+=("-and" -"not" "-name" "bpython")
		[ $SETUP_NEOVIM -ne 1 ] && FIND_ARGS+=("-and" -"not" "-name" "nvim")
		[ $SETUP_I3 -ne 1 ] && {
			I3_CONFIGS=("i3" "dunst" "rofi")
			for c in "${I3_CONFIGS[@]}"; do
				FIND_ARGS+=("-and" -"not" "-name" "$c")
			done
		}
		mapfile -t CONFIG <<< "$(find .config "${FIND_ARGS[@]}")"
		CONFIG_DIR="$HOME/.config"
		[ ! -d "$CONFIG_DIR" ] && mkdir "$CONFIG_DIR"
		setup_links "$CLONE_DIR/dotfiles/.config" "$CONFIG_DIR" "${CONFIG[@]#.config/}"

		# Oh My Zsh custom themes
		[ $SETUP_ZSH -eq 1 ] && {
			FIND_ARGS=("-maxdepth" "1" "-mindepth" "1" "-not" "-name" "*.example")
			mapfile -t THEMES <<< "$(find .oh-my-zsh-custom/themes "${FIND_ARGS[@]}")"
			setup_links "$CLONE_DIR/dotfiles/.oh-my-zsh-custom/themes" "$HOME/.oh-my-zsh-custom/themes" "${THEMES[@]#.oh-my-zsh-custom/themes/}"
		}
		cd - > /dev/null || true
	else
		error "Unable to change directory to $CLONE_DIR/dotfiles"
	fi
fi

[ $SETUP_VIM -eq 1 ] && setup_vim

if [ -f "$LOG_FILE" ] && grep -qE "ERROR|WARNING" "$LOG_FILE"; then
	msg "Some warnings or errors were raised during this setup:"
	cat "$LOG_FILE"
	msg "Logs stored in $LOG_FILE"
fi
