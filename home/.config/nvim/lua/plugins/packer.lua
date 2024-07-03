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
    use 'airblade/vim-gitgutter'
    use 'junegunn/fzf.vim'
    use 'junegunn/fzf'
    use 'vim-scripts/BufOnly.vim'
    use 'google/vim-searchindex'

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
    use 'rebelot/kanagawa.nvim'
    use 'preservim/tagbar'
    use 'stevearc/dressing.nvim'
    use {"ellisonleao/glow.nvim", config = function() require("glow").setup() end}
    use 'mg979/vim-visual-multi'
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
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.6',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
            "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
        },
        config = function()
            require("neo-tree").setup({
                sources = {
                    "filesystem", -- Neotree filesystem source
                    "buffers",
                    "git_status",
                    "netman.ui.neo-tree",
                },
                source_selector = {
                    winbar = true,
                    sources = {
                        { source = "filesystem" },
                        { source = "buffers" },
                        { source = "git_status" },
                        -- Any other items you had in your source selector
                        -- Just add the netman source as well
                        { source = "remote" }
                    }
                }
            })
        end
    }
    use "miversen33/netman.nvim"

    -- Language server and Auto completion
    use 'liuchengxu/vista.vim'
    use 'neovim/nvim-lspconfig'
    use 'mfussenegger/nvim-lint'
    use 'mhartington/formatter.nvim'
    use {
        "rcarriga/nvim-dap-ui",
        requires = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
        config = function()
            require("dapui").setup()
        end,
    }
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
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({})
        end,
    }

    -- rust
    use {
        'mrcjkb/rustaceanvim',
        version = '^4', -- Recommended
        ft = { 'rust' },
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
            "ray-x/cmp-treesitter",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-calc",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
        },
        disable = false,
    }
    use {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        tag = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!:).
        -- run = "make install_jsregexp"
    }


    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)

--
-- <<< Packer Plugins <<<
--

