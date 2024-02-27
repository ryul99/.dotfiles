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
-- Key Mappings
--

-- Easy Indentation
vmap('<Tab>', '>gv', {
    silent = true
})
vmap('<S-Tab>', '<gv', {
    silent = true
})

-- Easy Splitting
nmap('<C-_>', ':split<CR>', {
    silent = true
})
nmap('<C-\\>', ':vertical split<CR>', {
    silent = true
})

-- Easy Navigation
nmap('<C-h>', '<C-w><C-h>')
nmap('<C-j>', '<C-w><C-j>')
nmap('<C-k>', '<C-w><C-k>')
nmap('<C-l>', '<C-w><C-l>')

-- Easy Resize
nmap('<A-h>', ':vertical resize -2<CR>', {
    silent = true
})
nmap('<A-j>', ':resize -2<CR>', {
    silent = true
})
nmap('<A-k>', ':resize +2<CR>', {
    silent = true
})
nmap('<A-l>', ':vertical resize +2<CR>', {
    silent = true
})

-- Tab Navigations
nmap('<Leader>t', ':tabnew<CR>', {
    silent = true
})
nmap('<Leader>T', ':-tabnew<CR>', {
    silent = true
})
nmap('<Leader>1', '1gt', {
    silent = true
})
nmap('<Leader>2', '2gt', {
    silent = true
})
nmap('<Leader>3', '3gt', {
    silent = true
})
nmap('<Leader>4', '4gt', {
    silent = true
})
nmap('<Leader>5', '5gt', {
    silent = true
})
nmap('<Leader>6', '6gt', {
    silent = true
})
nmap('<Leader>7', '7gt', {
    silent = true
})
nmap('<Leader>8', '8gt', {
    silent = true
})
nmap('<Leader>9', '9gt', {
    silent = true
})

-- Line Moving
nmap('<S-Up>', ':m-2<CR>', {
    silent = true
})
nmap('<S-Down>', ':m+<CR>', {
    silent = true
})
imap('<S-Up>', '<Esc>:m-2<CR>', {
    silent = true
})
imap('<S-Down>', '<Esc>:m+<CR>', {
    silent = true
})

-- Buffer Navigations
nmap('<Tab><Tab>', ':b #<CR>', {
    silent = true
})

-- Remove highlight
nmap(',<Space>', ':noh<CR>', {
    silent = true
})

-- Easy save
nmap('<C-s>', ':w<CR>')
imap('<C-s>', '<ESC>:w<CR>')

-- Visual to search
vmap('//', "\"vy/\\V<C-R>=escape(@v,'/')<CR><CR>")

imap('<c-b>', '<c-o>b', { silent = true })  -- words backward
imap('<c-f>', '<c-o>w', { silent = true })  -- words forward

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

require ('plugins/packer')
require ('config/plugins')
require ('config/lsp')
