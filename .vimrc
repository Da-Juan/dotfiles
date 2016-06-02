" au BufNewFile,BufRead *.yaml,*.yml,*.sls so ~/.vim/yaml.vim
syntax on
set nocompatible
filetype plugin indent on

set background=dark

python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

" Always show statusline
set laststatus=2

" Use 256 colours (Use this setting only if your terminal supports 256 colours)
set t_Co=256
