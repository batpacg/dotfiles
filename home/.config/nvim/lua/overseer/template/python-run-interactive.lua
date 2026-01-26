local name = "Python: run interactively"

return {
    name      = name,
    condition = { filetype = { "python" } },
    builder   = function()
        local filename = vim.fn.expand "%"
        return {
            name = name,
            cmd  = "python",
            args = { "-i", "-u", "-W", "default", filename },
        }
    end,
}
