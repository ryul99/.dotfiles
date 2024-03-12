o = vim.opt
km = vim.keymap
fn = vim.fn

local imap = function(...) vim.keymap.set('i', ...) end
local nmap = function(...) vim.keymap.set('n', ...) end
local vmap = function(...) vim.keymap.set('v', ...) end

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
o.pastetoggle = '<F8>'
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
-- Commands
--

-- save with sudo
if vim.fn.has('nvim') then
    km.set('c', 'w!!', 'w suda://%')
else
    -- cmap w!! w !sudo tee %
    km.set('c', 'w!!', 'w !sudo tee %')
end

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

-- plugins
require ('plugins/packer')
require ('plugins/treesitter')
-- configs
-- require ('config/cmp.lua') is already loaded
require ('config/plugins')
require ('config/lsp')
require ('config/keymap')
