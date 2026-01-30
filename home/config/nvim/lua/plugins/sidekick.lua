return {
    "folke/sidekick.nvim",
    opts = {
        -- add any options here
        cli = {
            mux = {
                backend = "tmux",
                enabled = true,
            },
        },
    },
    -- stylua: ignore
    keys = {
        {
            "<leader>ns",
            function()
                require("sidekick.nes").update()
            end,
            desc = "Request NES suggestions",
        },
        {
            "<tab>",
            function()
                -- if there is a next edit, jump to it, otherwise apply it if any
                if require("sidekick").nes_jump_or_apply() then
                    return -- jumped or applied
                end

                -- -- if you are using Neovim's native inline completions
                -- if vim.lsp.inline_completion.get() then
                --     return
                -- end

                -- any other things (like snippets) you want to do on <tab> go here.

                -- fall back to normal tab
                return "<tab>"
            end,
            mode = { "n", "i" },
            expr = true,
            desc = "Goto/Apply Next Edit Suggestion",
        },
        {
            "<c-.>",
            function() require("sidekick.cli").toggle() end,
            desc = "Sidekick Toggle",
            mode = { "n", "t", "i", "x" },
        },
        {
            "<leader>sa",
            function() require("sidekick.cli").toggle() end,
            desc = "Sidekick Toggle CLI",
        },
        {
            "<leader>ss",
            function() require("sidekick.cli").select() end,
            -- Or to select only installed tools:
            -- require("sidekick.cli").select({ filter = { installed = true } })
            desc = "Select CLI",
        },
        {
            "<leader>sd",
            function() require("sidekick.cli").close() end,
            desc = "Detach a CLI Session",
        },
        {
            "<leader>st",
            function() require("sidekick.cli").send({ msg = "{this}" }) end,
            mode = { "x", "n" },
            desc = "Send This",
        },
        {
            "<leader>sf",
            function() require("sidekick.cli").send({ msg = "{file}" }) end,
            desc = "Send File",
        },
        {
            "<leader>sv",
            function() require("sidekick.cli").send({ msg = "{selection}" }) end,
            mode = { "x" },
            desc = "Send Visual Selection",
        },
        {
            "<leader>sp",
            function() require("sidekick.cli").prompt() end,
            mode = { "n", "x" },
            desc = "Sidekick Select Prompt",
        },
    },
}
