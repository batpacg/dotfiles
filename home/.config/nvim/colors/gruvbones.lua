-- Refs:
-- https://github.com/zenbones-theme/zenbones.nvim/blob/main/doc/zenbones.md#create-your-own-colorscheme

local colors_name = "gruvbones"
vim.g.colors_name = colors_name

local lush = require "lush"
local hsluv = lush.hsluv -- Human-friendly hsl
local util = require "zenbones.util"

local bg = vim.o.background

-- Define a palette. Use `palette_extend` to fill unspecified colors.
-- Based on 'https://github.com/gruvbox-community/gruvbox#palette'.
local palette
if bg == "light" then
  palette = util.palette_extend({
    -- stylua: ignore start
    bg      = hsluv "#fbf1c7",
    fg      = hsluv "#3c3836",
    rose    = hsluv "#9d0006",
    leaf    = hsluv "#79740e",
    wood    = hsluv "#b57614",
    water   = hsluv "#076678",
    blossom = hsluv "#8f3f71",
    sky     = hsluv "#427b58",
    -- stylua: ignore end
  }, bg)
elseif bg == "dark" then
  palette = util.palette_extend({
    -- stylua: ignore start
    bg      = hsluv "#282828",
    fg      = hsluv "#ebdbb2",
    rose    = hsluv "#fb4934",
    leaf    = hsluv "#b8bb26",
    wood    = hsluv "#fabd2f",
    water   = hsluv "#83a598",
    blossom = hsluv "#d3869b",
    sky     = hsluv "#83c07c",
    -- stylua: ignore end
  }, bg)
end

-- Terminal ANSI colors.
if bg == "light" then
  vim.g.terminal_color_0 = "#3c3836"
  vim.g.terminal_color_1 = "#9d0006"
  vim.g.terminal_color_2 = "#79740e"
  vim.g.terminal_color_3 = "#b57614"
  vim.g.terminal_color_4 = "#076678"
  vim.g.terminal_color_5 = "#8f3f71"
  vim.g.terminal_color_6 = "#427b58"
  vim.g.terminal_color_7 = "#a89984"

  vim.g.terminal_color_8 = "#928374"
  vim.g.terminal_color_9 = "#cc241d"
  vim.g.terminal_color_10 = "#98971a"
  vim.g.terminal_color_11 = "#d79921"
  vim.g.terminal_color_12 = "#458588"
  vim.g.terminal_color_13 = "#b16286"
  vim.g.terminal_color_14 = "#689d6a"
  vim.g.terminal_color_15 = "#282828"
else
  vim.g.terminal_color_0 = "#282828"
  vim.g.terminal_color_1 = "#cc241d"
  vim.g.terminal_color_2 = "#98971a"
  vim.g.terminal_color_3 = "#d79921"
  vim.g.terminal_color_4 = "#458588"
  vim.g.terminal_color_5 = "#b16286"
  vim.g.terminal_color_6 = "#689d6a"
  vim.g.terminal_color_7 = "#a89984"

  vim.g.terminal_color_8 = "#928374"
  vim.g.terminal_color_9 = "#fb4934"
  vim.g.terminal_color_10 = "#b8bb26"
  vim.g.terminal_color_11 = "#fabd2f"
  vim.g.terminal_color_12 = "#83a598"
  vim.g.terminal_color_13 = "#d3869b"
  vim.g.terminal_color_14 = "#8ec07c"
  vim.g.terminal_color_15 = "#ebdbb2"
end

-- Generate the lush specs using the generator util.
local generator = require "zenbones.specs"
local base_specs =
  generator.generate(palette, bg, generator.get_global_config(colors_name, bg))

-- Optionally extend specs using Lush.
local specs = lush.extends({ base_specs }).with(function()
  return {
    ---@diagnostic disable: undefined-global
    NonText { base_specs.NonText, fg = palette.bg.lighten(5).hex },
    ColorColumn { bg = palette.bg.lighten(5).hex },
    CursorLine { bg = palette.bg.lighten(5).hex },
    Pmenu { link = "Normal" },
    NormalFloat { link = "Normal" },
    ---@diagnostic enable: undefined-global
  }
end)

-- Pass the specs to lush to apply.
lush(specs)
