local catnip = require('catnip')
local keys = require('lib.keys')

local M = {}

local key_press_callbacks = {} ---@type table<string, fun()[]>
local key_release_callbacks = {} ---@type table<string, fun()[]>

-- -----------------------------------------------------------------------------
-- API
-- -----------------------------------------------------------------------------

---@param modifiers Modifier[]
---@param key string
---@param callback fun()
function M.press(modifiers, key, callback)
  local key_combination_serial = keys.serialize_key_combination(modifiers, key)
  key_press_callbacks[key_combination_serial] = key_press_callbacks[key_combination_serial] or {}
  table.insert(key_press_callbacks[key_combination_serial], callback)
end

---@param modifiers Modifier[]
---@param key string
---@param callback fun()
function M.release(modifiers, key, callback)
  local key_combination_serial = keys.serialize_key_combination(modifiers, key)
  key_release_callbacks[key_combination_serial] = key_release_callbacks[key_combination_serial] or {}
  table.insert(key_release_callbacks[key_combination_serial], callback)
end

-- -----------------------------------------------------------------------------
-- Subscriptions
-- -----------------------------------------------------------------------------

catnip.keyboards:subscribe('keypress', function(_, event)
  local key_event_serials = keys.serialize_key_event(event)

  for _, key_event_serial in ipairs(key_event_serials) do
    event.propagate = event.propagate
        and key_press_callbacks[key_event_serial] == nil
        and key_release_callbacks[key_event_serial] == nil

    if key_press_callbacks[key_event_serial] ~= nil then
      for _, callback in ipairs(key_press_callbacks[key_event_serial]) do
        callback()
      end
    end
  end
end)

catnip.keyboards:subscribe('keyrelease', function(_, event)
  local key_event_serials = keys.serialize_key_event(event)

  for _, key_event_serial in ipairs(key_event_serials) do
    event.propagate = event.propagate
        and key_press_callbacks[key_event_serial] == nil
        and key_release_callbacks[key_event_serial] == nil

    if key_release_callbacks[key_event_serial] ~= nil then
      for _, callback in ipairs(key_release_callbacks[key_event_serial]) do
        callback()
      end
    end
  end
end)

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return M
