local name = "Liveserver in CWD"

return {
    name      = name,
    condition = { filetype = { "html", "css", "javascript", "typescript" } },
    builder   = function()
        return {
            name = name,
            cmd  = "live-server",
            args = { "--index", "--hard", "--port", "8000", "--open" },
        }
    end,
}
