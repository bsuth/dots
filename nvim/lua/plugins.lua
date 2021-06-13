--
-- vim-plug
--

local plug =
  io.open(os.getenv('HOME') .. '/.config/nvim/autoload/plug.vim', 'r')

if plug == nil then
  os.execute([[
		curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	]])
  nvim_command('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
else
  io.close(plug)
end

local plugins = {
  'joshdick/onedark.vim',
  'tpope/vim-surround',
  'tpope/vim-commentary',
  'junegunn/fzf',
  'sheerun/vim-polyglot',
  'lambdalisue/suda.vim',
  'justinmk/vim-dirvish',
  { [[ 'neoclide/coc.nvim', {'branch': 'release'}  ]] },
  'matze/vim-move',
  'itchyny/lightline.vim',
  '~/projects/nvim-tabby',
  '~/projects/nvim-imacs',
}

nvim_call_function('plug#begin', { '~/.config/nvim/bundle' })
for _, plugin in ipairs(plugins) do
  if type(plugin) == 'string' then
    nvim_command(([[ Plug '%s' ]]):format(plugin))
  elseif type(plugin) == 'table' then
    nvim_command('Plug ' .. plugin[1])
  end
end
nvim_call_function('plug#end', {})

--
-- misc
--

nvim_set_var('suda_smart_edit', true)
nvim_command('colorscheme onedark')

--
-- coc
--

nvim_set_var('coc_global_extensions', {
  'coc-tsserver',
  'coc-css',
  'coc-json',
  'coc-prettier',
})

--
-- lightline
--

local lightlineOneDark = (function()
  local palette = {}

  for k, v in pairs(nvim_call_function('onedark#GetColors', {})) do
    palette[k] = { v.gui, tonumber(v.cterm) }
  end

  return palette
end)()

function lightlineMode(color, normal)
  local mode = {
    left = {
      { lightlineOneDark.black, color, 'bold' },
      { color, lightlineOneDark.special_grey },
    },
    middle = {
      { lightlineOneDark.white, lightlineOneDark.black },
    },
    right = {
      { lightlineOneDark.black, color, 'bold' },
      { lightlineOneDark.white, lightlineOneDark.special_grey },
    },
  }

  if normal then
    mode.error = { lightlineOneDark.red, lightlineOneDark.black }
    mode.warning = { lightlineOneDark.yellow, lightlineOneDark.black }
  end

  return mode
end

nvim_set_var(
  'lightline#colorscheme#onedark#palette',
  nvim_call_function('lightline#colorscheme#flatten', {
      {
        inactive = lightlineMode(lightlineOneDark.white),
        normal = lightlineMode(lightlineOneDark.green, true),
        insert = lightlineMode(lightlineOneDark.blue),
        command = lightlineMode(lightlineOneDark.yellow),
        terminal = lightlineMode(lightlineOneDark.red),
        visual = lightlineMode(lightlineOneDark.purple),
        tabline = lightlineMode(lightlineOneDark.cyan),
      },
    })
)

nvim_set_var('lightline', {
  colorscheme = 'onedark',
  active = {
    left = {
      { 'mode', 'paste' },
      { 'readonly', 'filename', 'modified' },
    },
    right = {
      { 'lineinfo' },
      { 'percent' },
      { 'filetype' },
    },
  },
})
