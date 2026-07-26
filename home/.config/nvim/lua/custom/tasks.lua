local M = {}

-- =============================================================================

M.state = {
  bufnr = nil,
  task = nil,
}

-- =============================================================================

local function tbl_deep_copy(tbl)
  local copy = {}
  for k, v in pairs(tbl) do
    if type(v) ~= "table" then
      copy[k] = v
    else
      copy[k] = tbl_deep_copy(v)
    end
  end
  return copy
end

-- =============================================================================

M.get_cwd_files = function()
  local files_glob = vim.fn.glob "**/*"
  local files = {}
  for line in string.gmatch(files_glob, "[^\n]+") do
    table.insert(files, line)
  end
  return files
end

M.search_cwd_files = function(pattern)
  local files = M.get_cwd_files()
  for _, file in pairs(files) do
    if string.match(file, pattern) then
      return true
    end
  end
  return false
end

-- =============================================================================

M.run_task = function(task)
  local default_task = {
    enter = false,
    win = {
      height = 10,
      split = "below",
    },
  }
  local tk = tbl_deep_copy(task)
  tk = vim.tbl_deep_extend("force", tk, default_task)

  local cmd
  if type(tk.cmd) == "table" then
    cmd = table.concat(tk.cmd, " ")
  elseif type(tk.cmd) == "string" then
    cmd = tk.cmd
  end
  cmd = vim.fn.expandcmd(cmd)

  local bufnr = vim.api.nvim_create_buf(false, true)
  local last_bufnr = M.state.bufnr
  M.state.bufnr = bufnr

  vim.api.nvim_buf_call(bufnr, function()
    tk.jobid = vim.fn.jobstart(cmd, { term = true })
  end)
  M.state.task = tk

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
  local winnr = vim.api.nvim_open_win(bufnr, tk.enter, { split = tk.win.split })
  vim.wo[winnr].winbar = ""
  if tk.win.height then
    vim.api.nvim_win_set_height(winnr, tk.win.height)
  end
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
      local task_name = table.concat(task.cmd, " ")
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

M.run_input = function()
  vim.ui.input({ prompt = "Shell command to run: " }, function(input)
    M.run_task {
      cmd = input,
    }
  end)
end

-- =============================================================================

M.run_last_task = function()
  vim.fn.jobstop(M.state.task.jobid)
  vim.fn.jobwait { M.state.task.jobid }
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

-- =============================================================================

return M
