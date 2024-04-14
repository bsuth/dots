local catnip = require('catnip')
local windows = require('utils.windows')
local keymap = require('keymap')

local function focus_direction(direction)
  local prev_focused_window = windows.get_focused_window()

  windows.focus_window_in_direction(direction)

  if windows.get_focused_window() ~= prev_focused_window then
    return
  end

  windows.focus_output_in_direction(direction)
end

keymap({ 'mod1' }, 'h', function() focus_direction('left') end)
keymap({ 'mod1' }, 'j', function() focus_direction('down') end)
keymap({ 'mod1' }, 'k', function() focus_direction('up') end)
keymap({ 'mod1' }, 'l', function() focus_direction('right') end)

catnip.subscribe('window::create', function(window)
  window:focus()
end)
