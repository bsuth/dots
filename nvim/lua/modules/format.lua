local C = require('constants')
local path = require('utils.path')
local io = require('utils.stdlib').io
local string = require('utils.stdlib').string
local table = require('utils.stdlib').table

-- -----------------------------------------------------------------------------
-- Jobs
-- -----------------------------------------------------------------------------

local buffer_async_jobs = {}

vim.api.nvim_create_autocmd('BufModifiedSet', {
  group = 'bsuth',
  callback = function(params)
    if vim.api.nvim_buf_get_option(params.buf, 'modified') then
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

local function has_ancestor(filenames)
  local dir = path.lead(path.dirname(vim.api.nvim_buf_get_name(0)))

  while dir:match('^' .. C.HOME) do
    for _, filename in ipairs(filenames) do
      if io.exists(path.join(dir, filename)) then
        return true
      end
    end

    dir = path.lead(path.dirname(dir))
  end
end

local function format_sync(command)
  local buffer = vim.api.nvim_get_current_buf()
  local stdout = vim.fn.system(command)

  if vim.v.shell_error == 0 then
    local trimmed_stdout = vim.lsp.util.trim_empty_lines(string.split(stdout, '\n'))

    if #trimmed_stdout > 0 then
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, trimmed_stdout)
      vim.cmd('noautocmd write')

      -- Sometimes diagnostics seem to disappear after editing, so manually
      -- refresh here.
      vim.diagnostic.enable(buffer)
    end
  end
end

local function format_async(command)
  local buffer = vim.api.nvim_get_current_buf()

  local job_id = vim.fn.jobstart(command, {
    stdout_buffered = true,
    on_stdout = function(_, stdout)
      local trimmed_stdout = vim.lsp.util.trim_empty_lines(stdout)
      if #trimmed_stdout > 0 then
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, trimmed_stdout)
        vim.cmd('noautocmd write')

        -- Sometimes diagnostics seem to disappear after editing, so manually
        -- refresh here.
        vim.diagnostic.enable(buffer)
      end
    end,
    on_exit = function(job_id)
      buffer_async_jobs[job_id] = nil
    end,
  })

  buffer_async_jobs[job_id] = buffer
end

-- -----------------------------------------------------------------------------
-- Tidy
--
-- Modified version of https://github.com/mcauley-penney/tidy.nvim
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'bsuth',
  callback = function()
    local cursor = vim.api.nvim_win_get_cursor(0)

    vim.cmd([[keepjumps keeppatterns %s/\s\+$//e]])                   -- trailing whitespace
    vim.cmd([[keepjumps keeppatterns silent! 0;/^\%(\n*.\)\@!/,$d_]]) -- trailing newlines

    cursor[1] = math.min(cursor[1], vim.api.nvim_buf_line_count(0))
    vim.api.nvim_win_set_cursor(0, cursor)
  end,
})

-- -----------------------------------------------------------------------------
-- Clang Format
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('BufWritePost', {
  group = 'bsuth',
  pattern = C.C_PATTERNS,
  callback = function()
    if has_ancestor({ '.clang-format' }) then
      format_sync('clang-format ' .. vim.api.nvim_buf_get_name(0))
    end
  end,
})

-- -----------------------------------------------------------------------------
-- EmmyLuaCodeStyle
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'bsuth',
  pattern = { '*.lua' },
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- -----------------------------------------------------------------------------
-- Eslint
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'bsuth',
  pattern = C.JS_PATTERNS,
  callback = function()
    if vim.fn.exists(':EslintFixAll') ~= 0 then
      vim.cmd('EslintFixAll')
    end
  end,
})

-- -----------------------------------------------------------------------------
-- Prettier
-- -----------------------------------------------------------------------------

local prettier_patterns = table.merge(
  C.CSS_PATTERNS,
  C.HTML_PATTERNS,
  C.JSON_PATTERNS
)

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
  pattern = prettier_patterns,
  callback = function()
    if has_ancestor(prettier_configs) then
      format_async('npx prettier ' .. vim.api.nvim_buf_get_name(0))
    end
  end,
})
