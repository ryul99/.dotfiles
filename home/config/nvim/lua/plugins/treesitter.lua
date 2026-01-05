-- install only when 1. not installed and 2. stable language
local function need_install(lang)
    local ok, _ = pcall(vim.treesitter.get_string_parser, "", lang)
    if ok then
        return false
    end

    local ok, nt = pcall(require, "nvim-treesitter")
    if not ok then
        return false
    end

    local stable_langs = nt.get_available(1)
    return vim.tbl_contains(stable_langs, lang)
end

return {
    -- 1. nvim-treesitter (Core)
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({})

            -- ensure install
            local ensure_installed = { "markdown", "markdown_inline", "python", "lua" }
            for _, lang in ipairs(ensure_installed) do
                if need_install(lang) then
                    require("nvim-treesitter").install({ lang })
                end
            end

            local lang = vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype

            -- auto install
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("TreesitterAutoInstall", { clear = true }),
                callback = function(_)
                    if not lang then
                        return
                    end

                    if need_install(lang) then
                        require("nvim-treesitter").install({ lang })
                    end
                end,
            })

            -- Highlighting
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
                callback = function(args)
                    local max_filesize = 1024 * 1024 -- 1MB
                    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))

                    if vim.bo.filetype ~= "markdown" and (ok and stats and stats.size > max_filesize) then
                        return
                    end

                    if pcall(vim.treesitter.get_parser, args.buf, lang) then
                        vim.treesitter.start()
                    end

                    -- use vim's native syntax highlighting too
                    vim.cmd("syntax on")
                end,
            })
        end,
    },

    -- 2. nvim-treesitter-textobjects (Extension)
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                textobjects = {
                    move = {
                        enable = true,
                        set_jumps = false,
                        goto_next_start = {
                            ["]b"] = { query = "@code_cell.inner", desc = "Next code block" },
                        },
                        goto_previous_start = {
                            ["[b"] = { query = "@code_cell.inner", desc = "Previous code block" },
                        },
                    },
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["ib"] = { query = "@code_cell.inner", desc = "Inside block" },
                            ["ab"] = { query = "@code_cell.outer", desc = "Around block" },
                        },
                    },
                },
            })
        end,
    },
}
