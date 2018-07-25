" Pathogen load
filetype off

call pathogen#infect()
call pathogen#helptags()

"set nocompatible
filetype plugin indent on
"au FileType py set autoindent
"au FileType py set smartindent

""""""""""""""""""""
" General settings "
""""""""""""""""""""
syntax on			" Highlight syntax

" Hide line numbers when file has no filetype or no file was opened
autocmd BufNewFile,BufRead,VimEnter * if &ft == '' | set nonumber
set number			" show line numbers

				" toggle line numbering
nnoremap <F3> :set nonumber!<CR>
imap <F3> <C-O><F3>

set cursorline			" shows line under the cursor's line
set showmatch			" shows matching part of bracket pairs (), [], {}

set enc=utf-8			" utf-8 by default

set pastetoggle=<F2>		" Toggle auto-indenting for code paste

set modeline			" Enable modelines
set modelines=5

set scrolloff=10		" let 10 lines before/after cursor during scroll

set exrc			" enable usage of additional .vimrc files from working directory
set secure			" prohibit .vimrc files to execute shell, create files, etc...

"""""""""""""""
" Color theme "
"""""""""""""""
set t_Co=256			" Use 256 colours (Use this setting only if your terminal supports 256 colours)

" Solarized colorscheme
let g:solarized_termtrans=1 	" 1|0 background transparent
colorscheme solarized
set background=dark

""""""""""""""""""""
" Buffers settings "
""""""""""""""""""""
set switchbuf=useopen
nmap <F9> :bprev<CR>
nmap <F10> :bnext<CR>

"""""""""""""
" Powerline "
"""""""""""""
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

" Always show statusline
set laststatus=2

"""""""""""""""""""
" Search settings "
"""""""""""""""""""
set incsearch			" Incremental search
set hlsearch			" Highlight search

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

"""""""""""""""
" Python mode "
"""""""""""""""
" Python 120 characters line length
let g:pymode_options_max_line_length=120
autocmd FileType python set colorcolumn=120

" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" Disable docstring preview on auto-completion for Python
autocmd FileType python set completeopt=menu

""""""""
" YAML "
""""""""
" Use 2 space YAML
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
