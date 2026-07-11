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
      { out, "WarningMsg" },
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
    require "config.heirline"
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
    yazi_floating_window_border = "single",
    floating_window_scaling_factor = 0.85,
    keymaps = { change_working_directory = "<C-.>" },
    highlight_groups = {
      hovered_buffer = {},
      hovered_buffer_in_same_directory = {},
    },
  },
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
        require("fzf-lua").files { cwd = "~/Projects/dotfiles/home" }
      end,
    },
    {
      "sl",
      function()
        require("fzf-lua").files { cwd = "~/.local/share/nvim" }
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
    require "config.lsp"
  end,
}

add {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  ft = { "markdown", "text", "typst", "latex", "asciidoc", "lsp_markdown" },
  opts = { dir_path = "assets/attachments" },
  keys = {
    {
      "<LocalLeader>p",
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
