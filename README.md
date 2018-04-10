# dotfiles
Backup for my dotfiles

```
git clone --recurse-submodules https://github.com/Da-Juan/dotfiles.git
```

## zsh
Oh my zsh: http://ohmyz.sh/

Plugins:  
zsh-autosuggestions: https://github.com/zsh-users/zsh-autosuggestions
zsh-syntax-highlighting: https://github.com/zsh-users/zsh-syntax-highlighting
zsh_virsh_autocompletion: https://github.com/jplitza/zsh-virsh-autocomplete

Packages needed:
```
apt-get install zsh
```

If you want to hide the first element of the prompt (`user@host`) add the following line to you \.profile`:
```
export DEFAULT_USER=$USER
```

## i3wm
i3wm: https://i3wm.org/  
i3wm screencast tutorials: https://www.youtube.com/watch?v=j1I63wGcvU4&list=PL5ze0DjYv5DbCv9vNEzFmP6sU7ZmkGzcf  
Alex Booker dotfiles: https://github.com/alexbooker/dotfiles/tree/ubuntu

Packages needed:
```
apt-get install i3-wm i3blocks i3lock rofi compton thunar arc-theme lxappearance moka-icon-theme faba-icon-theme pavucontrol terminator dunst feh numlockx
```

Set Ark Darker theme and Moka icons theme using `lxappearance`

Font Awesome: http://fontawesome.io/
Octicons: https://octicons.github.com/
Pomicons: https://github.com/gabrielelana/pomicons
Yosemite San Francisco Font: https://github.com/supermarin/YosemiteSanFranciscoFont

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
Packages needed:
```
apt-get install fonts-powerline python3-powerline powerline vim-nox
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

## Useful tools

```
apt-get install htop tig
```
