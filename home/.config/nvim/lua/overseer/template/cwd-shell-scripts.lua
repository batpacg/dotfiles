local files = require "overseer.files"

---@type overseer.TemplateFileProvider
return {
    generator = function()
        local cwd = vim.fn.getcwd()

        local scripts = vim.tbl_filter(function(filename)
            return filename:match "%.sh$"
        end, files.list_files(cwd))

        local ret = {}
        for _, filename in ipairs(scripts) do
            table.insert(ret, {
                name = filename,
                builder = function()
                    return {
                        cmd = { vim.fs.joinpath(cwd, filename) },
                    }
                end,
            })
        end

        return ret
    end,
}
