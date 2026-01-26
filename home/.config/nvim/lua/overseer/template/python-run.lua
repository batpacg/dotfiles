local name = "Python: run"

return {
    name      = name,
    condition = { filetype = { "python" } },
    builder   = function()
        local filename = vim.fn.expand "%"
        return {
            name = name,
            cmd  = "python",
            args = { "-u", "-W", "default", filename },
        }
    end,
}
