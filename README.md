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

:warning:  
Since macOS X El Capitan a helper in `/etc/zprofile` might alter your directories order in your `$PATH` variable.  
You can comment the lines in that file to keep your `$PATH` order.  
See http://www.zsh.org/mla/users//2015/msg00724.html for more details.

### Packages needed
#### Debian/Ubuntu
```
apt-get install zsh
```

#### macOS X
```
brew install zsh
```

To use Powerline you need to install a patched font, I use Roboto Mono for Powerline.  
https://github.com/powerline/fonts

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
brew install vim
# Check if python 3 is installed correctly
which python3
/usr/local/bin/python3
# Install powerline
pip3 install git+git://github.com/powerline/powerline
```

### Pathogen
https://github.com/tpope/vim-pathogen  
vim-pathogen is included in this repository as a submodule.

### Python-mode
https://github.com/klen/python-mode  
python-mode is included in this repository as a submodule.

### Gitgutter
https://github.com/airblade/vim-gitgutter  
vim-gitgutter is included in this repository as a submodule.

### Syntax highlighting
* Jinja: https://github.com/Glench/Vim-Jinja2-Syntax
* SaltStack: https://github.com/saltstack/salt-vim

## Random wallpapers
Put some images in `~/Pictures/Wallpapers`

### Systemd timer
Run the following commands:
```
systemctl --user daemon-reload
systemctl --user enable wallpaper.timer
systemctl --user start wallpaper.timer
```
### Crontab setup
Add this line to your crontab:
```
*/5 * * * *     ps -C i3 > /dev/null && env USER=$LOGNAME ~/.config/i3/scripts/wallpaper || true
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
* `monitor_partitions.sh`: monitor partitions and send a notification email when space or inodes usage is 90% or above, setup your partitions or mount points, email, and threshold, if you want to change it, in `~/.config/partitions_monitor`, see `.config/partitions_monitor.example`.

### Debian/Ubuntu
```
apt-get install htop httpie ncdu shellcheck silversearcher-ag tig xclip
```

### macOS X
```
brew install htop httpie ncdu shellcheck the_silver_searcher tig xclip
```
