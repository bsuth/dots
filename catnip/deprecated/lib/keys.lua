local M = {}

-- -----------------------------------------------------------------------------
-- Types
-- -----------------------------------------------------------------------------

---@alias Modifier "ctrl" | "mod1" | "mod2" | "mod3" | "mod4" | "mod5"

-- -----------------------------------------------------------------------------
-- API
-- -----------------------------------------------------------------------------

---@param modifiers Modifier[]
---@param key string
---@return string
function M.serialize_key_combination(modifiers, key)
  local serial = { 0, 0, 0, 0, 0, 0, key }

  for _, modifier in ipairs(modifiers) do
    if modifier == 'ctrl' then
      serial[1] = 1
    elseif modifier == 'mod1' then
      serial[2] = 1
    elseif modifier == 'mod2' then
      serial[3] = 1
    elseif modifier == 'mod3' then
      serial[4] = 1
    elseif modifier == 'mod4' then
      serial[5] = 1
    elseif modifier == 'mod5' then
      serial[6] = 1
    end
  end

  return table.concat(serial)
end

---@param event CatnipKeyEvent
---@return string[]
function M.serialize_key_event(event)
  local flags = table.concat({
    event.ctrl and 1 or 0,
    event.mod1 and 1 or 0,
    event.mod2 and 1 or 0,
    event.mod3 and 1 or 0,
    event.mod4 and 1 or 0,
    event.mod5 and 1 or 0,
  })

  local key_event_serials = { flags .. event.name }

  if event.char ~= nil then
    table.insert(key_event_serials, flags .. event.char)
  end

  return key_event_serials
end

---@param event CatnipKeyEvent
function M.key_event_has_modifiers(event)
  return event.ctrl or event.mod1 or event.mod2 or event.mod3 or event.mod4 or event.mod5
end

---@param serials string[]
---@param modifiers Modifier[]
---@param key string
---@return boolean
function M.match(serials, modifiers, key)
  local key_combination_serial = M.serialize_key_combination(modifiers, key)

  for _, serial in ipairs(serials) do
    if serial == key_combination_serial then
      return true
    end
  end

  return false
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return M
