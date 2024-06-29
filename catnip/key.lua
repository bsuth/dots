local catnip = require('catnip')

---@alias Modifier "ctrl" | "mod1" | "mod2" | "mod3" | "mod4" | "mod5"

local M = {}

local key_press_callbacks = {} ---@type table<string, fun()[]>
local key_release_callbacks = {} ---@type table<string, fun()[]>

---@param modifiers Modifier[]
---@param key string
---@return string
local function get_key_binding_code(modifiers, key)
  local code = { 0, 0, 0, 0, 0, 0, key }

  for _, modifier in ipairs(modifiers) do
    if modifier == 'ctrl' then
      code[1] = 1
    elseif modifier == 'mod1' then
      code[2] = 1
    elseif modifier == 'mod2' then
      code[3] = 1
    elseif modifier == 'mod3' then
      code[4] = 1
    elseif modifier == 'mod4' then
      code[5] = 1
    elseif modifier == 'mod5' then
      code[6] = 1
    end
  end

  return table.concat(code)
end

---@param event CatnipKeyEvent
---@return string
local function get_key_event_code(event)
  local is_printable_ascii = 32 < event.code and event.code < 127

  return table.concat({
    event.ctrl and 1 or 0,
    event.mod1 and 1 or 0,
    event.mod2 and 1 or 0,
    event.mod3 and 1 or 0,
    event.mod4 and 1 or 0,
    event.mod5 and 1 or 0,
    is_printable_ascii and string.char(event.code) or event.name,
  })
end

---@param modifiers Modifier[]
---@param key string
---@param callback fun()
function M.press(modifiers, key, callback)
  local code = get_key_binding_code(modifiers, key)
  key_press_callbacks[code] = key_press_callbacks[code] or {}
  table.insert(key_press_callbacks[code], callback)
end

---@param modifiers Modifier[]
---@param key string
---@param callback fun()
function M.release(modifiers, key, callback)
  local code = get_key_binding_code(modifiers, key)
  key_release_callbacks[code] = key_release_callbacks[code] or {}
  table.insert(key_release_callbacks[code], callback)
end

catnip.subscribe('keyboard::keypress', function(_, event)
  local code = get_key_event_code(event)

  event.prevent_notify = key_press_callbacks[code] ~= nil or key_release_callbacks[code] ~= nil

  if key_press_callbacks[code] ~= nil then
    for _, callback in ipairs(key_press_callbacks[code]) do
      callback()
    end
  end
end)

catnip.subscribe('keyboard::keyrelease', function(_, event)
  local code = get_key_event_code(event)

  event.prevent_notify = key_press_callbacks[code] ~= nil or key_release_callbacks[code] ~= nil

  if key_release_callbacks[code] ~= nil then
    for _, callback in ipairs(key_release_callbacks[code]) do
      callback()
    end
  end
end)

return M
