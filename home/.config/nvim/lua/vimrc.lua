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
o.mouse = a

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
-- >>> Packer Plugins >>>
--

local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim",
                                  install_path})
    print("Installing packer close and reopen Neovim...")
    vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init({
    display = {
        open_fn = function()
            return require("packer.util").float({
                border = "rounded"
            })
        end
    }
})

return packer.startup(function(use)
    use "wbthomason/packer.nvim" -- Have packer manage itself

    use 'itchyny/lightline.vim'
    use 'simnalamburt/vim-mundo'
    use 'vim-utils/vim-interruptless'
    use 'junegunn/gv.vim'
    use 'editorconfig/editorconfig-vim'
    use 'easymotion/vim-easymotion'
    use 'airblade/vim-gitgutter'
    use 'junegunn/fzf.vim'
    use 'junegunn/fzf'
    use 'vim-scripts/BufOnly.vim'
    use 'google/vim-searchindex'
    use 'kshenoy/vim-signature'

    use {
        '~/.fzf',
        run = 'fzf#install()'
    }

    use 'AndrewRadev/splitjoin.vim'

    if vim.fn.has('nvim') then
        use 'lambdalisue/suda.vim'
    end

    -- The Pope
    use 'tpope/vim-fugitive'
    use 'tpope/vim-sensible'
    use 'tpope/vim-obsession'
    use 'tpope/vim-vinegar'
    use 'tpope/vim-commentary'

    -- Visual
    use 'Yggdroot/indentLine'
    use 'ntpeters/vim-better-whitespace'
    use 'connorholyday/vim-snazzy'

    -- Languages
    use 'HerringtonDarkholme/yats.vim'
    use 'cespare/vim-toml'
    use 'elzr/vim-json'
    use 'neoclide/jsonc.vim'
    use 'hashivim/vim-terraform'
    use 'nirum-lang/nirum.vim'
    use 'neovimhaskell/haskell-vim'
    use 'pangloss/vim-javascript'
    use 'jason0x43/vim-js-indent'
    use 'leafgarland/typescript-vim'
    use 'peitalin/vim-jsx-typescript'

    -- Language server and Auto completion
    use 'liuchengxu/vista.vim'
    use 'prabirshrestha/vim-lsp'
    use 'mattn/vim-lsp-settings'
    use 'prabirshrestha/asyncomplete.vim'
    use 'prabirshrestha/asyncomplete-lsp.vim'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }
    -- use 'bfrg/vim-cpp-modern'

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
    vim.cmd([[autocmd FileType markdown let g:indentLine_enabled=false]])
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
    local treesitter = require('treesitter')

    -- vim-cpp-modern
    vim.g.cpp_attributes_highlight = true
    vim.g.cpp_member_highlight = true
    vim.g.cpp_simple_highlight = true

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
    vim.api.nvim_create_autocmd("Filetype", {
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

    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)

--
-- <<< Packer Plugins <<<
--

