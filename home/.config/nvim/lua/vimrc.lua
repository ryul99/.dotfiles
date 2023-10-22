local o = vim.opt
local km = vim.keymap

--
-- General Configs
--

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

-- Easy Home/End
-- translate this vim language comment to lua
km.set('i', '<C-a>', '<ESC>I')
km.set('i', '<C-e>', '<ESC>A')
km.set('n', '<C-a>', '^')
km.set('n', '<C-e>', '$')
km.set('v', '<C-a>', '^')
km.set('v', '<C-e>', '$')

-- Easy Delete Key
km.set('v', '<BS>', '"_d', {
    silent = true
})

-- Easy Indentation
km.set('v', '<Tab>', '>gv', {
    silent = true
})
km.set('v', '<S-Tab>', '<gv', {
    silent = true
})

-- Easy Splitting
km.set('n', '<C-_>', ':split<CR>', {
    silent = true
})
km.set('n', '<C-\\>', ':vertical split<CR>', {
    silent = true
})

-- Easy Navigation
km.set('n', '<C-h>', '<C-w><C-h>')
km.set('n', '<C-j>', '<C-w><C-j>')
km.set('n', '<C-k>', '<C-w><C-k>')
km.set('n', '<C-l>', '<C-w><C-l>')

-- Easy Resize
km.set('n', '<C-A-h>', ':vertical resize -2<CR>', {
    silent = true
})
km.set('n', '<C-A-j>', ':resize -2<CR>', {
    silent = true
})
km.set('n', '<C-A-k>', ':resize +2<CR>', {
    silent = true
})
km.set('n', '<C-A-l>', ':vertical resize +2<CR>', {
    silent = true
})

-- Tab Navigations
km.set('n', '<a-t>', ':tabnew<CR>', {
    silent = true
})
km.set('n', '<a-T>', ':-tabnew<CR>', {
    silent = true
})
km.set('n', '<a-1>', '1gt', {
    silent = true
})
km.set('n', '<a-2>', '2gt', {
    silent = true
})
km.set('n', '<a-3>', '3gt', {
    silent = true
})
km.set('n', '<a-4>', '4gt', {
    silent = true
})
km.set('n', '<a-5>', '5gt', {
    silent = true
})
km.set('n', '<a-6>', '6gt', {
    silent = true
})
km.set('n', '<a-7>', '7gt', {
    silent = true
})
km.set('n', '<a-8>', '8gt', {
    silent = true
})
km.set('n', '<a-9>', '9gt', {
    silent = true
})

-- Line Moving
km.set('n', '<S-Up>', ':m-2<CR>', {
    silent = true
})
km.set('n', '<S-Down>', ':m+<CR>', {
    silent = true
})
km.set('i', '<S-Up>', '<Esc>:m-2<CR>', {
    silent = true
})
km.set('i', '<S-Down>', '<Esc>:m+<CR>', {
    silent = true
})

-- Buffer Navigations
km.set('n', '<Tab><Tab>', ':b #<CR>', {
    silent = true
})

-- Easy delete
km.set('i', '<A-BS>', '<C-w>')

-- Remove highlight
km.set('n', ',<Space>', ':noh<CR>', {
    silent = true
})

-- Easy save
km.set('n', '<C-s>', ':w<CR>')
km.set('i', '<C-s>', '<ESC>:w<CR>')

-- Visual to search
km.set('v', '//', "\"vy/\\V<C-R>=escape(@v,'/')<CR><CR>")

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

vim.diagnostic.config({severity = vim.diagnostic.severity.ERROR})

require ('plugins/packer')
