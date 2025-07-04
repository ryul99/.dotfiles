return {
    "itchyny/lightline.vim",
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
        "debugloop/telescope-undo.nvim",
        dependencies = { -- note how they're inverted to above example
            {
                "nvim-telescope/telescope.nvim",
                dependencies = { "nvim-lua/plenary.nvim" },
            },
        },
        keys = {
            { -- lazy style key map
                "<leader>u",
                "<cmd>Telescope undo<cr>",
                desc = "undo history",
            },
        },
        opts = {
            -- don't use `defaults = { }` here, do this in the main telescope spec
            extensions = {
                undo = {
                    -- telescope-undo.nvim config, see below
                    side_by_side = true,
                    layout_strategy = "vertical",
                    layout_config = {
                        preview_height = 0.6,
                    },
                    entry_format = "state #$ID, $STAT, $TIME",
                },
                -- no other extensions here, they can have their own spec too
            },
        },
        config = function(_, opts)
            -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
            -- configs for us. We won't use data, as everything is in it's own namespace (telescope
            -- defaults, as well as each extension).
            require("telescope").setup(opts)
            require("telescope").load_extension("undo")
        end,
    },
    -- "miversen33/netman.nvim",
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
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            delay = 500,
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },
    {
        'stevearc/oil.nvim',
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {
            default_file_explorer = false,
        },
        -- Optional dependencies
        -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
        -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
        lazy = false,
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
    {
        'jmbuhr/otter.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        opts = {},
    },
    {
        "boltlessengineer/sense.nvim",
        config = function()
            vim.g.sense_nvim = {
                _log_level = vim.log.levels.ERROR,
            }
        end,
        enabled = function()
            if vim.fn.executable("luarocks") == 0 then
                return false
            end
            return true
        end,
    },

    -- rust
    {
        "mrcjkb/rustaceanvim",
        version = "^4", -- Recommended
        ft = { "rust" },
    },

    -- jupyter
    -- {
    --     "kiyoon/jupynium.nvim",
    --     build = "pip3 install --user .",
    --     config = function()
    --         require("jupynium").setup({
    --             use_default_keybindings = false,
    --         })
    --         vim.cmd([[
    --         hi! link JupyniumCodeCellSeparator CursorLine
    --         hi! link JupyniumMarkdownCellSeparator CursorLine
    --         hi! link JupyniumMarkdownCellContent CursorLine
    --         hi! link JupyniumMagicCommand Keyword
    --         ]])
    --     end,
    -- },

    -- git-conflict
    { 'akinsho/git-conflict.nvim', version = "*", config = true },

    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!:).
        -- run = "make install_jsregexp"
    },
    -- {
    --     "vhyrro/luarocks.nvim",
    --     priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
    --     config = true,
    -- },
    {
        'beeender/richclip.nvim',
        config = function()
            require("richclip").setup({ set_g_clipboard = false })
        end
    },

    {
        "ggml-org/llama.vim",
        init = function()
            vim.g.llama_config = {
                show_info = 0,
                keymap_trigger = "",
                keymap_accept_full = "",
                keymap_accept_line = "<C-l>",
                keymap_accept_word = "<C-B>",
            }
        end,
    },
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                suggestion = { enabled = false },
                panel = { enabled = false },
                filetypes = { yaml = true, markdown = true },
                copilot_model = "gpt-4o-copilot",
            })
        end,
    },
    {
        "Exafunction/windsurf.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            require("codeium").setup({
            })
        end
    },
}
