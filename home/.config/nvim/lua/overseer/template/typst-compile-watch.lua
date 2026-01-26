local name = "Typst: watch file"

return {
    name      = name,
    condition = { filetype = { "typst" } },
    builder   = function()
        local filename = vim.fn.expand "%"
        return {
            name = name,
            cmd  = "typst",
            args = { "watch", filename },
        }
    end,
}
