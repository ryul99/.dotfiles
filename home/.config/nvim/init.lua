vim.cmd([[
    set runtimepath^=~/.vim runtimepath+=~/.vim/after
    let &packpath=&runtimepath
]])
local vimrc = require('vimrc')
