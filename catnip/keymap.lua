local catnip = require('catnip')

local keymappings = {}

local function get_key_event_mappings(event)
  local modifier_flags = {
    event.shift and 1 or 0,
    event.ctrl and 1 or 0,
    event.alt and 1 or 0,
  }

  local id = table.concat(modifier_flags) .. ':' .. event.code
  return keymappings[id]
end

catnip.subscribe('keyboard::keydown', function(keyboard, event)
  local key_event_mappings = get_key_event_mappings(event)
  event.prevent_notify = (key_event_mappings ~= nil)
end)

catnip.subscribe('keyboard::keyup', function(keyboard, event)
  local key_event_mappings = get_key_event_mappings(event)

  if key_event_mappings ~= nil then
    event.prevent_notify = true

    for _, callback in ipairs(key_event_mappings) do
      callback()
    end
  end
end)

return function(modifiers, key, callback)
  local modifier_flags = { 0, 0, 0 }

  for _, modifier in ipairs(modifiers) do
    if modifier == 'shift' then
      modifier_flags[1] = 1
    elseif modifier == 'ctrl' then
      modifier_flags[2] = 1
    elseif modifier == 'alt' then
      modifier_flags[3] = 1
    end
  end

  local id = table.concat(modifier_flags) .. ':' .. string.byte(key)
  keymappings[id] = keymappings[id] or {}
  table.insert(keymappings[id], callback)
end
