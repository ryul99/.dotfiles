require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all" (the five listed parsers should always be installed)
    ensure_installed = { "markdown" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    -- List of parsers to ignore installing (or "all")
    -- ignore_install = { "javascript" },

    ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
    -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

    highlight = {
        enable = true,

        -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
        -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
        -- the name of the parser)
        -- list of language that will be disabled
        -- disable = { "c", "rust" },
        -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
        disable = function(lang, buf)
            -- jupyter notebook
            if vim.bo.filetype == "markdown" then
                return false
            end
            local max_filesize = 1024 * 1024 -- Byte
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = true,
    },

    textobjects = {
        move = {
            enable = true,
            set_jumps = false, -- you can change this if you want.
            goto_next_start = {
                --- ... other keymaps
                ["]b"] = { query = "@code_cell.inner", desc = "next code block" },
            },
            goto_previous_start = {
                --- ... other keymaps
                ["[b"] = { query = "@code_cell.inner", desc = "previous code block" },
            },
        },
        select = {
            enable = true,
            lookahead = true, -- you can change this if you want
            keymaps = {
                --- ... other keymaps
                ["ib"] = { query = "@code_cell.inner", desc = "in block" },
                ["ab"] = { query = "@code_cell.outer", desc = "around block" },
            },
        },
    }
}
