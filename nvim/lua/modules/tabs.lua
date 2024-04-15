-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<c-t>', function() vim.cmd('tabnew ' .. vim.fn.getcwd()) end)
vim.keymap.set('n', '<Tab>', function() vim.cmd('tabnext') end)
vim.keymap.set('n', '<S-Tab>', function() vim.cmd('tabprevious') end)

-- -----------------------------------------------------------------------------
-- Tabline
-- -----------------------------------------------------------------------------

vim.opt.tabline = "%!v:lua.TABLINE()"

local function tabline_name(tabpage, width)
  local window = vim.api.nvim_tabpage_get_win(tabpage)
  local buffer = vim.api.nvim_win_get_buf(window)

  local name = vim.api.nvim_buf_get_name(buffer)
  name = name:gsub('^/home/bsuth', '~')

  local raw_padding = (width - #name) / 2

  if raw_padding < 1 then
    raw_padding = 1
    -- Truncate to `width - 5`: -2 for padding, -3 for ellipsis
    name = name:sub(1, math.floor(width - 5)) .. '...'
  end

  local left_padding = math.floor(raw_padding)
  local right_padding = math.ceil(raw_padding)

  return table.concat({
    (' '):rep(left_padding),
    name,
    (' '):rep(right_padding),
  })
end

function TABLINE()
  local tabline = {}

  local last_tabpage = vim.fn.tabpagenr('$')
  local current_tabpage = vim.api.nvim_get_current_tabpage()

  local columns = vim.o.columns
  local min_tab_width = math.floor(columns / last_tabpage)
  local width_remainder = columns % last_tabpage

  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    local tab_width = min_tab_width

    if width_remainder > 0 then
      tab_width = tab_width + 1
      width_remainder = width_remainder - 1
    end

    if tabpage == current_tabpage then
      table.insert(tabline, '%#TabLineSel#')
    else
      table.insert(tabline, '%#TabLine#')
    end

    table.insert(tabline, tabline_name(tabpage, tab_width))
  end

  return table.concat(tabline)
end
