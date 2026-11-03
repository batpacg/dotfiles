" ~/.vimrc

" Keymaps ====================================================================

let mapleader = " "

map <C-s> <CMD>w!<CR>
map <C-q> <CMD>quitall!<CR>

map <Leader>e <CMD>Ex<CR>

nnoremap <ESC> <CMD>nohl<CR><ESC>

map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
map <S-l> <CMD>bn<CR>
map <S-h> <CMD>bp<CR>
map <Leader>d <CMD>bd!<CR>

" Options ====================================================================

set lazyredraw
set noerrorbells
set novisualbell
set nobackup
set nowb
set noswapfile
set encoding=utf-8

" visual guides
set number
set colorcolumn=81

" identation
set autoindent
set smartindent
set smarttab
set expandtab
set shiftwidth=4
set softtabstop=4

" regex substitution
set gdefault
set ignorecase
set smartcase

" search
set hlsearch
set incsearch

" Set to auto read when a file is changed from the outside
set autoread
au FocusGained,BufEnter * silent! checktime

" appearance
syntax on
colorscheme habamax
set laststatus=2
set statusline=\ %f\ %m%h%w\ %=\ @\ %{getcwd()}\ 

filetype plugin on
filetype indent on
