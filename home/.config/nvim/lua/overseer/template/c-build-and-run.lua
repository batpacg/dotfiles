local name = "C: build and run"

return {
    name = name,
    condition = { filetype = { "c", "cpp" } },
    builder = function()
        local source = vim.fn.expand "%"
        local target = vim.fn.expand "%:r"
        return {
            name = name,
            cmd = "gcc -Wall -pedantic -std=c99 -o '"
                .. target
                .. "' '"
                .. source
                .. "' "
                .. "&& "
                .. "./"
                .. target,
        }
    end,
}
