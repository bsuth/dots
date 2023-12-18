local catnip = require('catnip')
local keymap = require('keymap')

local function dump_object(name, object, fields)
  print(name .. ' {')

  for _, field in ipairs(fields) do
    local value = object[field]

    if (type(value) == 'string') then
      print(('  %s = "%s",'):format(field, value))
    else
      print(('  %s = %s,'):format(field, value))
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
  for i = 1, #catnip.keyboards do
    dump_object('keyboard_' .. i, catnip.keyboards[i], {
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
  for i = 1, #catnip.outputs do
    dump_object('output_' .. i, catnip.outputs[i], {
      'x',
      'y',
      'width',
      'height',
      'refresh',
      'scale',
      'mode',
    })
  end
end

local function dump_windows()
  for i = 1, #catnip.windows do
    dump_object('window_' .. i, catnip.windows[i], {
      'x',
      'y',
      'width',
      'height',
      'visible',
      'active',
      'maximized',
      'fullscreen',
    })
  end
end

keymap({ 'alt' }, 'd', function()
  dump_cursor()
  dump_keyboards()
  dump_outputs()
  dump_windows()
end)
