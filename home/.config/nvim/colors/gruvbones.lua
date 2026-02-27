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

-- Generate the lush specs using the generator util.
local generator = require "zenbones.specs"
local base_specs = generator.generate(
    palette,
    bg,
    generator.get_global_config(colors_name, bg)
)

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

-- Optionally set term colors.
require("zenbones.term").apply_colors(palette)
