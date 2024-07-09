local imap = function(...) vim.keymap.set('i', ...) end
local nmap = function(...) vim.keymap.set('n', ...) end
local vmap = function(...) vim.keymap.set('v', ...) end
local cmap = function(...) vim.keymap.set('c', ...) end

--
-- Key Mappings
--

-- Toggle *conceallevel*
nmap('<Leader>c', ":let &cole=(&cole == 2) ? 0 : 2 <bar> echo 'conceallevel ' . &cole <CR>")

-- diagnostic
nmap('<leader>e', ':lua vim.diagnostic.open_float(0, {scope="line"})<CR>')

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
nmap('<C-A-h>', ':vertical resize -2<CR>', {
    silent = true
})
nmap('<C-A-j>', ':resize -2<CR>', {
    silent = true
})
nmap('<C-A-k>', ':resize +2<CR>', {
    silent = true
})
nmap('<C-A-l>', ':vertical resize +2<CR>', {
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

-- save with sudo
if vim.fn.has('nvim') then
    cmap('w!!', 'w suda://%')
else
    -- cmap w!! w !sudo tee %
    cmap('w!!', 'w !sudo tee %')
end


-- Plugins

-- tagbar
nmap('<F8>', ':TagbarToggle<CR>')

-- neotree
nmap('<leader>T', ':Neotree toggle<CR>')

-- indentline
nmap('<leader>i', ':IndentLinesToggle<CR>', {
    silent = true
})

-- fzf
nmap('<leader><Tab>', ':Files<CR>')
nmap('<leader><leader><Tab>', ':Files!<CR>')
nmap('<leader>q', ':Buffers<CR>')
nmap('<leader><leader>q', ':Buffers!<CR>')
nmap('<leader>r', ':Rg<space>')
nmap('<leader><leader>r', ':Rg!<space>')

-- gv
nmap('<leader>g', ':GV<CR>')
nmap('<leader><leader>g', ':GV!<CR>', {
    silent = true
})

-- gitgutter
nmap('<leader>G', ':GitGutterToggle<CR>', {
    silent = true
})

-- vim-obsession
nmap('<leader>o', ':Obsess<CR>', {
    silent = true
})
nmap('<leader>O', ':Obsess!<CR>', {
    silent = true
})

-- alt
nmap('<leader>.', ":call AltCommand(expand('%'), ':e')<cr>")

-- vim-commentary
nmap('<C-/>', 'gcc')
imap('<C-/>', '<ESC>gcca')

-- vim-vinegar
nmap('=', '<C-^>')

-- vista
nmap('<leader>v', ':Vista!!<CR>')
nmap('<leader><leader>v', ':Vista finder<CR>')

-- mundo
nmap('<leader>m', ':MundoToggle<CR>', {
    silent = true
})

-- telescope.nvim
local status_ok, telescope = pcall(require, "telescope.builtin")
if status_ok then
    nmap('<leader>ff', telescope.find_files, {})
    nmap('<leader>fg', telescope.live_grep, {})
    nmap('<leader>fb', telescope.buffers, {})
    nmap('<leader>fh', telescope.help_tags, {})
end

-- jupynium
vim.keymap.set(
  { "n", "x" },
  "<localleader>x",
  "<cmd>JupyniumExecuteSelectedCells<CR>",
  { buffer = buf_id, desc = "Jupynium execute selected cells" }
)
vim.keymap.set(
  { "n", "x" },
  "<localleader>c",
  "<cmd>JupyniumClearSelectedCellsOutputs<CR>",
  { buffer = buf_id, desc = "Jupynium clear selected cells" }
)
vim.keymap.set(
  { "n" },
  "<localleader>K",
  "<cmd>JupyniumKernelHover<cr>",
  { buffer = buf_id, desc = "Jupynium hover (inspect a variable)" }
)
vim.keymap.set(
  { "n", "x" },
  "<localleader>js",
  "<cmd>JupyniumScrollToCell<cr>",
  { buffer = buf_id, desc = "Jupynium scroll to cell" }
)
vim.keymap.set(
  { "n", "x" },
  "<localleader>jo",
  "<cmd>JupyniumToggleSelectedCellsOutputsScroll<cr>",
  { buffer = buf_id, desc = "Jupynium toggle selected cell output scroll" }
)
vim.keymap.set("", "<PageUp>", "<cmd>JupyniumScrollUp<cr>", { buffer = buf_id, desc = "Jupynium scroll up" })
vim.keymap.set("", "<PageDown>", "<cmd>JupyniumScrollDown<cr>", { buffer = buf_id, desc = "Jupynium scroll down" })

