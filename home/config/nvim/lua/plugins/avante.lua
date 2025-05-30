return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    lazy = false,
    opts = {
        -- add any opts here
        provider = "copilot",
        mode = "legacy",
        auto_suggestions_provider = "gemini",
        openai = { model = "gpt-4o-mini" },
        gemini = { model = "gemini-2.0-flash", max_tokens = 32768 },
        copilot = { model = "gpt-4.1", max_tokens = 32768 },
        ollama = { model = "gemma3:12b", max_tokens = 32768, endpoint = "http://127.0.0.1:11434" },
        vendors = {
            ---@type AvanteProvider
            mlx = {
                __inherited_from = "openai",
                api_key_name = '',
                endpoint = "127.0.0.1:11433/v1",
                model = "mlx-community/Qwen2.5-Coder-7B-Instruct-4bit",
                max_tokens = 16384,
            },

            ---@type AvanteProvider
            deepseek = {
                __inherited_from = "openai",
                api_key_name = "DEEPSEEK_API_KEY",
                endpoint = "https://api.deepseek.com",
                model = "deepseek-chat",
                max_tokens = 32768,
            },
        },
        behavior = {
            enable_cursor_planning_mode = true,
        },
        mappings = {
            sidebar = {
                close = {},
            },
        },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
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
            -- Make sure to set this up properly if you have lazy=true
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
}
