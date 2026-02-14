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
        local conditions = require "heirline.conditions"
        local utils = require "heirline.utils"

        local PositionComponent = {
            provider = "(" .. "%3l,%2c" .. ")",
            { -- Separator
                provider = function()
                    return " "
                end,
            },
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
            provider = function(self)
                return self.cwd
            end,
            { -- Separator
                provider = function()
                    return " "
                end,
            },
        }

        local FileNameComponent = {
            init = function(self)
                self.filename = vim.api.nvim_buf_get_name(0)
            end,
            provider = function(self)
                local filename = vim.fn.fnamemodify(self.filename, ":t")
                if filename == "" then
                    return "[No Name]"
                end
                return filename
            end,
            { -- Separator
                provider = function()
                    return " "
                end,
            },
        }

        local GitComponent = {
            condition = conditions.is_git_repo,

            init = function(self)
                self.statusdict = vim.b.gitsigns_status_dict
                self.has_changes = self.statusdict ~= 0
                    or self.statusdict.removed
            end,

            { -- Git Repo Name
                provider = function(self)
                    return "> " .. self.statusdict.head
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
                        .. ",-"
                        .. (self.statusdict.removed or 0)
                        .. ",~"
                        .. (self.statusdict.changed or 0)
                        .. ")"
                end,
            },
            { -- Separator
                provider = function()
                    return " "
                end,
            },
        }

        require("heirline").setup {
            statusline = {
                { provider = " " },
                FileNameComponent,
                { provider = "@ " },
                CwdComponent,
                GitComponent,
                { provider = "%=" },
                PositionComponent,
            },
        }
    end,
}

add {
    "knubie/vim-kitty-navigator",
    build = "cp ./*.py ~/.config/kitty/",
    init = function()
        vim.g.kitty_navigator_no_mappings = 1
    end,
    keys = {
        { "<M-h>", ":KittyNavigateLeft<CR>",  silent = true },
        { "<M-j>", ":KittyNavigateDown<CR>",  silent = true },
        { "<M-k>", ":KittyNavigateUp<CR>",    silent = true },
        { "<M-l>", ":KittyNavigateRight<CR>", silent = true },
    },
}

add {
    "brenton-leighton/multiple-cursors.nvim",
    keys = {
        { "<C-n>", ":MultipleCursorsAddJumpNextMatch<CR>zz" },
    },
    opts = {},
}

add {
    "mikavilpas/yazi.nvim",
    dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
    keys = {
        { "<Leader>e", "<cmd>Yazi<CR>" },
    },
    opts = {
        yazi_floating_window_border = "single",
        floating_window_scaling_factor = 0.8,
        keymaps = { change_working_directory = "g." },
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
                require("fzf-lua").files { cwd = "~/.config/nvim" }
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
            if vim.tbl_isempty(tasks) then
                vim.cmd "OverseerRun"
            else
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
    "https://github.com/LunarVim/bigfile.nvim",
    opts = {
        filesize = 2,
        features = {
            "indent_blankline",
            "illuminate",
            "lsp",
            "treesitter",
            "syntax",
            "matchparen",
            "vimopts",
            "filetype",
        },
    },
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
