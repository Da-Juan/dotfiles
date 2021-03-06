" Pathogen load
filetype off

runtime bundle/vim-pathogen/autoload/pathogen.vim

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
python3 sys.path.append('/usr/lib/python3/dist-packages/')
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
" Press F5 to clear highlighted search
noremap <F5> :nohlsearch<CR>

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
" Use python3 syntax checking
let g:pymode_python = 'python3'

" Python 120 characters line length
let g:pymode_options_max_line_length=89
autocmd FileType python set colorcolumn=89

" Highlight trailing spaces
highlight BadWhitespace ctermfg=16 ctermbg=166 guifg=#000000 guibg=#d75f00
autocmd FileType python match BadWhitespace /\s\+$/

" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" Disable docstring preview on auto-completion for Python
autocmd FileType python set completeopt=menuone,noinsert

" Enable Rope support
let g:pymode_rope = 1
" let g:pymode_rope_completion = 1
" let g:pymode_rope_complete_on_dot = 1
" let g:pymode_rope_completion_bind = '<C-Space>'

"""""""""""""""""
" CSS, HTML, JS "
"""""""""""""""""
" Use 2 spaces
autocmd FileType css,html,javascript set ts=2 sts=2 sw=2

""""""""
" YAML "
""""""""
" Use 2 spaces YAML
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

"""""""""""""""""""""""""""""
" Highlight repeating lines "
"""""""""""""""""""""""""""""
function! HighlightRepeats() range
  let lineCounts = {}
  let lineNum = a:firstline
  while lineNum <= a:lastline
    let lineText = getline(lineNum)
    if lineText != ""
      let lineCounts[lineText] = (has_key(lineCounts, lineText) ? lineCounts[lineText] : 0) + 1
    endif
    let lineNum = lineNum + 1
  endwhile
  exe 'syn clear Repeat'
  for lineText in keys(lineCounts)
    if lineCounts[lineText] >= 2
      exe 'syn match Repeat "^' . escape(lineText, '".\^$*[]') . '$"'
    endif
  endfor
endfunction

command! -range=% HighlightRepeats <line1>,<line2>call HighlightRepeats()
map <F6> :HighlightRepeats<CR>
