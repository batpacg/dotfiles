-- Neovim-Kitty Integration
-- https://sw.kovidgoyal.net/kitty/mapping/#conditional-mappings-depending-on-the-state-of-the-focused-window

vim.api.nvim_create_autocmd({ "VimEnter", "VimResume", "UIEnter" }, {
  group = vim.api.nvim_create_augroup("KittySetVarVimEnter", { clear = true }),
  callback = function()
    if vim.api.nvim_ui_send then
      vim.api.nvim_ui_send "\x1b]1337;SetUserVar=in_editor=MQ==\007"
    else
      io.stdout:write "\x1b]1337;SetUserVar=in_editor=MQ==\007"
    end
  end,
})

vim.api.nvim_create_autocmd({ "VimLeave", "VimSuspend" }, {
  group = vim.api.nvim_create_augroup(
    "KittyUnsetVarVimLeave",
    { clear = true }
  ),
  callback = function()
    if vim.api.nvim_ui_send then
      vim.api.nvim_ui_send "\x1b]1337;SetUserVar=in_editor\007"
    else
      io.stdout:write "\x1b]1337;SetUserVar=in_editor\007"
    end
  end,
})

local SmartNavigate = function(dir)
  -- https://sw.kovidgoyal.net/kitty/remote-control/#id1
  local neighbormap = {
    h = "left",
    j = "bottom",
    k = "top",
    l = "right",
  }
  local winnr = vim.api.nvim_win_get_number(0)
  vim.cmd("wincmd " .. dir)
  local final_winnr = vim.api.nvim_win_get_number(0)
  if winnr == final_winnr then
    local cmd = {
      "kitten",
      "@",
      "focus-window",
      "-m",
      "neighbor:" .. neighbormap[dir],
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

-- add {
--   "knubie/vim-kitty-navigator",
--   init = function()
--     vim.g.kitty_navigator_no_mappings = 1
--   end,
--   keys = {
--     { "<M-h>", ":KittyNavigateLeft<CR>",  silent = true },
--     { "<M-j>", ":KittyNavigateDown<CR>",  silent = true },
--     { "<M-k>", ":KittyNavigateUp<CR>",    silent = true },
--     { "<M-l>", ":KittyNavigateRight<CR>", silent = true },
--   },
-- }
