--
-- ~/.config/nvim/lua/autocommands.lua
--

local user_augroup = vim.api.nvim_create_augroup("User", {})

-- Try to move to the last editing position when opening a recent buffer.
vim.api.nvim_create_autocmd("BufReadPost", {
    group = user_augroup,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Auto reload files on change.
vim.api.nvim_create_autocmd("BufEnter", {
    group = user_augroup,
    callback = function()
        vim.cmd "checktime"
    end,
})
