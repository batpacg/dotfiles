vim.fn.execute "CsvViewEnable"

vim.keymap.set(
    "n",
    "<LocalLeader>s",
    "<CMD>CsvViewToggle<CR>",
    { desc = "Toggle CSV view", buffer = true }
)
