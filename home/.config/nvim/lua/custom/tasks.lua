local M = {}

M.state = {
  bufnr = nil,
  winnr = nil,
  task = nil,
}

-- = Private ===================================================================

local function table_deep_copy(tbl)
  local copy = {}
  for k, v in pairs(tbl) do
    if type(v) ~= "table" then
      copy[k] = v
    else
      copy[k] = table_deep_copy(v)
    end
  end
  return copy
end

local function string_match_list(s, patterns)
  for _, pattern in ipairs(patterns) do
    if string.match(s, pattern) then
      return true
    end
  end
  return false
end

-- = Public ====================================================================

-- -- Files --------------------------------------------------------------------

M.get_cwd_files = function()
  return vim.fs.find(function(name, path)
    return true
  end, { limit = 1000 })
end

M.search_cwd_files = function(pattern)
  for file_name, _ in
  vim.fs.dir(".", {
    skip = function(dir_name)
      if
          string_match_list(dir_name, { "node_modules", "%.git", "%.venv" })
      then
        return false
      end
      return true
    end,
  })
  do
    if string.match(file_name, pattern) then
      return true
    end
  end
  return false
end

-- -- Running Tasks ------------------------------------------------------------

M.run_task = function(task)
  -- Create a copy of the given task.
  local default_task = {
    enter = false,
    win_opts = {
      height = 10,
      split = "below",
      style = "minimal",
    },
  }
  local tk = table_deep_copy(task)
  tk = vim.tbl_deep_extend("force", tk, default_task)

  -- Setup the command to run.
  local cmd
  if type(tk.cmd) == "table" then
    cmd = table.concat(tk.cmd, " ")
  elseif type(tk.cmd) == "string" then
    cmd = tk.cmd
  end
  cmd = vim.fn.expandcmd(cmd)

  -- Create a buffer to serve as the interface of the task/command.
  local bufnr = vim.api.nvim_create_buf(false, true)
  local last_bufnr = M.state.bufnr
  if M.state.task then
    vim.fn.jobstop(M.state.task.jobid)
    vim.fn.jobwait { M.state.task.jobid }
  end
  M.state.bufnr = bufnr

  -- Connect the task and the buffer, saving the buffer reference in global
  -- scope.
  vim.api.nvim_buf_call(bufnr, function()
    tk.jobid = vim.fn.jobstart(cmd, { term = true })
  end)
  M.state.task = tk

  M.window(tk, bufnr, last_bufnr)
end

M.window = function(tk, bufnr, last_bufnr)
  -- If a window with the last task buffer exists, change the window's buffer
  -- to the current task buffer and delete the old task.
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == last_bufnr then
      vim.api.nvim_win_set_buf(win, bufnr)
      vim.api.nvim_buf_delete(last_bufnr, {})
      return
    end
  end

  -- If there was no window but there is an old task buffer, delete it.
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if buf == last_bufnr then
      vim.api.nvim_buf_delete(last_bufnr, {})
    end
  end

  -- Create a new window for the new task.
  local winnr = vim.api.nvim_open_win(bufnr, tk.enter, tk.win_opts)
  M.state.winnr = winnr
  vim.wo[winnr].winbar = ""
  vim.wo[winnr].winfixheight = true
  vim.wo[winnr].winfixwidth = true
end

M.run_task_list = function(task_list)
  local final_task_list = {}
  for k, task in pairs(task_list) do
    if
        type(k) ~= "number"
        and (not task.ft or vim.tbl_contains(task.ft, vim.bo.ft))
        and (not task.cond or task.cond())
    then
      final_task_list[k] = task
    end
  end

  for i = 1, #task_list, 1 do
    local generated_tasks = task_list[i]()
    for _, task in ipairs(generated_tasks) do
      local task_name = "default task name"
      if type(task.cmd) == "table" then
        task_name = table.concat(task.cmd, " ")
      elseif type(task.cmd) == "string" then
        task_name = task.cmd
      end
      final_task_list[task_name] = task
    end
  end

  local tasks_names = vim.tbl_keys(final_task_list)
  if #tasks_names > 1 then
    table.sort(tasks_names)
    vim.ui.select(
      tasks_names,
      { prompt = "Select a task:" },
      function(task_name)
        M.run_task(final_task_list[task_name])
      end
    )
  else
    for _, task in pairs(final_task_list) do
      M.run_task(task)
    end
  end
end

M.run_shell = function()
  vim.ui.input({ prompt = "Shell command to run: " }, function(input)
    M.run_task {
      cmd = input,
    }
  end)
end

M.run_last_task = function()
  M.run_task(M.state.task)
end

M.clear_last_task = function()
  vim.fn.jobstop(M.state.task.jobid)
  M.state.task = nil
end

M.run_last_or_list = function(tasks)
  if M.state.task then
    M.run_last_task()
  else
    M.run_task_list(tasks)
  end
end

return M
