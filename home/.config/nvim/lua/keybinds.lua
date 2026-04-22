--
-- ~/.config/nvim/lua/keybinds.lua
--

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.opt.timeoutlen = 2000
vim.opt.ttimeoutlen = 100

-- QoL =========================================================================

vim.keymap.set({ "n" }, "<Leader>q", ":quitall!<CR>")
vim.keymap.set({ "n", "v", "i" }, "<Esc>", "<CMD>noh<CR><Esc>")
vim.keymap.set({ "t" }, "<Esc>", "<C-\\><C-n>")
vim.keymap.set({ "n", "x" }, "x", "<Nop>")
vim.keymap.set({ "n", "x" }, "s", "<Nop>")
-- vim.keymap.set({ "n" }, "<Leader>e", ":Ex<CR>")
vim.keymap.set({ "n", "x" }, "<Leader>m", "<CMD>make<CR>")
vim.keymap.set({ "x" }, ">", ">gv")
vim.keymap.set({ "x" }, "<", "<gv")

function toggle_terminal()
  for i, buffer in ipairs(vim.api.nvim_list_bufs()) do
    local buffer_name = vim.api.nvim_buf_get_name(buffer)
    if string.sub(buffer_name, 1, 7) == "term://" then
      -- if not vim.fn.getbufinfo(buffer).windows then
      --   return
      -- end
      vim.api.nvim_open_win(buffer, true, { split = "below" })
      vim.api.nvim_feedkeys("i", "n", false)
      return
    end
  end
  vim.api.nvim_command ":split | terminal"
  vim.api.nvim_feedkeys("i", "n", false)
end

vim.keymap.set({ "n" }, "<C-j>", toggle_terminal)
vim.keymap.set({ "t" }, "<C-j>", "<C-\\><C-n><C-w>q")

vim.keymap.set({ "x" }, "J", ":m '>+1<CR>gv=gv")
vim.keymap.set({ "x" }, "K", ":m '<-2<CR>gv=gv")

-- Automatically center the screen when possible.
vim.keymap.set({ "n" }, "n", "nzz")
vim.keymap.set({ "n" }, "N", "Nzz")

-- Marks =======================================================================

vim.keymap.set({ "n" }, "m", "`")
vim.keymap.set({ "n" }, "M", "m")

-- Macros ======================================================================

vim.keymap.set({ "n" }, "q", "@")
vim.keymap.set({ "n" }, "<C-q>", "q")

-- Windows =====================================================================

vim.keymap.set({ "n" }, "<Leader>w", "")

vim.keymap.set({ "n" }, "<Leader>wd", "<C-w>q")
vim.keymap.set({ "n" }, "<Leader>wq", "<C-w>q")

vim.keymap.set({ "n" }, "<Leader>wo", "<C-w>o")

vim.keymap.set({ "n" }, "<Leader>ws", "<C-w>s")
vim.keymap.set({ "n" }, "<Leader>wv", "<C-w>v")
vim.keymap.set({ "n" }, "<Leader>ww", "<C-w>s")
vim.keymap.set({ "n" }, "<Leader>we", "<C-w>v")

-- Move window focus.
vim.keymap.set({ "n" }, "<Leader>wh", "<C-w>h")
vim.keymap.set({ "n" }, "<Leader>wj", "<C-w>j")
vim.keymap.set({ "n" }, "<Leader>wk", "<C-w>k")
vim.keymap.set({ "n" }, "<Leader>wl", "<C-w>l")

-- Move windows.
vim.keymap.set({ "n" }, "<Leader>wH", "<C-w>H")
vim.keymap.set({ "n" }, "<Leader>wJ", "<C-w>J")
vim.keymap.set({ "n" }, "<Leader>wK", "<C-w>K")
vim.keymap.set({ "n" }, "<Leader>wL", "<C-w>L")

-- Resize windows.
vim.keymap.set({ "n" }, "<Leader>w<", "<C-w><<Leader>w", { remap = true })
vim.keymap.set({ "n" }, "<Leader>w+", "<C-w>+<Leader>w", { remap = true })
vim.keymap.set({ "n" }, "<Leader>w-", "<C-w>-<Leader>w", { remap = true })
vim.keymap.set({ "n" }, "<Leader>w>", "<C-w>><Leader>w", { remap = true })

-- Buffers =====================================================================

local smart_bd = function(args)
  -- Get window and buffer info
  local winids = vim.api.nvim_list_wins()
  local listed_bufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_get_option_value("buflisted", { buf = buf }) then
      table.insert(listed_bufs, buf)
    end
  end
  local cbuf = vim.api.nvim_get_current_buf()
  local ft =
    vim.api.nvim_get_option_value("filetype", { scope = "local", buf = cbuf })

  -- Decide close command
  local close_cmd = args.force and "bd!" or "bd"

  -- Close buffer
  if #winids == 1 or ft == "help" then
    vim.cmd(close_cmd)
  elseif #winids > 1 then
    for _, winid in ipairs(winids) do
      if vim.api.nvim_win_get_buf(winid) == cbuf then
        vim.api.nvim_win_call(winid, function()
          vim.cmd "bn"
        end)
      end
    end
    vim.cmd(close_cmd .. " #")
  end
end

vim.keymap.set({ "n" }, "<Leader><Leader>", ":b#<CR>")
vim.keymap.set({ "n" }, "<Leader>d", function()
  smart_bd { force = true }
end)
vim.keymap.set({ "n" }, "<Leader>s", ":silent w<CR>", { silent = true })
vim.keymap.set({ "n" }, "<Leader><C-s>", ":write ++p<CR>")
vim.keymap.set({ "n" }, "<S-h>", ":bp<CR>")
vim.keymap.set({ "n" }, "<S-l>", ":bn<CR>")

-- Surround Selection ==========================================================

vim.keymap.set({ "v", "x" }, "s<", "c" .. "<>" .. "<Esc>P")
vim.keymap.set({ "v", "x" }, "s>", "c" .. "<>" .. "<Esc>P")

vim.keymap.set({ "v", "x" }, "s{", "c" .. "{}" .. "<Esc>P")
vim.keymap.set({ "v", "x" }, "s}", "c" .. "{}" .. "<Esc>P")

vim.keymap.set({ "v", "x" }, "s[", "c" .. "[]" .. "<Esc>P")
vim.keymap.set({ "v", "x" }, "s]", "c" .. "[]" .. "<Esc>P")

vim.keymap.set({ "v", "x" }, "s(", "c" .. "()" .. "<Esc>P")
vim.keymap.set({ "v", "x" }, "s)", "c" .. "()" .. "<Esc>P")

vim.keymap.set({ "v", "x" }, "s'", "c" .. "''" .. "<Esc>P")

vim.keymap.set({ "v", "x" }, 's"', "c" .. '""' .. "<Esc>P")

vim.keymap.set({ "v", "x" }, "s ", "c" .. "  " .. "<Esc>P")

vim.keymap.set({ "v", "x" }, "s*", "c" .. "**" .. "<Esc>P")

vim.keymap.set({ "v", "x" }, "s_", "c" .. "__" .. "<Esc>P")

-- Toggle ======================================================================

local toggle_option = function(opt)
  local new_opt = vim.wo[opt] == true and ("no" .. opt) or opt
  local cmd = "setlocal " .. new_opt
  vim.cmd(cmd)
end

vim.keymap.set({ "n" }, "<Leader>t", "")
vim.keymap.set({ "n" }, "<Leader>tw", function()
  toggle_option "wrap"
end)
vim.keymap.set({ "n" }, "<Leader>tl", function()
  toggle_option "list"
end)
vim.keymap.set({ "n" }, "<Leader>tn", function()
  toggle_option "number"
end)

vim.keymap.set({ "n" }, "<Leader>ts", function()
  -- scl
  if vim.o.signcolumn == "yes" then
    vim.cmd "setlocal signcolumn=no"
  else
    vim.cmd "setlocal signcolumn=yes"
  end
end)

-- G Commands ==================================================================

vim.keymap.set({ "n" }, "gs", 'viwy:%s/\\<<C-r>"\\>//g<Left><Left>')
vim.keymap.set({ "v", "x" }, "gs", 'y:%s/\\<<C-r>"\\>//g<Left><Left>')
vim.keymap.set({ "n" }, "ga", "ggVG")
vim.keymap.set({ "n" }, "g.", "ga")
