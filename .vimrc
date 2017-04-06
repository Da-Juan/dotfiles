" Pathogen load
filetype off

call pathogen#infect()
call pathogen#helptags()

syntax on
"set nocompatible
filetype plugin indent on
"au FileType py set autoindent
"au FileType py set smartindent

" Use 256 colours (Use this setting only if your terminal supports 256 colours)
set t_Co=256

" Solarized colorscheme
let g:solarized_termtrans=1 " 1|0 background transparent
colorscheme solarized
set background=dark

python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

" Always show statusline
set laststatus=2

" Toggle auto-indenting for code paste
set pastetoggle=<F2>

""""""""""""""""""""
" Highlight search "
""""""""""""""""""""
" Press F4 to toggle highlighting on/off, and show current value.
noremap <F4> :set hlsearch! hlsearch?<CR>

" Press Return to temporarily get out of the highlighted search.
nnoremap <CR> :nohlsearch<CR><CR>

" Pressing F8 will highlight all occurrences of the current word.
nnoremap <F8> :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>

""""""""""""""""
" Code folding "
""""""""""""""""
" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za
vnoremap <space> zf

" Pyton 120 characters line length
let g:pymode_options_max_line_length=120
autocmd FileType python set colorcolumn=120

" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" Enable modelines
set modeline
set modelines=5
