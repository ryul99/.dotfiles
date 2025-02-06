return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    opts = {
        -- add any opts here
        provider = "gemini",
        auto_suggestions_provider = "gemini",
        openai = { model = "gpt-4o-mini" },
        gemini = { model = "gemini-2.0-flash-exp", max_tokens = 8192 },
        copilot = { model = "o3-mini", max_tokens = 16384 },
        vendors = {
            ---@type AvanteProvider
            ollama = {
                __inherited_from = "openai",
                api_key_name = '',
                endpoint = "127.0.0.1:11434/v1",
                model = "qwen2.5-coder",
            },

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
                max_tokens = 8192,
            },
        },
    },
    build = "make", -- This is optional, recommended tho. Also note that this will block the startup for a bit since we are compiling bindings in Rust.
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        -- "zbirenbaum/copilot.lua", -- for providers='copilot'
        {
            "zbirenbaum/copilot.lua",
            cmd = "Copilot",
            event = "InsertEnter",
            config = function()
                require("copilot").setup({})
            end,
        },
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
