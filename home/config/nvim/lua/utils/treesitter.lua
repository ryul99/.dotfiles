local M = {}
local has_cli

function M.has_cli()
    if has_cli ~= nil then
        return has_cli
    end

    if vim.fn.executable("tree-sitter") == 0 then
        has_cli = false
        return has_cli
    end

    vim.fn.system({ "tree-sitter", "--version" })
    has_cli = vim.v.shell_error == 0
    return has_cli
end

function M.manager_spec()
    return {
        "romus204/tree-sitter-manager.nvim",
        cond = M.has_cli,
    }
end

return M
