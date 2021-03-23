" Line numbers 
set number 
" Vertical line at 80 characters
set colorcolumn=80 
" Newline copies indentation of above line 
set autoindent 

" Show command in bottom bar
set showcmd

" Ignore case when searching 
set ignorecase 
set smartcase 
" Highlight search results 
set hlsearch 
" Highlight pattern matches while typing 
set incsearch 

" Show matching brackets 
set showmatch 

" Number of spaces per TAB 
set tabstop=4
" Number of spaces per TAB while editing 
set softtabstop=4 
" Tabs are spaces 
set expandtab

" allows cursor change in tmux mode
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Install PlugInstall if not already installed 
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"call plug#begin('~/.config/nvim')
call plug#begin('~/.vim/plugged')
Plug 'iCyMind/NeoSolarized'
call plug#end()

" Solarized dark colorscheme 
syntax enable
colorscheme NeoSolarized
