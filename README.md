# dotfiles
Backup for my dotfiles

**This is a work in progress**

## i3wm
i3wm: https://i3wm.org/  
i3wm screencast tutorials: https://www.youtube.com/watch?v=j1I63wGcvU4&list=PL5ze0DjYv5DbCv9vNEzFmP6sU7ZmkGzcf  
Alex Booker dotfiles: https://github.com/alexbooker/dotfiles/tree/ubuntu

Packages needed:
```
apt-get install i3-wm i3blocks i3lock rofi compton thunar pavucontrol terminator dunst
```

Font Awesome: http://fontawesome.io/  
Octicons: https://octicons.github.com/  
Pomicons: https://github.com/gabrielelana/pomicons  
Yosemite San Francisco Font: https://github.com/supermarin/YosemiteSanFranciscoFont  

**Memo**: get the version number of a font
```
apt-get  install lcdf-typetools
otfinfo -v .fonts/fontawesome-webfont.ttf 
```

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
git clone https://github.com/klen/python-mode.git
```
### Syntax highlighting
* Jinja: https://github.com/Glench/Vim-Jinja2-Syntax
* SaltStack: https://github.com/saltstack/salt-vim

## Random wallpapers
Put some images in `~/Pictures/Wallpapers`
Add this line to your crontab:
```
*/5 * * * *     DISPLAY=:0.0 ~/.config/i3/scripts/wallpaper
```
