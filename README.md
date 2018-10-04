# dotfiles
Backup for my dotfiles

```
git clone --recurse-submodules https://github.com/Da-Juan/dotfiles.git
```

Some packages on macOS X need to be installed using  homebrew: https://brew.sh/

## zsh
Oh my zsh: http://ohmyz.sh/

Plugins:  
* zsh-autosuggestions: https://github.com/zsh-users/zsh-autosuggestions
* zsh-syntax-highlighting: https://github.com/zsh-users/zsh-syntax-highlighting
* zsh_virsh_autocompletion: https://github.com/jplitza/zsh-virsh-autocomplete

If you want to hide the first element of the prompt (`user@host`) add the following line to you `.profile`:
```
export DEFAULT_USER=$USER
```

### Packages needed
#### Debian/Ubuntu
```
apt-get install zsh
```

#### macOS X
```
brew install zsh
```

## i3wm
* i3wm: https://i3wm.org/
* i3wm screencast tutorials: https://www.youtube.com/watch?v=j1I63wGcvU4&list=PL5ze0DjYv5DbCv9vNEzFmP6sU7ZmkGzcf
* Alex Booker dotfiles: https://github.com/alexbooker/dotfiles/tree/ubuntu

Packages needed:
```
apt-get install i3-wm i3blocks i3lock rofi compton thunar arc-theme lxappearance moka-icon-theme faba-icon-theme pavucontrol python3 python3-pil terminator dunst feh numlockx
```

Set Ark Darker theme and Moka icons theme using `lxappearance`

* Font Awesome: http://fontawesome.io/
* Octicons: https://octicons.github.com/
* Pomicons: https://github.com/gabrielelana/pomicons
* Yosemite San Francisco Font: https://github.com/supermarin/YosemiteSanFranciscoFont

**Memo**: get the version number of a font
```
apt-get  install lcdf-typetools
otfinfo -v .fonts/fontawesome-webfont.ttf 
```

## xcwd

Packages needed:
```
apt-get install gcc libx11-dev make
```

X current working directory: https://github.com/schischi/xcwd

## Vim
### Vim powerline
#### Debian/Ubuntu
Packages needed:
```
apt-get install fonts-powerline python3-powerline powerline vim-nox
```

#### macOS X
```
# Install python 3
brew install python
# Install vim and replace system vi command
brew install vim --override-system-vi
# Check if python 3 is installed correctly
which python3
/usr/local/bin/python3
# Install powerline
pip3 install git+git://github.com/powerline/powerline
```

### Pathogen
https://github.com/tpope/vim-pathogen
```
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
```
### Python-mode
https://github.com/klen/python-mode
```
cd ~/.vim/bundle
git clone --recursive https://github.com/python-mode/python-mode
```
### Syntax highlighting
* Jinja: https://github.com/Glench/Vim-Jinja2-Syntax
* SaltStack: https://github.com/saltstack/salt-vim

## Random wallpapers
Put some images in `~/Pictures/Wallpapers`
Add this line to your crontab:
```
*/5 * * * *     ps -C i3 > /dev/null && DISPLAY=:0.0 ~/.config/i3/scripts/wallpaper || true
```

## Audio configuration
### Change default output device
List devices using:
```
pacmd list-sinks | grep -e 'name:' -e 'index:'               
```

The `*` on the ouptut shows the default device.
```
  * index: 0
	name: <alsa_output.usb-Generic_USB_Audio_200901010001-00.analog-stereo-headphone>
    index: 1
	name: <alsa_output.pci-0000_00_1f.3.analog-stereo>
```

Copy `/etc/pulse/default.pa` to `.config/pulse/default.pa` and add a line `set-default-sink <index|name>`, for example:
```
set-default-sink 1
# or
set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo
```

Then restart pluseaudio:
```
pulseaudio -k
```

### Automatically mute when jack is unplugged
ACPI can be used to auotmatically mute/unmute the audio output when the jack is unplugged/plugged.

Copy the files to ACPI events directory and add the `jack_mute.sh` script to the PATH:
```
cp etc/acpi/events/jack-* /etc/acpi/events/
ln -s "$(pwd)/bin/jack_mute.sh" /usr/local/bin
```

## Useful tools

### bin directory

You can add the `bin` directory to your `PATH` or create symbolic links in `/usr/local/bin`.

* `switch_docking.sh`: reconfigure screens when docking/undocking the laptop, setup your screen order preference in `~/.config/screens`, see `.config/screens.example`.

### Debian/Ubuntu
```
apt-get install htop httpie ncdu shellcheck silversearcher-ag tig
```

### macOS X
```
brew install htop httpie ncdu shellcheck the_silver_searcher tig
```
