local imap = function(...) vim.keymap.set('i', ...) end
local nmap = function(...) vim.keymap.set('n', ...) end
local vmap = function(...) vim.keymap.set('v', ...) end

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


-- Plugins

-- Copilot
vim.g.copilot_no_tab_map = true
imap('<C-J>', '<Plug>copilot#Accept("\\<CR>")', { noremap = true, silent = true })
