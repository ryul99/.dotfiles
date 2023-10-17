--
-- >>> Packer Plugins >>>
--

local o = vim.opt
local km = vim.keymap
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
    use 'preservim/tagbar'

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

      -- Snippet generation
    use {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        opt = true,
        config = function()
            require("config.cmp").setup()
        end,
        requires = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lua",
            "ray-x/cmp-treesitter",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
        },
        disable = false,
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

    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)

--
-- <<< Packer Plugins <<<
--

