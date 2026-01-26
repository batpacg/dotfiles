local ls = require "luasnip"
local s = ls.snippet
-- local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local l = require("luasnip.extras").lambda
-- local rep = require("luasnip.extras").rep
-- local p = require("luasnip.extras").partial
-- local m = require("luasnip.extras").match
-- local n = require("luasnip.extras").nonempty
-- local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local types = require "luasnip.util.types"
-- local conds = require "luasnip.extras.conditions"
-- local conds_expand = require "luasnip.extras.conditions.expand"

ls.add_snippets("all", {
    s("+h2", {
        f(function()
            local commentstring = vim.bo.commentstring:gsub("%%s", "")
            local delimiter = "="
            return commentstring .. delimiter:rep(80 - #commentstring)
        end),
        t { "", "" },
    }),
    s("+h3", {
        f(function()
            local commentstring = vim.bo.commentstring:gsub("%%s", "")
            local delimiter = "-"
            return commentstring .. delimiter:rep(80 - #commentstring)
        end),
        t { "", "" },
    }),
}, { type = "autosnippets", key = "all_auto" })

ls.add_snippets("typst", {
    s(
        "+fig",
        fmt(
            [[
        #figure(
            image("./{}", width: {}),
            caption: [{}],
        ) <{}>

        ]],
            { i(1), i(2), i(3), i(4) }
        )
    ),
    -- s("+tp", fmt([[
    -- #import "template.typ": *
    -- #conf.with()
    -- ]], {})),
}, { type = "autosnippets", key = "typst_auto" })

ls.add_snippets("markdown", {
    s("+todo", { t "- [ ] ", i(1, "item") }),
    s("+sc", { t { "```" }, i(1, "language"), t { "", "```", "" } }),
}, { type = "autosnippets", key = "markdown_auto" })
