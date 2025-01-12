-- Snippet generation
return {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    lazy = true,
    config = function()
        local cmp = require("cmp")

        local has_words_before = function()
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
        end

        cmp.setup({
            preselect = cmp.PreselectMode.None,
            completion = { completeopt = "menu,menuone,noinsert,noselect", keyword_length = 1 },
            experimental = { native_menu = false, ghost_text = false },
            formatting = {
                format = function(entry, vim_item)
                    vim_item.menu = ({
                        buffer = "[Buffer]",
                        nvim_lua = "[Lua]",
                        treesitter = "[Treesitter]",
                        nvim_lsp = "[LSP]",
                    })[entry.source.name]
                    return vim_item
                end,
            },
            mapping = {
                ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
                ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
                ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
                ["<C-e>"] = cmp.mapping { i = cmp.mapping.close(), c = cmp.mapping.close() },
                ["<CR>"] = cmp.mapping {
                    i = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false },
                    -- c = function(fallback)
                    --     if cmp.visible() then
                    --         cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
                    --     else
                    --         fallback()
                    --     end
                    -- end,
                },
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, {
                    "i",
                    "s",
                    "c",
                }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end, {
                    "i",
                    "s",
                    "c",
                }),
            },
            sources = {
                { name = "nvim_lua" },
                { name = 'nvim_lsp',               keyword_length = 3 },
                { name = 'nvim_lsp_signature_help' },
                { name = "treesitter" },
                { name = "buffer" },
                { name = "path" },
                { name = "calc" },
                { name = "spell" },
                { name = "luasnip" },
                { name = "jupynium",               priority = 1000 }, -- consider higher priority than LSP
                { name = "nvim_lsp",               priority = 100 },
            },
            window = {
                documentation = cmp.config.window.bordered(),
            },
            sorting = {
                priority_weight = 1.0,
                comparators = {
                    cmp.config.compare.score, -- Jupyter kernel completion shows prior to LSP
                    cmp.config.compare.recently_used,
                    cmp.config.compare.locality,
                    -- ...
                },
            },
            -- documentation = {
            --  border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            --  winhighlight = "NormalFloat:NormalFloat,FloatBorder:TelescopeBorder",
            -- },
        })

        -- Use buffer source for `/`
        cmp.setup.cmdline("/", {
            sources = {
                { name = "buffer" },
            }
        })

        -- Use cmdline & path source for ':'
        cmp.setup.cmdline(":", {
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
        })
    end,
    dependencies = {
        "ray-x/cmp-treesitter",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-calc",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
    },
    enable = true,
}
