--
-- Neovim-Tmux Integration
--

local M = {}

M.move_window_focus = function(dir)
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

M.popup_pane = function(cmd)
  local final_cmd = {
    "tmux",
    "display-popup",
    "-E",
    "-w",
    "85%",
    "-h",
    "85%",
    ("%s"):format(cmd),
  }
  vim.fn.jobstart(table.concat(final_cmd, " "))
end

return M
