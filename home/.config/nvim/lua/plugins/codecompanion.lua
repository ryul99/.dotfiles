-- codecompanion
return {
    "olimorris/codecompanion.nvim",
    opts = {
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
        default_prompts = {
            ["English Commentor"] = {
                strategy = "chat",
                description = "Fix comments to be easy to understand",
                opts = {
                    auto_submit = true,
                },
                prompts = {
                    {
                        role = "system",
                        -- ref: github.com/minty99/english-copilot
                        content =
                        [[You are an English language assistant designed to help software engineers who find it challenging to write comments in English.
                            Your role is to assist them in improving the clarity and fluency of their comments.
                            When provided with a comment, your task is to translate or convert its contents into natural and fluent English.
                            Correct any grammatical errors and ensure that the output text uses commonly understood English terminology.
                            Only output the resulting text without any additional explanations or annotations.
                            It is crucial to maintain any indentations or special characters present in the input, as the output will replace the original comment in the code editor.
                            For example, if the input is a code comment, you must preserve the comment symbols and indentations in the output.
                            Remember, the output should be formatted in a way that allows it to seamlessly replace the original text without requiring any further modifications.
                            Additionally, do not add code block annotations like backticks, even if the input is a code block.]]
                    },
                    {
                        role = "user",
                        content = function(context)
                            local code = require("codecompanion.helpers.actions").get_code(context.start_line,
                                context.end_line)
                            return "The input is:\n\n" .. code .. "\n"
                        end
                    }
                },
            }
        }
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope.nvim", -- Optional
        "stevearc/dressing.nvim",        -- Optional: Improves the default Neovim UI
    },
}
