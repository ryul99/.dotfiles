vim.cmd([[
    set runtimepath^=~/.vim runtimepath+=~/.vim/after
    let &packpath=&runtimepath
]])

require('vimrc')
