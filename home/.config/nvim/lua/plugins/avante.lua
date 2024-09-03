return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    opts = {
        -- add any opts here
        provider = "openai",
        openai = { model = "gpt-4o-mini" },
        vendors = {
            ---@type AvanteProvider
            ollama = {
                ["local"] = true,
                endpoint = "127.0.0.1:11434/v1",
                model = "codegemma",
                parse_curl_args = function(opts, code_opts)
                    return {
                        url = opts.endpoint .. "/chat/completions",
                        headers = {
                            ["Accept"] = "application/json",
                            ["Content-Type"] = "application/json",
                        },
                        body = {
                            model = opts.model,
                            messages = require("avante.providers").copilot.parse_message(code_opts), -- you can make your own message, but this is very advanced
                            max_tokens = 2048,
                            stream = true,
                        },
                    }
                end,
                parse_response_data = function(data_stream, event_state, opts)
                    require("avante.providers").openai.parse_response(data_stream, event_state, opts)
                end,
            },

            ---@type AvanteProvider
            deepseek = {
                endpoint = "https://api.deepseek.com/chat/completions",
                model = "deepseek-coder",
                api_key_name = "DEEPSEEK_API_KEY",
                parse_curl_args = function(opts, code_opts)
                    return {
                        url = opts.endpoint,
                        headers = {
                            ["Accept"] = "application/json",
                            ["Content-Type"] = "application/json",
                            ["Authorization"] = "Bearer " .. os.getenv(opts.api_key_name),
                        },
                        body = {
                            model = opts.model,
                            messages = { -- you can make your own message, but this is very advanced
                                { role = "system", content = code_opts.system_prompt },
                                { role = "user",   content = require("avante.providers.openai").get_user_message(code_opts) },
                            },
                            temperature = 0,
                            max_tokens = 4096,
                            stream = true, -- this will be set by default.
                        },
                    }
                end,
                parse_response_data = function(data_stream, event_state, opts)
                    require("avante.providers").openai.parse_response(data_stream, event_state, opts)
                end,
            },
        },
    },
    build = ":AvanteBuild", -- This is optional, recommended tho. Also note that this will block the startup for a bit since we are compiling bindings in Rust.
    dependencies = {
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        "zbirenbaum/copilot.lua", -- for providers='copilot'
        {
            -- support for image pasting
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
                -- recommended settings
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = {
                        insert_mode = true,
                    },
                    -- required for Windows users
                    use_absolute_path = true,
                },
            },
        },
        {
            -- Make sure to setup it properly if you have lazy=true
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
}
