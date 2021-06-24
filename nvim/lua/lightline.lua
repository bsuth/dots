--
-- Theme
--

local palette = (function()
  local palette = {}

  for k, v in pairs(nvim_call_function('onedark#GetColors', {})) do
    palette[k] = { v.gui, tonumber(v.cterm) }
  end

  return palette
end)()

local function lightline_theme(color, flag)
  local mode = {
    left = {
      { palette.black, color, 'bold' },
      { color, palette.special_grey },
    },
    middle = {
      { palette.white, palette.black },
    },
    right = {
      { palette.black, color, 'bold' },
      { palette.white, palette.special_grey },
    },
    error = { palette.red, palette.black },
    warning = { palette.yellow, palette.black },
  }

  return mode
end

nvim_set_var(
  'lightline#colorscheme#onedark#palette',
  nvim_call_function('lightline#colorscheme#flatten', {
      {
        inactive = lightline_theme(palette.white),
        normal = lightline_theme(palette.green),
        insert = lightline_theme(palette.blue),
        command = lightline_theme(palette.yellow),
        terminal = lightline_theme(palette.red),
        visual = lightline_theme(palette.purple),
        tabline = {
          left = {
            { palette.white, palette.black, 'bold' },
          },
          right = {
            { palette.black, palette.white, 'bold' },
          },
          tabsel = {
            { palette.black, palette.cyan, 'bold' },
          },
        },
      },
    })
)

--
-- Components
--

function lightline_file_name()
  local filetype = nvim_buf_get_option(0, 'filetype')
  local filename = nvim_call_function('expand', { '%:t' })
  return filetype == 'dirvish' and 'Dirvish' or filename or '[No Name]'
end

nvim_command([[ function! LightlineFileName()
  return luaeval('lightline_file_name()')
endfunction ]])

--
-- Setup
--

nvim_set_var('lightline', {
  colorscheme = 'onedark',

  active = {
    left = {
      { 'mode', 'paste' },
      { 'gitbranch', 'readonly', 'filename', 'modified' },
    },
    right = {
      { 'lineinfo' },
      { 'percent' },
      { 'filetype' },
    },
  },

  component_function = {
    filename = 'LightlineFileName',
    gitbranch = 'FugitiveHead',
  },

  tabline_separator = { left = '', right = '' },
  tabline_subseparator = { left = '', right = '' },

  tab = {
    active = { 'filename', 'modified' },
    inactive = { 'filename', 'modified' },
  },

  tab_component_function = {
    tabname = 'LightlineTabName',
  },
})
