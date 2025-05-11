-- -----------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------

local BUFFER_CWD = {}

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

-- Do not make this local! zsh needs this for cd hook in nested terminal.
function SAVE_BUFFER_CWD()
  local buffer = vim.api.nvim_get_current_buf()
  BUFFER_CWD[buffer] = vim.fn.getcwd()
end

--- @param buffer number
--- @return boolean
local function should_track_buffer_cwd(buffer)
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = buffer })
  local buftype = vim.api.nvim_get_option_value('buftype', { buf = buffer })
  local bufname = vim.api.nvim_buf_get_name(buffer)

  return (
    filetype ~= 'help' and
    filetype ~= 'man' and
    buftype ~= 'terminal' and
    buftype ~= 'prompt' and
    not bufname:match('^[a-z]+://') and
    not bufname:match('^/tmp/nvim.bsuth')
  )
end

-- -----------------------------------------------------------------------------
-- Autocommands
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('TermOpen', {
  group = 'bsuth',
  callback = SAVE_BUFFER_CWD,
})

vim.api.nvim_create_autocmd('TermClose', {
  group = 'bsuth',
  callback = function(params)
    BUFFER_CWD[params.buf] = nil
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = 'bsuth',
  callback = function()
    local buffer = vim.api.nvim_get_current_buf()

    if BUFFER_CWD[buffer] ~= nil then
      vim.cmd('cd ' .. BUFFER_CWD[buffer])
      return
    end

    if should_track_buffer_cwd(buffer) then
      vim.cmd('cd ' .. vim.fn.expand('%:p:h'))
    end
  end,
})
