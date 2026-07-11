local tasks = require "custom.tasks"

local task_list = {
  ["Makefile"] = {
    cmd = { "make" },
  },

  ["Justfile"] = {
    cmd = { "just" },
  },

  ["Web: live-server in CWD"] = {
    {
      ft = { "html", "css", "javascript", "typescript" },
      cmd = {
        "live-server",
      },
    },
  },

  ["Lua: Run"] = {
    ft = { "lua" },
    cmd = {
      "lua",
      vim.fn.expand "%",
    },
  },

  ["Python: Run"] = {
    ft = { "python" },
    cmd = {
      "python",
      vim.fn.expand "%",
    },
  },

  ["Bash: Run"] = {
    ft = { "bash", "sh" },
    cmd = {
      "bash",
      vim.fn.expand "%",
    },
  },

  ["Typst: Watch"] = {
    ft = { "typst" },
    cmd = {
      "typst",
      "w",
      vim.fn.expand "%",
    },
  },

  ["Typst: Compile"] = {
    ft = { "typst" },
    cmd = {
      "typst",
      "c",
      vim.fn.expand "%",
    },
  },
}

vim.keymap.set({ "n" }, "<Leader>r", function()
  vim.cmd "write"
  tasks.run_last_or_select(task_list)
end)

vim.keymap.set({ "n" }, "<Leader><S-r>", function()
  tasks.run_input()
end)

vim.keymap.set({ "n" }, "<Leader><C-r>", function()
  tasks.clear_last_task()
end)
