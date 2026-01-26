-- Documentation for LSP configuration:
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

-- local lspconfig = require "lspconfig"
local nonels = require "null-ls"

-- Options =====================================================================

local LspConfig = {}

LspConfig.default = {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
}

LspConfig.default.capabilities.textDocument.completion.completionItem.snippetSupport =
    true

LspConfig.servers = {
    ["lua_ls"] = {},
    ["html"] = {},
    ["cssls"] = {},
    ["emmet_ls"] = {},
    ["clangd"] = {
        cmd = {
            "clangd",
            "--enable-config",
            "--fallback-style=webkit",
        },
    },
    ["pyright"] = {},
    ["ruff"] = {},
    ["bashls"] = {},
    ["ts_ls"] = {},
    ["tombi"] = {},
    ["tinymist"] = {},
}

local NoneLS = {}

NoneLS.formatters = {
    ["prettierd"] = {
        disabled_filetypes = { "html", "markdown" },
        env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand "~/.config/nvim/utils/.prettierrc.json",
        },
    },
    ["stylua"] = {},
    ["shfmt"] = { extra_args = { "-ci", "-sr" } },
}

-- lsp-config setup ============================================================

vim.lsp.config("*", {
    capabilities = LspConfig.default.capabilities,
})

for name, opts in pairs(LspConfig.servers) do
    if opts ~= {} then
        vim.lsp.config(name, opts)
    end
    vim.lsp.enable(name)
end

vim.diagnostic.config { float = { border = "single" } }

-- none-ls setup ===============================================================

local nonels_sources = {}

for name, opts in pairs(NoneLS.formatters) do
    if opts == {} then
        table.insert(nonels_sources, nonels.builtins.formatting[name])
    else
        table.insert(
            nonels_sources,
            nonels.builtins.formatting[name].with(opts)
        )
    end
end

nonels.setup { sources = nonels_sources }

-- Keymaps =====================================================================

vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP Attach",
    callback = function(args)
        -- local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
        -- client.server_capabilities.semanticTokensProvider = nil

        vim.keymap.set(
            { "n" },
            "<LocalLeader>r",
            "<cmd>lua vim.lsp.buf.rename()<CR>",
            { buffer = args.buf }
        )

        vim.keymap.set(
            { "n" },
            "<LocalLeader>a",
            "<cmd>lua vim.lsp.buf.code_action()<CR>",
            { buffer = args.buf }
        )

        vim.keymap.set(
            { "n" },
            "<LocalLeader>l",
            "<cmd>lua vim.diagnostic.open_float()<CR>",
            { buffer = args.buf }
        )

        vim.keymap.set(
            { "n" },
            "<LocalLeader>.",
            "<cmd>lua vim.diagnostic.goto_next()<CR>",
            { buffer = args.buf }
        )

        vim.keymap.set(
            { "n" },
            "<LocalLeader>,",
            "<cmd>lua vim.diagnostic.goto_prev()<CR>",
            { buffer = args.buf }
        )

        vim.keymap.set({ "n" }, "K", function()
            vim.lsp.buf.hover { border = "single" }
        end, { buffer = args.buf })

        vim.keymap.set({ "n" }, "<LocalLeader>k", function()
            vim.lsp.buf.hover { border = "single" }
        end, { buffer = args.buf })

        vim.keymap.set({ "i" }, "<C-s>", function()
            vim.lsp.buf.signature_help { border = "single" }
        end, { buffer = args.buf })

        vim.keymap.set({ "n", "v", "x" }, "<LocalLeader>f", function()
            vim.lsp.buf.format { async = false }
        end, { buffer = args.buf })

        vim.keymap.set({ "n" }, "<Leader>tl", ":LspStop<CR>")
    end,
})
