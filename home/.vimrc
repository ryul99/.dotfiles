set nocompatible              " be iMproved, required
set rtp+=~/.vim/bundle/Vundle.vim
filetype off                  " required

" set the runtime path to include Vundle and initialize
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'scrooloose/nerdtree'
Plugin 'autoclose'
Plugin 'vim-airline/vim-airline'
Plugin 'syntastic'
Plugin 'nanotech/jellybeans.vim'
Plugin 'vim-gitgutter' " 코드 변경내역 확인
Plugin 'vim-fugitive'
Plugin "ctrpvim/ctrlp.vim"

call vundle#end()            " required
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

" using colorscheme
colorscheme jellybeans

"syntax highlighting
if has("syntax")
        syntax on
endif

