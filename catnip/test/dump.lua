local catnip = require('catnip')
local key = require('key')

local function dump_object(name, object, fields)
  print(name .. ' {')

  for _, field in ipairs(fields) do
    local value = object[field]

    if type(value) == 'string' then
      print('  { field } = \"{ value }\",')
    else
      print('  { field } = { value },')
    end
  end

  print('}')
end

local function dump_cursor()
  dump_object('cursor', catnip.cursor, {
    'x',
    'y',
    'name',
    'theme',
    'size',
  })
end

local function dump_keyboards()
  for keyboard in catnip.keyboards do
    dump_object('keyboard::{keyboard.id }', keyboard, {
      'name',
      'xkb_rules',
      'xkb_model',
      'xkb_layout',
      'xkb_variant',
      'xkb_options',
    })
  end
end

local function dump_outputs()
  for output in catnip.outputs do
    dump_object('output::{ output.id }', output, {
      'x',
      'y',
      'width',
      'height',
      'refresh',
      'scale',
      'mode',
    })

    for mode in output.modes do
      dump_object('output::{ output.id }.mode::{ mode.id }', mode, {
        'width',
        'height',
        'refresh',
      })
    end
  end
end

local function dump_windows()
  for window in catnip.windows do
    dump_object('window::{ window.id }', window, {
      'x',
      'y',
      'z',
      'width',
      'height',
      'visible',
      'focused',
      'fullscreen',
      'maximized',
    })
  end
end

key.release({ 'mod1' }, 'd', function()
  dump_cursor()
  dump_keyboards()
  dump_outputs()
  dump_windows()
end)

