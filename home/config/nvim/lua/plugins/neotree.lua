return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
        require("neo-tree").setup({
            sources = {
                "filesystem", -- Neotree filesystem source
                "buffers",
                "git_status",
                -- "netman.ui.neo-tree",
            },
            source_selector = {
                winbar = true,
                sources = {
                    { source = "filesystem" },
                    { source = "buffers" },
                    { source = "git_status" },
                    -- Any other items you had in your source selector
                    -- Just add the netman source as well
                    -- { source = "remote" },
                },
            },
            window = { width = 25 },
            filesystem = {
                commands = {
                    avante_add_files = function(state)
                        local node = state.tree:get_node()
                        local filepath = node:get_id()
                        local relative_path = require('avante.utils').relative_path(filepath)

                        local sidebar = require('avante').get()

                        local open = sidebar:is_open()
                        -- ensure avante sidebar is open
                        if not open then
                            require('avante.api').ask()
                            sidebar = require('avante').get()
                        end

                        sidebar.file_selector:add_selected_file(relative_path)

                        -- remove neo tree buffer
                        if not open then
                            sidebar.file_selector:remove_selected_file('neo-tree filesystem [1]')
                        end
                    end,
                },
                window = {
                    mappings = {
                        ['oa'] = 'avante_add_files',
                    },
                },
            },
        })
    end,
}
