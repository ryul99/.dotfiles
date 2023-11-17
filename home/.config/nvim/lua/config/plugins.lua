--
-- Plugin Configs
--

vim.g.python3_host_prog = '/usr/bin/python'

-- Persistent history
if vim.fn.has('persistent_undo') then
    vim.cmd([[
  let vimdir='$HOME/.vim'
  let &runtimepath.=','.vimdir
  let vimundodir=expand(vimdir.'/undodir')
  call system('mkdir -p '.vimundodir)

  let &undodir=vimundodir
  set undofile
]])
end

-- indentLine
km.set('n', '<leader>i', ':IndentLinesToggle<CR>', {
    silent = true
})
vim.g.indentLine_char = '▏'

-- vim-better-whitespace
vim.g.better_whitespace_enabled = true
vim.g.strip_whitespace_on_save = true
vim.g.strip_whitespace_confirm = false

-- mundo.vim
vim.g.mundo_right = 1
km.set('n', '<leader>m', ':MundoToggle<CR>', {
    silent = true
})

-- theme
vim.cmd([[colorscheme snazzy]])
vim.g.SnazzyTransparent = 1

-- lightline
-- init lightline
vim.g.lightline = {
    colorscheme = 'snazzy',
    active = {
        left = {{'mode', 'paste'}, {'filename', 'readonly'}, {'currentfunction'}, {'truncate_here'}},
        right = {{'lineinfo'}, {'percent'}, {'gitbranch', 'fileformat', 'fileencoding', 'filetype'}}
    },
    component = {
        truncate_here = '%<'
    },
    component_visible_condition = {
        truncate_here = 0
    },
    component_type = {
        truncate_here = 'raw'
    },
    component_function = {
        readonly = 'LightlineReadonly',
        filename = 'LightlineFilename',
        fileformat = 'LightlineFileformat',
        fileencoding = 'LightlineFileencoding',
        filetype = 'LightlineFiletype',
        gitbranch = 'FugitiveHead',
        currentfunction = 'NearestMethodOrFunction'
    }
}

vim.cmd([[
function! LightlineReadonly()
  return &readonly && &filetype !=# 'help' ? 'RO' : ''
endfunction

function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction

function! LightlineFileformat()
  return winwidth(0) > 90 ? &fileformat : ''
endfunction

function! LightlineFileencoding()
  return winwidth(0) > 100 ? &fileencoding : ''
endfunction

function! LightlineFiletype()
  return winwidth(0) > 80 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! NearestMethodOrFunction()
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction
]])

-- fzf
vim.cmd([[
let g:fzf_action = {
  \     'ctrl-t': 'tab split',
  \     'ctrl-x': 'split',
  \     'ctrl-v': 'vsplit',
  \ }
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(
  \     <q-args>,
  \     fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline']}),
  \     <bang>0)
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \     'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>),
  \     1,
  \     fzf#vim#with_preview(),
  \     <bang>0)
]])
km.set('n', '<leader><Tab>', ':Files<CR>')
km.set('n', '<leader><leader><Tab>', ':Files!<CR>')
km.set('n', '<leader>q', ':Buffers<CR>')
km.set('n', '<leader><leader>q', ':Buffers!<CR>')
km.set('n', '<leader>r', ':Rg<space>')
km.set('n', '<leader><leader>r', ':Rg!<space>')

-- gv
km.set('n', '<leader>g', ':GV<CR>')
km.set('n', '<leader><leader>g', ':GV!<CR>', {
    silent = true
})

-- gitgutter
km.set('n', '<leader>G', ':GitGutterToggle<CR>', {
    silent = true
})

-- vim-obsession
km.set('n', '<leader>o', ':Obsess<CR>', {
    silent = true
})
km.set('n', '<leader>O', ':Obsess!<CR>', {
    silent = true
})

-- float-preview
vim.g['float_preview#docked'] = true

-- BufOnly.vim
vim.cmd([[
command! -nargs=? -complete=buffer -bang Bo
\ :call BufOnly('<args>', '<bang>')
]])

-- vim-json
vim.g.vim_json_syntax_conceal = false

-- alt
vim.cmd([[
function! AltCommand(path, vim_command)
  let l:alternate = system("alt " . a:path)
  if empty(l:alternate)
    echo "No alternate file for " . a:path . " exists!"
  else
    exec a:vim_command . " " . l:alternate
  endif
endfunction
]])

km.set('n', '<leader>.', ":call AltCommand(expand('%'), ':e')<cr>")

-- vim-commentary
km.set('n', '<C-/>', 'gcc')
km.set('i', '<C-/>', '<ESC>gcca')

-- vim-vinegar
km.set('n', '=', '<C-^>')

-- vista
km.set('n', '<leader>v', ':Vista!!<CR>')
km.set('n', '<leader><leader>v', ':Vista finder<CR>')

vim.cmd([[
let g:vista#finders = ['fzf']
let g:vista_fzf_preview = ['right:50%']
]])

-- typescript.tsx
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = {"*.tsx", "*.jsx"},
    command = "set filetype=typescriptreact"
})

-- treesitter
local treesitter = require('plugins/treesitter')

-- tagbar
km.set('n', '<F8>', ':TagbarToggle<CR>')

-- vim-cpp-modern
-- vim.g.cpp_attributes_highlight = true
-- vim.g.cpp_member_highlight = true
-- vim.g.cpp_simple_highlight = true

-- Filetype specific

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = "*.yaml.example",
    command = "set ft=yaml"
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "json",
    command = "setlocal sw=2 sts=2 et"
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "yaml",
    command = "setlocal sw=2 sts=2 et"
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "yaml",
    command = "setlocal indentkeys-=<:>"
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "yaml",
    command = "setlocal indentkeys-=:"
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "sql",
    command = "setlocal sw=2 sts=2 et"
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    command = "setlocal indentkeys-=<:>"
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    command = "setlocal indentkeys-=:"
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "terraform",
    command = "nnoremap <silent> <leader>f :TerraformFmt<cr>"
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "rust",
    command = "setlocal matchpairs+=<:>"
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    command = "DisableStripWhitespaceOnSave"
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "scss",
    command = "setlocal sw=2 sts=2 et"
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "css",
    command = "setlocal sw=2 sts=2 et"
})

