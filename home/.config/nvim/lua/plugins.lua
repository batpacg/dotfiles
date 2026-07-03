--
-- ~/.config/nvim/lua/plugins.lua
--

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.keymap.set("n", "<Leader>ip", ":Lazy<CR>")

local plugin_list = {}

local add = function(args)
  table.insert(plugin_list, args)
end

add { "nvim-mini/mini.splitjoin", version = "*", opts = {} }

add {
  "zenbones-theme/zenbones.nvim",
  dependencies = "rktjmp/lush.nvim",
  lazy = false,
  priority = 1000,
  init = function()
    -- Depends on '~/.config/nvim/colors/gruvbones.lua'.
    vim.cmd.colorscheme "gruvbones"
  end,
}

add {
  "rebelot/heirline.nvim",
  event = "UIEnter",
  config = function()
    -- https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md
    local heirline = require "heirline"
    local conditions = require "heirline.conditions"
    -- local utils = require "heirline.utils"

    local PositionComponent = {
      provider = "%l:%c",
    }

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
      -- condition = function()
      --   return not vim.bo.readonly
      -- end,
      provider = function(self)
        return self.cwd
      end,
    }

    local FileNameComponent = {
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
          return "[No Name]"
        end
        return self.filename
      end,
    }

    local FileStatusComponent = {
      init = function(self)
        self.modified = vim.bo.modified
        self.readonly = vim.bo.readonly
      end,
      provider = function(self)
        if self.readonly then
          return "[R]"
        elseif self.modified then
          return "[+]"
        end

        return "[-]"
      end,
    }

    local GitComponent = {
      condition = conditions.is_git_repo,

      init = function(self)
        self.statusdict = vim.b.gitsigns_status_dict
        self.has_changes = self.statusdict ~= 0 or self.statusdict.removed
      end,

      { -- Git Repo Name
        provider = function(self)
          return " " .. self.statusdict.head
        end,
      },

      { -- Git Diff
        condition = function(self)
          return self.has_changes
        end,
        provider = function(self)
          return "("
              .. "+"
              .. (self.statusdict.added or 0)
              .. "-"
              .. (self.statusdict.removed or 0)
              .. "~"
              .. (self.statusdict.changed or 0)
              .. ")"
        end,
      },

      {
        provider = " | ",
      },
    }

    local colors = require "colors"
    local bg = colors.gruvbox.light3
    local fg = colors.gruvbox.dark0
    heirline.setup {
      ---@diagnostic disable-next-line: missing-fields
      statusline = {
        hl = { bg = bg, fg = fg, bold = true },
        { provider = " " },
        PositionComponent,
        { provider = "%=" },
        GitComponent,
        CwdComponent,
        { provider = " " },
      },
      ---@diagnostic disable-next-line: missing-fields
      winbar = {
        hl = { bg = bg, fg = fg, bold = true },
        { provider = " " },
        FileNameComponent,
        { provider = " " },
        FileStatusComponent,
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
  end,
}

add {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    {
      "x",
      mode = { "n", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
    {
      "X",
      mode = { "n", "o" },
      function()
        require("flash").remote()
      end,
      desc = "Remote Flash",
    },
  },
}

add {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = { preset = "helix", win = { border = "single" }, delay = 1000 },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show { global = false }
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}

add {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require "multicursor-nvim"
    mc.setup()

    local set = vim.keymap.set

    -- Add or skip cursor above/below the main cursor.
    set({ "n", "x" }, "<up>", function()
      mc.lineAddCursor(-1)
    end)
    set({ "n", "x" }, "<down>", function()
      mc.lineAddCursor(1)
    end)
    set({ "n", "x" }, "<leader><up>", function()
      mc.lineSkipCursor(-1)
    end)
    set({ "n", "x" }, "<leader><down>", function()
      mc.lineSkipCursor(1)
    end)

    -- Add or skip adding a new cursor by matching word/selection
    set({ "n", "x" }, "<C-n>", function()
      mc.matchAddCursor(1)
    end)
    set({ "n", "x" }, "<C-S-n>", function()
      mc.matchAddCursor(-1)
    end)

    mc.addKeymapLayer(function(layerSet)
      -- Select a different cursor as the main one.
      layerSet({ "n", "x" }, "<left>", mc.prevCursor)
      layerSet({ "n", "x" }, "<right>", mc.nextCursor)

      -- Delete the main cursor.
      layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

      -- Enable and clear cursors using escape.
      layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)

    -- Customize how cursors look.
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { reverse = true })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn" })
    hl(0, "MultiCursorMatchPreview", { link = "Search" })
    hl(0, "MultiCursorDisabledCursor", { reverse = true })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
  end,
}

add {
  "mikavilpas/yazi.nvim",
  dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
  keys = { { mode = { "n", "v" }, "<Leader>e", "<cmd>Yazi<CR>" } },
  opts = {
    yazi_floating_window_border = "none",
    floating_window_scaling_factor = 1.0,
    keymaps = { change_working_directory = "<C-.>" },
    highlight_groups = {
      hovered_buffer = {},
      hovered_buffer_in_same_directory = {},
    },
  },
}

add {
  "Vigemus/iron.nvim",
  keys = {
    {
      mode = { "n" },
      "<Leader>is",
      function()
        require("iron.core").send_file()
      end,
    },
    {
      mode = { "v" },
      "<Leader>is",
      function()
        require("iron.core").visual_send()
      end,
    },
    {
      mode = { "n" },
      "<Leader>ii",
      ":IronFocus<CR>",
    },
    {
      mode = { "n" },
      "<Leader>ir",
      ":IronRestart<CR>",
    },
    {
      mode = { "n" },
      "<Leader>il",
      function()
        require("iron.core").send_line()
      end,
    },
    {
      mode = { "n" },
      "<Leader>ic",
      function()
        require("iron.core").send(nil, string.char(12))
      end,
    },
    {
      mode = { "n" },
      "<Leader>iC",
      function()
        require("iron.core").send(nil, string.char(03))
      end,
    },
    {
      mode = { "n" },
      "<Leader>i<CR>",
      function()
        require("iron.core").send(nil, string.char(13))
      end,
    },
  },
  config = function()
    local view = require "iron.view"
    require("iron").setup {
      config = {
        repl_open_cmd = view.split "30%",
        repl_definition = {
          python = {
            command = { "ipython", "--no-autoindent" },
            format = require("iron.fts.common").bracketed_paste,
            block_dividers = { "#%%", "# %%" },
          },
        },
      },
    }
  end,
}

-- https://github.com/amitds1997/remote-nvim.nvim
-- add {
--     "uhs-robert/sshfs.nvim",
--     opts = {},
-- }

add {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- Because of vim.ui.select wrapper, fzf-lua needs to run on startup.
  lazy = false,
  keys = {
    { "sf", ":FzfLua files<CR>" },
    { "sw", ":FzfLua live_grep<CR>" },
    { "s/", ":FzfLua blines<CR>" },
    { "sh", ":FzfLua help_tags<CR>" },
    { "sa", ":FzfLua builtin<CR>" },
    { "sc", ":FzfLua zoxide<CR>" },
    { "so", ":FzfLua nvim_options<CR>" },
    { "sj", ":FzfLua buffers<CR>" },
    {
      "s.",
      function()
        -- require("fzf-lua").files { cwd = "~/.config" }
        require("fzf-lua").files { cwd = "~/Projects/dotfiles/home" }
      end,
    },
  },
  opts = {
    winopts = {
      title_pos = "center",
      title_flags = false,
      border = "single",
      backdrop = 100,
      preview = {
        title = false,
        border = "single",
        layout = "flex",
        horizontal = "right:50%",
        vertical = "down:50%",
      },
    },
    keymap = {
      fzf = {
        ["ctrl-l"] = "accept",
        ["ctrl-h"] = "abort",
        -- select all and then send them to the quickfix list
        ["ctrl-q"] = "select-all+accept",
      },
    },
    files = {
      cwd_prompt = false,
      follow = true,
      hidden = true,
      fd_opts = [[--color=never --hidden --type f --type l --exclude .git --exclude '*.pdf' --exclude '*.png' --exclude '*.jpg']],
    },
    buffers = {
      ignore_current_buffer = false,
    },
    grep = {
      follow = true,
      hidden = true,
    },
  },
  config = function(_, opts)
    local fzf = require "fzf-lua"
    fzf.register_ui_select()
    fzf.setup(opts)
  end,
}

add {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    local treesitter = require "nvim-treesitter"

    treesitter.install {
      "vim",
      "vimdoc",
      "query",
      "regex",
      "lua",
      "luadoc",
      "luap",
      "bash",
      "markdown",
      "markdown_inline",
      "typst",
      "latex", -- Requires tree-sitter-cli installed.
      "html",
      "css",
      "javascript",
      "typescript",
      "tsx",
      "c",
      "cpp",
      "rust",
      "go",
      "python",
      "toml",
      "yaml",
      "ini",
      "json",
    }

    -- Enable treesitter's syntax highlighting and indent for all filetypes
    -- with installed grammars.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "*" },
      callback = function(args)
        local ft = args.match
        local installed_parsers = treesitter.get_installed()
        table.insert(installed_parsers, "sh")
        if vim.tbl_contains(installed_parsers, ft) then
          vim.treesitter.start()
          -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}

add {
  "lewis6991/gitsigns.nvim",
  opts = {},
}

add {
  "stevearc/overseer.nvim",
  cmd = { "OverseerRun" },
  keys = {
    { "<Leader>r",     ":OverseerReRun<CR>" },
    { "<CR>",          ":OverseerReRun<CR>" },
    { "<Leader><S-r>", ":OverseerToggle!<CR>" },
    { "<Leader><C-r>", ":OverseerTaskAction<CR>" },
  },
  opts = {
    actions = {
      ["open tab"] = false,
      ["open float"] = false,
      ["open hsplit"] = false,
      ["open vsplit"] = false,
      ["open output in quickfix"] = false,
    },
    component_aliases = {
      default = {
        "open_output",
        "on_exit_set_status",
        "on_complete_notify",
        {
          "on_complete_dispose",
          require_view = { "SUCCESS", "FAILURE" },
        },
      },
    },
    task_list = {
      direction = "bottom",
      min_width = 1,
      max_width = 15,
      render = function(task)
        return require("overseer.render").format_compact(task)
      end,
      keymaps = {
        ["<C-l>"] = false,
        ["<C-h>"] = false,
        ["<C-j>"] = false,
        ["<C-k>"] = false,
      },
    },
    form = { border = "single" },
    confirm = { border = "single" },
    task_win = { border = "single" },
    help_win = { border = "single" },
  },
  config = function(_, opts)
    local overseer = require "overseer"

    overseer.setup(opts)

    -- New command to run last task or to start a new task if there is no
    -- task to be restarted.
    vim.api.nvim_create_user_command("OverseerReRun", function()
      local tasks = overseer.list_tasks()
      -- local buf = vim.api.nvim_win_get_buf(0)
      if vim.tbl_isempty(tasks) then
        vim.cmd "OverseerRun"
      else
        vim.fn.execute "write"
        overseer.run_action(tasks[1], "restart")
      end
    end, {})
  end,
}

add {
  "hat0uma/csvview.nvim",
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
  opts = {},
}

add {
  "brenoprata10/nvim-highlight-colors",
  ft = {
    "lua",
    "html",
    "css",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  opts = { render = "background" },
}

add {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  event = "VeryLazy",
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = { enable_autosnippets = true },
  config = function(_, opts)
    local ls = require "luasnip"
    ls.setup(opts)
    vim.tbl_map(function(element)
      require("luasnip.loaders.from_" .. element).lazy_load()
    end, {
      "vscode",
      "lua",
      -- "snipmate",
    })
    require "luasnip.snippets"
  end,
}

add {
  "saghen/blink.cmp",
  event = "InsertEnter",
  dependencies = {
    "L3MON4D3/LuaSnip",
    "folke/lazydev.nvim",
  },
  version = "1.*",
  opts = {
    snippets = { preset = "luasnip" },
    enabled = function()
      return vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
    end,
    completion = {
      menu = {
        auto_show = true,
        border = "single",
      },
      list = {
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = { border = "single" },
      },
    },
    signature = {
      enabled = true,
      window = { border = "single" },
    },
    keymap = {
      preset = "none",
      -- Main
      ["<C-.>"] = { "show", "hide", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-l>"] = { "select_and_accept", "fallback" },
      -- Docs
      ["<C-h>"] = {
        "hide_documentation",
        "show_documentation",
        "fallback",
      },
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      -- Snippets
      ["<C-n>"] = { "snippet_forward", "fallback" },
      ["<C-p>"] = { "snippet_backward", "fallback" },
    },
    sources = {
      default = { "lazydev", "lsp", "path", "snippets", "buffer" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
      },
    },
    cmdline = {
      keymap = { preset = "inherit" },
      completion = { menu = { auto_show = true } },
    },
  },
}

add {
  "williamboman/mason.nvim",
  cmd = "Mason",
  keys = { { "<Leader>im", ":Mason<CR>" } },
  opts = {},
}

add {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      -- See the configuration section for more details
      -- Load luvit types when the `vim.uv` word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}

add {
  "neovim/nvim-lspconfig",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "williamboman/mason.nvim",
    "folke/lazydev.nvim",
    "nvimtools/none-ls.nvim",
  },
  config = function()
    require "lsp"
  end,
}

add {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = { dir_path = "assets/attachments" },
  keys = {
    {
      "<LocalLeaderr>p",
      "<cmd>PasteImage<cr>",
      desc = "Paste image from system clipboard",
    },
  },
}

require("lazy").setup(plugin_list, {
  -- ui = { border = "single" },
  defaults = { lazy = false },
  install = { colorscheme = { "habamax" } },
  performance = {
    rtp = {
      disabled_plugins = {
        -- "netrw",
        -- "netrwPlugin",
        -- "netrwSettings",
        -- "netrwFileHandlers",

        "gzip",
        "zip",
        "zipPlugin",
        "tar",
        "tarPlugin",

        "getscript",
        "getscriptPlugin",

        "vimball",
        "vimballPlugin",

        "2html_plugin",
        "logipat",
        "rrhelper",
        "spellfile_plugin",
        "matchit",
      },
    },
  },
})
