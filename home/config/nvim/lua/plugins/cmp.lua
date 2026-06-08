local function select_blink_item(direction, cmp)
    cmp = cmp or require("blink.cmp")

    if cmp.is_menu_visible() then
        if direction == "next" then
            return cmp.select_next()
        end
        return cmp.select_prev()
    end

    local list = require("blink.cmp.completion.list")
    if cmp.is_active() and #list.items > 0 then
        vim.schedule(function()
            if direction == "next" then
                list.select_next({ auto_insert = false })
            else
                list.select_prev({ auto_insert = false })
            end
        end)
        return true
    end
end

local function blink_select(direction)
    return function(cmp)
        return select_blink_item(direction, cmp)
    end
end

local function set_insert_select_keymap(lhs, direction)
    local fallback = require("blink.cmp.keymap.fallback").wrap("i", lhs)
    vim.keymap.set("i", lhs, function()
        if select_blink_item(direction) then
            return ""
        end
        return fallback()
    end, {
        buffer = true,
        desc = "blink.cmp: Select " .. (direction == "next" and "Next" or "Prev"),
        expr = true,
        replace_keycodes = false,
        silent = true,
    })
end

local function ensure_insert_select_keymaps()
    set_insert_select_keymap("<NL>", "next")
    set_insert_select_keymap("<C-j>", "next")
    set_insert_select_keymap("<C-k>", "prev")
end

local function setup_insert_select_keymaps()
    vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
            vim.schedule(ensure_insert_select_keymaps)
        end,
    })

    if vim.api.nvim_get_mode().mode == "i" then
        vim.schedule(ensure_insert_select_keymaps)
    end
end

return {
    "saghen/blink.cmp",
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
            ["<C-k>"] = { blink_select("prev"), "fallback" },
            ["<C-j>"] = { blink_select("next"), "fallback" },
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            ["<C-e>"] = { "show", "hide", "fallback" },
            ["<C-]>"] = { "accept", "fallback" },
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
                                    local icon = symbol_map[ctx.kind] or lspkind.symbol_map[ctx.kind]
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
            list = { selection = { preselect = false, auto_insert = false } }
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
    config = function(_, opts)
        require("blink.cmp").setup(opts)
        setup_insert_select_keymaps()
    end,
    enable = true,
}
