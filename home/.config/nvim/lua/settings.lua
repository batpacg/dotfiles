--
-- ~/.config/nvim/lua/settings.lua
--

-- stylua: ignore start

-- Basic -----------------------------------------------------------------------

vim.opt.number         = false
vim.opt.relativenumber = false
vim.opt.cursorline     = true
vim.opt.wrap           = false
vim.opt.scrolloff      = 16
vim.opt.sidescrolloff  = 8
vim.opt.modeline       = true

-- Identation ------------------------------------------------------------------

vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 4
vim.opt.softtabstop    = 4
vim.opt.expandtab      = true
vim.opt.smartindent    = true
vim.opt.autoindent     = true

-- Search ----------------------------------------------------------------------

vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.hlsearch       = true
vim.opt.incsearch      = true
vim.opt.grepprg        = "rg --vimgrep -uu --follow --hidden"

-- Appearance ------------------------------------------------------------------

vim.opt.termguicolors  = true
vim.opt.signcolumn     = "yes"
vim.opt.colorcolumn    = "81"
vim.opt.showmatch      = true
vim.opt.matchtime      = 2
vim.opt.cmdheight      = 1
vim.opt.laststatus     = 3
vim.opt.completeopt    = "menuone,noinsert,noselect"
vim.opt.showmode       = false
vim.opt.pumheight      = 10
vim.opt.pumblend       = 10
vim.opt.winblend       = 0
vim.opt.lazyredraw     = true
vim.opt.synmaxcol      = 300
vim.opt.conceallevel   = 2
vim.opt.concealcursor:remove("n")

-- Whitespaces -----------------------------------------------------------------

vim.opt.list         = true
vim.opt.listchars    = { space = "·", tab = ">-", eol = "¬" }

-- Leader Keys -----------------------------------------------------------------

vim.g.mapleader      = " "
vim.g.maplocalleader = ","
vim.opt.timeoutlen   = 500
vim.opt.ttimeoutlen  = 0

-- File Handling ---------------------------------------------------------------

vim.opt.backup       = false
vim.opt.writebackup  = false
vim.opt.swapfile     = false
vim.opt.autowrite    = false
vim.opt.undofile     = true
vim.opt.updatetime   = 50
vim.opt.autoread     = true

-- Behavior --------------------------------------------------------------------

vim.opt.hidden       = true
vim.opt.errorbells   = false
vim.opt.backspace    = "indent,eol,start"
vim.opt.autochdir    = false
vim.opt.virtualedit  = "block"
-- vim.opt.selection    = "exclusive"
vim.opt.mouse        = "a"
vim.opt.modifiable   = true
vim.opt.encoding     = "UTF-8"
vim.opt.clipboard:append("unnamedplus")
---@diagnostic disable-next-line: undefined-field
vim.opt.iskeyword:append("-")
vim.opt.path:append("**")

-- Splits ----------------------------------------------------------------------

vim.opt.splitbelow = true
vim.opt.splitright = true

-- Folds -----------------------------------------------------------------------
-- https://www.reddit.com/r/neovim/comments/1d3iwcz/custom_folds_without_any_plugins/

vim.wo.foldmethod  = "marker"
-- vim.wo.foldexpr  = "v:lua.vim.treesitter.foldexpr()"
-- vim.opt.foldmarker   = "{{{,}}}"
-- vim.opt.foldminlines = 1
-- vim.opt.foldlevel    = 99
-- vim.opt.foldcolumn   = "auto:1"
vim.opt.fillchars:append("fold:-")

-- stylua: ignore end
