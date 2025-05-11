local path = require('lib.path')
local io = require('lib.stdlib').io

local HOME = os.getenv('HOME')

-- -----------------------------------------------------------------------------
-- Jobs
-- -----------------------------------------------------------------------------

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

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

--- @param filenames string[]
--- @return boolean
local function has_ancestor(filenames)
  local dir = path.lead(path.dirname(vim.api.nvim_buf_get_name(0)))

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

--- @param buffer number
--- @param command string
local function format_sync(buffer, command)
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

--- @param buffer number
--- @param command string
local function format_async(buffer, command)
  local job_id = vim.fn.jobstart(command, {
    stdout_buffered = true,
    on_stdout = function(_, stdout)
      local trimmed_stdout = vim.split(stdout, '\n', { trimempty = true })

      if #trimmed_stdout > 0 then
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, trimmed_stdout)
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

-- -----------------------------------------------------------------------------
-- Clang Format
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('BufWritePost', {
  group = 'bsuth',
  pattern = { '*.c', '*.h' },
  callback = function(args)
    if has_ancestor({ '.clang-format' }) then
      format_sync(args.buf, 'clang-format ' .. vim.api.nvim_buf_get_name(args.buf))
    end
  end,
})

-- -----------------------------------------------------------------------------
-- EmmyLuaCodeStyle
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'bsuth',
  pattern = { '*.lua' },
  callback = function(args)
    vim.lsp.buf.format()

    -- Sometimes diagnostics seem to disappear after editing, so manually
    -- refresh here.
    vim.diagnostic.enable(true, { bufnr = args.buf })
  end,
})

-- -----------------------------------------------------------------------------
-- Golang
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'bsuth',
  pattern = { '*.go' },
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- -----------------------------------------------------------------------------
-- Eslint
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'bsuth',
  pattern = { '*.js', '*.mjs', '*.jsx', '*.ts', '*.tsx', '*.vue' },
  callback = function()
    if vim.fn.exists(':EslintFixAll') ~= 0 then
      vim.cmd('EslintFixAll')
    end
  end,
})

-- -----------------------------------------------------------------------------
-- Prettier
-- -----------------------------------------------------------------------------

-- https://prettier.io/docs/en/configuration.html
local prettier_configs = {
  '.prettierrc',
  '.prettierrc.json',
  '.prettierrc.yml',
  '.prettierrc.yaml',
  '.prettierrc.json5',
  '.prettierrc.js',
  'prettier.config.js',
  '.prettierrc.mjs',
  'prettier.config.mjs',
  '.prettierrc.cjs',
  'prettier.config.cjs',
  '.prettierrc.toml',
}

vim.api.nvim_create_autocmd('BufWritePost', {
  group = 'bsuth',
  pattern = { '*.css', '*.scss', '*.less', '*.html', '*.json', '*.cjson' },
  callback = function(args)
    if has_ancestor(prettier_configs) then
      format_async(args.buf, 'npx prettier ' .. vim.api.nvim_buf_get_name(args.buf))
    end
  end,
})
