return {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    lazy = true,
    version = "1.*",
    dependencies = {
        "xzbdmw/colorful-menu.nvim",
        "rafamadriz/friendly-snippets",
        "onsails/lspkind.nvim",
        "zbirenbaum/copilot.lua",
        {
            "giuxtaposition/blink-cmp-copilot",
            dependencies = { "zbirenbaum/copilot.lua" },
        },
    },
    opts = {
        keymap = {
            preset = "none",
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            ["<C-e>"] = { "show", "hide", "fallback" },
            ["<CR>"] = { "accept", "fallback" },
            ["<Tab>"] = {
                function() -- sidekick next edit suggestion
                    return require("sidekick").nes_jump_or_apply()
                end,
                -- function() -- if you are using Neovim's native inline completions
                --     return vim.lsp.inline_completion.get()
                -- end,
                "fallback",
            },
        },

        appearance = {
            nerd_font_variant = "mono",
        },

        completion = {
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 0,
                window = {
                    border = "rounded",
                    winhighlight = "Normal:NormalFloat,FloatBorder:TelescopeBorder",
                },
            },
            menu = {
                border = "rounded",
                winhighlight = "Normal:NormalFloat,FloatBorder:TelescopeBorder",
                draw = {
                    columns = {
                        { "label", "label_description", gap = 1 },
                        { "kind_icon", "kind" },
                    },
                    components = {
                        label = {
                            text = function(ctx)
                                return require("colorful-menu").blink_components_text(ctx)
                            end,
                            highlight = function(ctx)
                                return require("colorful-menu").blink_components_highlight(ctx)
                            end,
                        },
                        kind_icon = {
                            text = function(ctx)
                                local lspkind_ok, lspkind = pcall(require, "lspkind")
                                if lspkind_ok then
                                    local symbol_map = { Copilot = ""}
                                    local icon = symbol_map[ctx.kind] or lspkind.symbolic(ctx.kind, { mode = "symbol" })
                                    return icon .. " "
                                end
                                return ctx.icon_gap .. ctx.icon
                            end,
                            highlight = function(ctx)
                                return require("colorful-menu").blink_components_highlight(ctx)
                            end,
                        },
                        -- source_name = {
                        --     text = function(ctx)
                        --         local source_names = {
                        --             buffer = "[Buffer]",
                        --             nvim_lua = "[Lua]",
                        --             lsp = "[LSP]",
                        --             path = "[Path]",
                        --             snippets = "[Snippet]",
                        --             luasnip = "[LuaSnip]",
                        --             copilot = "[Copilot]",
                        --         }
                        --         return source_names[ctx.source_name] or "[" .. ctx.source_name .. "]"
                        --     end,
                        -- },
                    },
                    treesitter = { "lsp" },
                },
            },
            ghost_text = { enabled = false },
        },

        signature = {
            enabled = true,
            window = {
                border = "rounded",
            },
        },

        cmdline = {
            keymap = { preset = 'inherit' },
            completion = { menu = { auto_show = false } },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer", "copilot" },
            providers = {
                lsp = {
                    min_keyword_length = 3,
                    fallbacks = {},
                },
                copilot = {
                    name = "copilot",
                    module = "blink-cmp-copilot",
                    score_offset = 100,
                    async = true,
                },
            },
        },
    },
    enable = true,
}
