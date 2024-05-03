local catnip = require('catnip')

local key_event_callbacks = {}

local function get_key_event_callbacks(event)
  local is_printable_ascii = 32 < event.code and event.code < 127

  local index = table.concat({
    (event.shift and not is_printable_ascii) and 1 or 0,
    event.ctrl and 1 or 0,
    event.mod1 and 1 or 0,
    event.mod2 and 1 or 0,
    event.mod3 and 1 or 0,
    event.mod4 and 1 or 0,
    event.mod5 and 1 or 0,
    is_printable_ascii and string.char(event.code) or event.name,
  })

  return key_event_callbacks[index]
end

catnip.subscribe('keyboard::key::press', function(_, event)
  if get_key_event_callbacks(event) ~= nil then
    event.prevent_notify = true
  end
end)

catnip.subscribe('keyboard::key::release', function(_, event)
  local callbacks = get_key_event_callbacks(event)

  if callbacks == nil then
    return
  end

  event.prevent_notify = true

  for _, callback in ipairs(callbacks) do
    callback()
  end
end)

return function(modifiers, key, callback)
  local id_parts = { 0, 0, 0, 0, 0, 0, 0, key }

  for _, modifier in ipairs(modifiers) do
    if modifier == 'shift' then
      id_parts[1] = 1
    elseif modifier == 'ctrl' then
      id_parts[2] = 1
    elseif modifier == 'mod1' then
      id_parts[3] = 1
    elseif modifier == 'mod2' then
      id_parts[4] = 1
    elseif modifier == 'mod3' then
      id_parts[5] = 1
    elseif modifier == 'mod4' then
      id_parts[6] = 1
    elseif modifier == 'mod5' then
      id_parts[7] = 1
    end
  end

  local id = table.concat(id_parts)
  key_event_callbacks[id] = key_event_callbacks[id] or {}
  table.insert(key_event_callbacks[id], callback)
end
