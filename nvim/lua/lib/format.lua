local path = require('lib.path')
local io = require('lib.stdlib').io

local M = {}

local HOME = os.getenv('HOME')
local buffer_async_jobs = {}

vim.api.nvim_create_autocmd('BufModifiedSet', {
  group = 'bsuth',
  callback = function(params)
    if vim.api.nvim_get_option_value('modified', { buf = params.buf }) then
      for job_id, buffer in pairs(buffer_async_jobs) do
        if buffer == params.buf then
          vim.fn.jobstop(job_id)
        end
      end
    end
  end,
})

---@param buffer number
---@param filenames string[]
---@return boolean
function M.has_ancestor(buffer, filenames)
  local dir = path.lead(path.dirname(vim.api.nvim_buf_get_name(buffer)))

  while dir:match('^' .. HOME) do
    for _, filename in ipairs(filenames) do
      if io.exists(path.join(dir, filename)) then
        return true
      end
    end

    dir = path.lead(path.dirname(dir))
  end

  return false
end

---@param buffer number
---@param command string
function M.sync(buffer, command)
  local stdout = vim.fn.system(command)

  if vim.v.shell_error == 0 then
    local trimmed_stdout = vim.split(stdout, '\n', { trimempty = true })

    if #trimmed_stdout > 0 then
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, trimmed_stdout)
      vim.cmd('noautocmd update')

      -- Sometimes diagnostics seem to disappear after editing, so manually
      -- refresh here.
      vim.diagnostic.enable(true, { bufnr = buffer })
    end
  end
end

---@param buffer number
---@param command string
function M.async(buffer, command)
  local job_id = vim.fn.jobstart(command, {
    stdout_buffered = true,
    on_stdout = function(_, stdout)
      if #stdout > 0 then
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, stdout)
        vim.cmd('noautocmd update')

        -- Sometimes diagnostics seem to disappear after editing, so manually
        -- refresh here.
        vim.diagnostic.enable(true, { bufnr = buffer })
      end
    end,
    on_exit = function(job_id)
      buffer_async_jobs[job_id] = nil
    end,
  })

  buffer_async_jobs[job_id] = buffer
end

return M
