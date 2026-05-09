--
-- ~/.config/nvim/init.lua
--

require "settings"
require "keybinds"
require "autocommands"
require "plugins"

require "kitty"

if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_vfx_mode = ""
end
