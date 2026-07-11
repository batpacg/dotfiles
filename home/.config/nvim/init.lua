require "config.settings"
require "config.keybinds"
require "config.autocommands"
require "config.plugins"
require "config.kitty"
require "config.tasks"

if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_vfx_mode = ""
end
