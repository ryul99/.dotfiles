-- codecompanion
require("codecompanion").setup({
    strategies = {
        chat = {
            adapter = "openai",
        },
        inline = {
            adapter = "openai",
        },
        agent = {
            adapter = "openai",
        },
    },
    adapters = {
        openai = function()
            return require("codecompanion.adapters").extend("openai", {
                schema = {
                    model = {
                        default = "gpt-4o-mini",
                    },
                },
            })
        end,
    },
})

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
