local M = {}

M.state = {
  bufnr = nil,
  task = nil,
}

M.run_task = function(task)
  task = vim.tbl_deep_extend("force", task, {
    enter = false,
    win = {
      height = 10,
      split = "below",
    },
  })

  local bufnr = vim.api.nvim_create_buf(false, true)
  local last_bufnr = M.state.bufnr
  M.state.bufnr = bufnr

  vim.api.nvim_buf_call(bufnr, function()
    vim.fn.jobstart(task.cmd, { term = true })
  end)
  M.state.task = task

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
  local winnr =
      vim.api.nvim_open_win(bufnr, task.enter, { split = task.win.split })
  vim.wo[winnr].winbar = ""
  if task.win.height then
    vim.api.nvim_win_set_height(winnr, task.win.height)
  end
end

M.run_select_task = function(tasks)
  vim.ui.select(
    vim.tbl_keys(tasks),
    { prompt = "Select a task:" },
    function(choice)
      M.run_task(tasks[choice])
    end
  )
end

M.run_last_task = function()
  M.run_task(M.state.task)
end

M.clear_last_task = function()
  M.state.task = nil
end

M.run_last_or_select = function(tasks)
  if M.state.task then
    M.run_last_task()
  else
    M.run_select_task(tasks)
  end
end

M.run_input = function()
  vim.ui.input({ prompt = "Shell command to run: " }, function(input)
    M.run_task {
      cmd = input,
    }
  end)
end

return M
