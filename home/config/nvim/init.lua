o = vim.opt
fn = vim.fn

--
-- General Configs
--

vim.g.mapleader = ","

vim.cmd([[
    filetype plugin on
    syntax on


    " Mistypings
    command Q :q
    command Qa :qa
]])
o.encoding = 'utf-8'
o.fileencoding = 'utf-8'
o.shell = '/bin/bash'
o.scroll = math.min(20, o.scroll:get())
o.scrolloff = 3
o.startofline = true
o.splitbelow = true
o.splitright = true
o.backup = false
o.swapfile = false

if not vim.fn.has('nvim') then
    o.compatible = false
end

o.showmode = true
o.foldenable = true
o.wrap = true
o.showcmd = true
o.signcolumn = 'yes'
o.colorcolumn = {'79', '99', '119'}

-- mouse
o.mouse = 'a'

-- Indentation
o.cindent = true
o.autoindent = true
o.smartindent = true

-- Taib
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true

-- Searching
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.wrapscan = false
o.incsearch = true

-- Line Number Column
o.number = true
o.cursorline = true
-- Pair Matching
o.showmatch = true


--
-- diagnostic
--

vim.diagnostic.config({
    virtual_text = {
        severity = { min = vim.diagnostic.severity.ERROR },
    },
    underline = {
        severity = { min = vim.diagnostic.severity.ERROR },
    },
    signs = {
        severity = { min = vim.diagnostic.severity.ERROR },
    },
})

-- Configure neovim python host.
-- This can be executed lazily after entering vim, to save startup time.
-- require('utils.pynvim')
require('utils.fixfnkeys')
require('utils.compat')

require("config.lazy")
-- require("lazy").setup("configs")
--
-- configs
require ('config/plugins')
require ('config/treesitter')
require ('config/ufo')
require ('config/keymaps')
require ('config/avante')
