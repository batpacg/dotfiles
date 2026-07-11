--
-- ~/.config/nvim/lua/heirline-config.lua
--
-- Refs:
-- https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md
--

local heirline = require "heirline"
local conditions = require "heirline.conditions"
local colors = require "colors"

local bg = colors.gruvbox.light3
local fg = colors.gruvbox.dark0

-- Components ==================================================================

-- Info. -----------------------------------------------------------------------

local MacroRec = {
  condition = function()
    return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
  end,
  provider = function()
    return "[rec|" .. vim.fn.reg_recording() .. "]"
  end,
  update = {
    "RecordingEnter",
    "RecordingLeave",
  },
}

local SearchCount = {
  condition = function()
    return vim.v.hlsearch ~= 0 and vim.o.cmdheight == 0
  end,
  init = function(self)
    local ok, search = pcall(vim.fn.searchcount)
    if ok and search.total then
      self.search = search
    end
  end,
  provider = function(self)
    local search = self.search
    return string.format(
      "[search|%d/%d]",
      search.current,
      math.min(search.total, search.maxcount)
    )
  end,
}

-- Cursor ----------------------------------------------------------------------

local CursorPosition = {
  provider = "[cpos|L%l:C%c]",
}

-- Current Working Directory ---------------------------------------------------

local CwdComponent = {
  init = function(self)
    self.cwd = vim.fn.getcwd()
    self.cwd = self.cwd:gsub(vim.fn.getenv "HOME", "~")

    self.dirs = vim.split(self.cwd, "/")
    self.dirs_max = 3
    if #self.dirs >= 7 then
      self.cwd = self.dirs[1]
          .. "/.../"
          .. table.concat(
            self.dirs,
            "/",
            #self.dirs - self.dirs_max + 1,
            #self.dirs
          )
    end
  end,
  provider = function(self)
    return "[cwd|" .. self.cwd .. "]"
  end,
}

-- Buffer File Name ------------------------------------------------------------

local BufferName = {
  init = function(self)
    local cwd = vim.fn.getcwd()
    local filename = vim.api.nvim_buf_get_name(0)
    if string.sub(filename, 1, 4) == "term" then
      self.filename = "term"
      return
    end
    local maybe_cwd = filename:sub(1, #cwd)
    if maybe_cwd == cwd then
      self.filename = filename:sub(#cwd + 2, #filename)
    else
      self.filename = filename:gsub(vim.fn.getenv "HOME", "~")
    end
  end,

  provider = function(self)
    if self.filename == "" then
      return "No Name"
    else
      return self.filename
    end
  end,
}

local BufferStatus = {
  init = function(self)
    self.modified = vim.bo.modified
    self.readonly = vim.bo.readonly
  end,
  provider = function(self)
    if self.readonly then
      return "R"
    elseif self.modified then
      return "+"
    end

    return "-"
  end,
}

local CurrentBuffer = {
  { provider = "[" },
  { provider = "cbuf|" },
  BufferName,
  { provider = ":" },
  BufferStatus,
  { provider = "]" },
}

-- Git -------------------------------------------------------------------------

local GitBranch = {
  condition = conditions.is_git_repo,

  init = function(self)
    self.statusdict = vim.b.gitsigns_status_dict
    self.has_changes = self.statusdict ~= 0 or self.statusdict.removed
  end,

  provider = function(self)
    return "[git|"
        .. self.statusdict.head
        .. ":"
        .. "A"
        .. (self.statusdict.added or 0)
        .. ":"
        .. "R"
        .. (self.statusdict.removed or 0)
        .. ":"
        .. "C"
        .. (self.statusdict.changed or 0)
        .. "]"
  end,
}

-- Setup =======================================================================

heirline.setup {
  ---@diagnostic disable-next-line: missing-fields
  statusline = {
    hl = { bg = bg, fg = fg, bold = true },
    { provider = " " },
    CursorPosition,
    MacroRec,
    SearchCount,

    { provider = "%=" },
    GitBranch,
    CwdComponent,
    { provider = " " },
  },

  ---@diagnostic disable-next-line: missing-fields
  winbar = {
    hl = { bg = bg, fg = fg, bold = true },
    { provider = " " },
    CurrentBuffer,
    { provider = "%=" },
  },

  opts = {
    disable_winbar_cb = function(args)
      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
        filetype = {
          "^git.*",
          "fugitive",
          "Trouble",
          "dashboard",
          "yazi",
          "fzf",
        },
      }, args.buf)
    end,
  },
}
