local treesitter = require("utils.treesitter")

return {
    -- 1. Tree-sitter parser manager
    {
        "romus204/tree-sitter-manager.nvim",
        cond = treesitter.has_cli,
        lazy = false,
        config = function()
            require("tree-sitter-manager").setup({
                ensure_installed = {
                    "markdown",
                    "markdown_inline",
                    "python",
                    "lua",
                    "html",
                    "latex",
                    "yaml"
                },
                auto_install = true,
                highlight = false,
            })

            local function enable_treesitter_highlight(args)
                if vim.bo[args.buf].buftype ~= "" then
                    return
                end

                local max_filesize = 1024 * 1024 -- 1MB
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))

                local filetype = vim.bo[args.buf].filetype
                if filetype == "" then
                    return
                end

                if filetype ~= "markdown" and (ok and stats and stats.size > max_filesize) then
                    return
                end

                local lang = vim.treesitter.language.get_lang(filetype)
                if lang and pcall(vim.treesitter.start, args.buf, lang) then
                    -- vim.notify("Treesitter highlighting enabled for " .. lang, vim.log.levels.INFO)
                    vim.bo[args.buf].syntax = lang
                end
            end

            local function enable_treesitter_highlight_for_loaded_buffers()
                for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(bufnr) then
                        enable_treesitter_highlight({ buf = bufnr })
                    end
                end
            end

            local highlight_group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true })

            -- Highlighting
            vim.api.nvim_create_autocmd("FileType", {
                group = highlight_group,
                callback = enable_treesitter_highlight,
            })

            vim.api.nvim_create_autocmd("VimEnter", {
                group = highlight_group,
                callback = enable_treesitter_highlight_for_loaded_buffers,
                once = true,
            })

            enable_treesitter_highlight_for_loaded_buffers()
            vim.schedule(enable_treesitter_highlight_for_loaded_buffers)
        end,
    },
}
