--
-- Neovim-Tmux Integration
--

local SmartNavigate = function(dir)
  local winnr = vim.api.nvim_win_get_number(0)
  vim.cmd("wincmd " .. dir)
  local final_winnr = vim.api.nvim_win_get_number(0)
  if winnr == final_winnr then
    local tmux_key_dir_map = {
      h = "L",
      j = "D",
      k = "U",
      l = "R",
    }
    local cmd = {
      "tmux",
      "select-pane",
      "-" .. tmux_key_dir_map[dir],
    }
    vim.fn.system(cmd)
  end
end

-- stylua: ignore start
vim.keymap.set({ "n" }, "<M-h>", function() SmartNavigate "h" end)
vim.keymap.set({ "n" }, "<M-j>", function() SmartNavigate "j" end)
vim.keymap.set({ "n" }, "<M-k>", function() SmartNavigate "k" end)
vim.keymap.set({ "n" }, "<M-l>", function() SmartNavigate "l" end)
-- stylua: ignore end
