set nocompatible              " be iMproved, required
set rtp+=~/.vim/bundle/Vundle.vim
filetype off                  " required

" set the runtime path to include vim-plug and initialize
call plug#begin('~/.vim/plugged')

" let Vundle manage vim-plug, required
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'townk/vim-autoclose'
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/syntastic'
Plug 'nanotech/jellybeans.vim'
Plug 'airblade/vim-gitgutter' " 코드 변경내역 확인
Plug 'tpope/vim-fugitive'
Plug 'ctrlpvim/ctrlp.vim'

call plug#end()            " required
filetype plugin indent on    " required



" Indentation
set autoindent
set cindent
set autoindent

" Line Number Column
set number
set cursorline"

" Tab
set ts=4 " Tab width
set shiftwidth=4 " autoindent width
set expandtab


set laststatus=2 " 상태바 표시를 항상한다
set statusline=\ %<%l:%v\ [%P]%=%a\ %h%m%r\ %F\

" Searching
set ignorecase
set smartcase
set hlsearch
set nowrapscan

let airline_powerline_fonts = 1

" using colorscheme
colorscheme jellybeans

"syntax highlighting
if has("syntax")
        syntax on
endif
