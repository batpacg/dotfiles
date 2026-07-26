local tasks = require "custom.tasks"

local task_list = {
  function() -- Generate tasks for shell scripts in CWD.
    local files = tasks.get_cwd_files()
    local generated_tasks = {}
    for _, file in ipairs(files) do
      if string.match(file, ".*%.sh$") then
        table.insert(generated_tasks, { cmd = "bash " .. file })
      end
    end
    return generated_tasks
  end,

  ["Makefile"] = {
    cmd = "make",
    cond = function()
      return tasks.search_cwd_files "^[Mm]akefile$"
    end,
  },

  ["Justfile"] = {
    cmd = "just",
    cond = function()
      return tasks.search_cwd_files "^[Jj]ustfile$"
    end,
  },

  ["Web: live-server in CWD"] = {
    ft = { "html", "css", "javascript", "typescript" },
    cmd = "live-server",
  },

  ["Lua: Run"] = {
    ft = { "lua" },
    cmd = "lua %",
  },

  ["Python: Run"] = {
    ft = { "python" },
    cmd = "python %",
  },

  ["Bash: Run"] = {
    ft = { "bash", "sh" },
    cmd = "bash %",
  },

  ["Typst: Watch"] = {
    ft = { "typst" },
    cmd = "typst w %",
  },

  ["Typst: Compile"] = {
    ft = { "typst" },
    cmd = "typst c %",
  },

  ["C: Compile & Run"] = {
    ft = { "c" },
    cmd = "gcc % -o %:r && ./%:r",
  },
}

vim.keymap.set({ "n" }, "<Leader>r", function()
  vim.cmd "write"
  tasks.run_last_or_list(task_list)
end)

vim.keymap.set({ "n" }, "<Leader><S-r>", function()
  tasks.run_input()
end)

vim.keymap.set({ "n" }, "<Leader><C-r>", function()
  tasks.clear_last_task()
end)
