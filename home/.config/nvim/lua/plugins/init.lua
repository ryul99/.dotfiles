return {
    "itchyny/lightline.vim",
    "simnalamburt/vim-mundo",
    "vim-utils/vim-interruptless",
    "junegunn/gv.vim",
    "editorconfig/editorconfig-vim",
    "airblade/vim-gitgutter",
    "junegunn/fzf.vim",
    "junegunn/fzf",
    "vim-scripts/BufOnly.vim",
    "google/vim-searchindex",

    {
        dir = "~/.fzf",
        build = "fzf#install()",
    },

    "AndrewRadev/splitjoin.vim",

    "lambdalisue/suda.vim",

    -- The Pope
    "tpope/vim-fugitive",
    "tpope/vim-sensible",
    "tpope/vim-obsession",
    "tpope/vim-vinegar",
    "tpope/vim-commentary",

    -- Visual
    "Yggdroot/indentLine",
    "ntpeters/vim-better-whitespace",
    {
        "folke/tokyonight.nvim",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- load the colorscheme here
            vim.cmd([[colorscheme tokyonight]])
        end,
    },
    "preservim/tagbar",
    "stevearc/dressing.nvim",
    {
        "rcarriga/nvim-notify",
        config = function()
            vim.notify = require("notify")
        end,
    },
    {
        "ellisonleao/glow.nvim",
        config = function()
            require("glow").setup()
        end,
    },
    "mg979/vim-visual-multi",
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup({
                -- -NOTE: If given `false` then the plugin won't create any mappings
                mappings = {
                    ---Extra mapping; `gco`, `gcO`, `gcA`
                    extra = false,
                },
            })
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        version = "0.1.6",
        -- or                            , branch = '0.1.x',
        dependencies = { { "nvim-lua/plenary.nvim" } },
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
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
                        { source = "remote" },
                    },
                },
            })
        end,
    },
    "miversen33/netman.nvim",
    {
        "kevinhwang91/nvim-ufo",
        dependencies = {
            "kevinhwang91/promise-async",
            {
                "luukvbaal/statuscol.nvim",
                config = function()
                    local builtin = require("statuscol.builtin")
                    require("statuscol").setup({
                        relculright = true,
                        segments = {
                            { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
                            { text = { "%s" }, click = "v:lua.ScSa" },
                            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
                        },
                    })
                end,
            },
        },
        config = function()
            vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
            vim.o.foldcolumn = "1" -- '0' is not bad
            vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
        end,
    },

    -- Language server and Auto completion
    "liuchengxu/vista.vim",
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-lint",
    "mhartington/formatter.nvim",
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            require("dapui").setup()
        end,
    },
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
            ts_update()
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = "nvim-treesitter/nvim-treesitter",
    },
    {
        "FabijanZulj/blame.nvim",
        config = function()
            require("blame").setup({
                date_format = "%Y.%m.%d",
            })
        end,
    },
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup()
        end,
    },

    -- rust
    {
        "mrcjkb/rustaceanvim",
        version = "^4", -- Recommended
        ft = { "rust" },
    },

    -- jupyter
    {
        "kiyoon/jupynium.nvim",
        build = "pip3 install --user .",
        config = function()
            require("jupynium").setup({
                use_default_keybindings = false,
            })
            vim.cmd([[
            hi! link JupyniumCodeCellSeparator CursorLine
            hi! link JupyniumMarkdownCellSeparator CursorLine
            hi! link JupyniumMarkdownCellContent CursorLine
            hi! link JupyniumMagicCommand Keyword
            ]])
        end,
    },

    -- git-conflict
    { 'akinsho/git-conflict.nvim', version = "*", config = true },

    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!:).
        -- run = "make install_jsregexp"
    },
    {
        "vhyrro/luarocks.nvim",
        priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
        config = true,
    },
}
