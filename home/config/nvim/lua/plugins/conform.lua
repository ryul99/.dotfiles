return {
    "stevearc/conform.nvim",
    event = { "BufWritePre", "BufNewFile" },
    cmd = { "ConformInfo" },
    keys = {
        {
            -- Customize or remove this keymap to your liking
            "<leader>f",
            function()
                require("conform").format({ async = true })
            end,
            mode = "",
            desc = "Format buffer",
        },
    },
    -- This will provide type hinting with LuaLS
    ---@module "conform"
    ---@type conform.setupOpts
    opts = function()
        local mason_reg = require("mason-registry")

        local formatters = {}
        local formatters_by_ft = {}
        local mason_install = require("mason-core.installer.InstallLocation").global()

        -- add diff langue vs filetype
        local lang_map = {
            ["c++"] = "cpp",
            ["c#"] = "cs",
        }

        -- add dif conform vs mason
        local name_map = {
            ["cmakelang"] = "cmake_format",
            ["deno"] = "deno_fmt",
            ["elm-format"] = "elm_format",
            ["gdtoolkit"] = "gdformat",
            ["nixpkgs-fmt"] = "nixpkgs_fmt",
            ["opa"] = "opa_fmt",
            ["php-cs-fixer"] = "php_cs_fixer",
            ["ruff"] = "ruff_format",
            ["sql-formatter"] = "sql_formatter",
            ["xmlformatter"] = "xmlformat",
        }

        for _, pkg in pairs(mason_reg.get_installed_packages()) do
            for _, type in pairs(pkg.spec.categories) do
                -- only act upon a formatter
                if type == "Formatter" then
                    -- if formatter doesn't have a builtin config, create our own from a generic template
                    if not require("conform").get_formatter_config(pkg.spec.name) then
                        -- the key of the entry to this table
                        -- is the name of the bare executable
                        -- the actual value may not be the absolute path
                        -- in some cases
                        local bin = next(pkg.spec.bin or {})
                        local command = bin and mason_install:bin(bin) or pkg.spec.name

                        formatters[pkg.spec.name] = {
                            command = command,
                            args = { "$FILENAME" },
                            stdin = true,
                            require_cwd = false,
                        }
                    end

                    -- finally add the formatter to it's compatible filetype(s)
                    for _, ft in pairs(pkg.spec.languages or {}) do
                        local ftl = string.lower(ft)
                        local ready = mason_reg.get_package(pkg.spec.name):is_installed()
                        if ready then
                            if lang_map[ftl] ~= nil then
                                ftl = lang_map[ftl]
                            end
                            local formatter_name = name_map[pkg.spec.name] or pkg.spec.name
                            if formatters[formatter_name] == nil then
                                formatters[formatter_name] = formatters[pkg.spec.name]
                                formatters[pkg.spec.name] = nil
                            end
                            formatters_by_ft[ftl] = formatters_by_ft[ftl] or {}
                            table.insert(formatters_by_ft[ftl], formatter_name)
                        end
                    end
                end
            end
        end

        return {
            formatters = formatters,
            formatters_by_ft = formatters_by_ft,
            -- Set default options
            default_format_opts = {
                lsp_format = "fallback",
            },
        }
    end,
    init = function()
        -- If you want the formatexpr, here is the place to set it
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
}
