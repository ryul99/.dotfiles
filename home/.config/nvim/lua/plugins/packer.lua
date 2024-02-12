--
-- >>> Packer Plugins >>>
--

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
    use 'stevearc/dressing.nvim'
    use {"ellisonleao/glow.nvim", config = function() require("glow").setup() end}

    -- Language server and Auto completion
    use 'liuchengxu/vista.vim'
    use 'neovim/nvim-lspconfig'
    use 'VonHeikemen/lsp-zero.nvim'
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup({
                ---NOTE: If given `false` then the plugin won't create any mappings
                mappings = {
                    ---Extra mapping; `gco`, `gcO`, `gcA`
                    extra = false,
                },
            })
        end
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

    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)

--
-- <<< Packer Plugins <<<
--

