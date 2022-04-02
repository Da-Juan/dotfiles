#!/usr/bin/env bash

CLONE_DIR="${1:-$HOME/Projects}"

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
SETUP_I3=0
SETUP_PKG=1

use_sudo=0

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

	black_venv_path="$HOME/.virtualenvs/black"
	if [ "$SETUP_PYTHON" -eq 1 ] && [ ! -d "$black_venv_path" ]; then
		python3 -m venv "$black_venv_path"
	fi
	"$black_venv_path"/bin/pip install black
}

function setup_links {
	local src_dir="$1"
	shift
	local dest_dir="$1"
	shift
	local links=("$@")
	for link in "${links[@]}"; do
		if [ ! -e "$dest_dir/$link" ]; then
			ln -s "$src_dir/$link" "$dest_dir/"
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
# i3 (Linux only)
[ "$OSTYPE" = "linux-gnu" ] && query_yes_no "--default" "y" "Setup i3wm?" && SETUP_I3=1

# Packages installation
if [ $SETUP_PKG -eq 1 ]; then
	PREREQUISITES=("git")
	TOOLS=("zsh" "htop" "httpie" "ncdu" "shellcheck" "tig" "xclip")

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
		case "$DISTRO" in
			"arch")
				TOOLS+=("the_silver_searcher")
				PYTHON=("python" "python-pip")
				VIM+=("powerline-fonts" "python" "python-powerline" "vim")
				I3+=("arc-gtk-theme" "python" "python-pillow")
				;;
			"debian")
				TOOLS+=("silversearcher-ag")
				PYTHON=("python3" "python3-dev" "python3-pip" "python3-venv")
				VIM+=("fonts-powerline" "python3" "python3-powerline" "vim-nox")
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

		TOOLS+=("the_silver_searcher")
		PYTHON=("python")
		VIM=("vim")
	fi

	declare -a AUR_PKGS
	declare -a PKGS
	[ $SETUP_ZSH -eq 1 ] && PKGS+=("${TOOLS[@]}")
	[ $SETUP_PYTHON -eq 1 ] && PKGS+=("${PYTHON[@]}")
	[ $SETUP_VIM -eq 1 ] && PKGS+=("${VIM[@]}")
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
	[ "${#AUR_PKGS}" -ne 0 ] && "${AUR_INSTALL[@]}" "${AUR_PKGS[@]}" 2>> "$LOG_FILE" || error "Errors occured during packages installation"

	[[ "$OSTYPE" =~ ^darwin.* ]] && [ $SETUP_VIM -eq 1 ] && pip3 install git+git://github.com/powerline/powerline
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
		[ $SETUP_I3 -eq 1 ] && LINKS+=(".fonts" ".xsessionrc")
		setup_links "$CLONE_DIR/dotfiles" "$HOME" "${LINKS[@]}"

		# Links in $HOME/.config
		FIND_ARGS=("-maxdepth" "1" "-mindepth" "1" "-not" "-name" "*.example")
		[ $SETUP_PYTHON -ne 1 ] && FIND_ARGS+=("-and" -"not" "-name" "bpython")
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
