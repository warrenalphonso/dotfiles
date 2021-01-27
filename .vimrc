set number " Line numbers 
set colorcolumn=80 " Tells me when I hit 80 chars in a line 
syntax on
filetype plugin indent on " Detects file type & loads plugin and indent files
" Disables autocomment on newline
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Set softtabstop=0 noexpandtab
set softtabstop=0 shiftwidth=4 smarttab

" Ignore case when searching 
:set ignorecase
" Ignore whitespace when searching - DOESN'T WORK
" :let @/ = join(split(@/, '\zs'), '\_s*')

" Install PlugInstall if not already installed 
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"call plug#begin('~/.config/nvim')
call plug#begin('~/.vim/plugged')
Plug 'lervag/vimtex'
Plug 'ervandew/supertab'
Plug 'parkr/vim-jekyll'
Plug 'JuliaEditorSupport/julia-vim'
Plug 'iCyMind/NeoSolarized'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
call plug#end()

" vimtex 
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
set conceallevel=2
let g:tex_conceal='abdgms'

function! MathAndLiquid()
    "" Define certain regions
    " Block math. Look for "$$[anything]$$"
    syn region math start=/\$\$/ end=/\$\$/
    " inline math. Look for "$[not $][anything]$"
    syn match math_block '\$[^$].\{-}\$'


    "" Actually highlight those regions.
    hi link math Statement
    hi link math_block Function
endfunction

" Call everytime we open a Markdown file
autocmd BufRead,BufNewFile,BufEnter *.md,*.markdown call MathAndLiquid()

" Solarized dark colorscheme 
syntax enable
colorscheme NeoSolarized

" Automatic unicode extension in Julia files - no need to press Tab 
" TODO: I can also enable this in all files. Should I? Guide is at: 
" https://github.com/JuliaEditorSupport/julia-vim
" Useful over normal tab method because when searching with / it lets me
" search for a unicode 
:let g:latex_to_unicode_keymap = 1

" From https://github.com/junegunn/limelight.vim
" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

" Color name (:help gui-colors) or RGB color
let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#777777'

" Default: 0.5
let g:limelight_default_coefficient = 0.7

" Number of preceding/following paragraphs to include (default: 0)
let g:limelight_paragraph_span = 1

" Beginning/end of paragraph
"   When there's no empty line between the paragraphs
"   and each paragraph starts with indentation
let g:limelight_bop = '^\s'
let g:limelight_eop = '\ze\n^\s'

" Highlighting priority (default: 10)
"   Set it to -1 not to overrule hlsearch
let g:limelight_priority = -1

" Goyo.vim integration
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

