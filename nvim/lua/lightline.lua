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

local function lightline_theme(color, normal)
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
  }

  if normal then
    mode.error = { palette.red, palette.black }
    mode.warning = { palette.yellow, palette.black }
  end

  return mode
end

nvim_set_var(
  'lightline#colorscheme#onedark#palette',
  nvim_call_function('lightline#colorscheme#flatten', {
      {
        inactive = lightline_theme(palette.white),
        normal = lightline_theme(palette.green, true),
        insert = lightline_theme(palette.blue),
        command = lightline_theme(palette.yellow),
        terminal = lightline_theme(palette.red),
        visual = lightline_theme(palette.purple),
        tabline = lightline_theme(palette.cyan),
      },
    })
)

--
-- Components
--

function lightline_filename()
  local filetype = nvim_buf_get_option(0, 'filetype')
  local filename = nvim_call_function('expand', { '%:t' })
  return filetype == 'dirvish' and 'Dirvish' or filename or '[No Name]'
end

--
-- Setup
--

nvim_command([[ function! LightlineFilename()
  return luaeval('lightline_filename()')
endfunction ]])

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
    filename = 'LightlineFilename',
    gitbranch = 'FugitiveHead',
  },
})
