local catnip = require('catnip')
local keymap = require('keymap')
local window_utils = require('windows.utils')

local window_buffer = {}

keymap({ 'alt' }, 'm', function()
  local active_window = window_utils.get_active_window()
  active_window.visible = false
  table.insert(window_buffer, active_window)
  catnip.publish('bsuth::tile')
end)

keymap({ 'alt', 'shift' }, 'M', function()
  local window = table.remove(window_buffer, 1)

  if window == nil then
    return
  end

  window.visible = true
  window.active = true

  catnip.publish('bsuth::tile')
end)
