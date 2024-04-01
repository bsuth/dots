local active_effect = nil
local effect_to_dependencies = setmetatable({}, { __mode = 'k' })

local M = {}

function M.track(effect, callback)
  callback = callback or effect

  if effect_to_dependencies[effect] then
    for dependency in pairs(effect_to_dependencies[effect]) do
      dependency[effect] = nil
    end
  end

  active_effect = effect
  callback()
  active_effect = nil
end

function M.create(initial_value)
  local t = type(initial_value) == 'table'
    and initial_value
    or { value = initial_value }

  local key_dependent_effects = {}

  --- @param key string
  local function __index(_, key)
    local is_raw = key:sub(1, 1) == '_'
    key = is_raw and key:sub(2) or key

    if not is_raw and active_effect ~= nil then
      if key_dependent_effects[key] == nil then
        key_dependent_effects[key] = setmetatable({}, { __mode = 'k' })
      end

      local dependent_effects = key_dependent_effects[key]
      dependent_effects[active_effect] = true

      if effect_to_dependencies[active_effect] == nil then
        effect_to_dependencies[active_effect] = setmetatable({}, { __mode = 'k' })
      end

      effect_to_dependencies[active_effect][dependent_effects] = true
    end

    return t[key]
  end

  --- @param key string
  --- @param value unknown
  local function __newindex(_, key, value)
    local is_raw = key:sub(1, 1) == '_'
    key = is_raw and key:sub(2) or key

    if t[key] == value then
      return
    end

    t[key] = value

    if not is_raw then
      for effect in pairs(key_dependent_effects[key]) do
        effect()
      end
    end
  end

  return setmetatable({}, {
    __index = __index,
    __newindex = __newindex,
  })
end

function M.compute(callback)
  local computed = M.create({})
  local is_value_outdated = true

  local function update()
    computed.value = callback()
  end

  local function effect()
    is_value_outdated = true
  end

  return function()
    if is_value_outdated then
      M.track(effect, update)
      is_value_outdated = false
    end

    return value
  end
end

-- TODO: allow manually specifying dependencies
--- @param callback fun(): nil | fun()
function M.watch(callback)
  local cleanup = nil --- @type nil | fun()

  local function on_change()
    if cleanup ~= nil then
      cleanup()
    end

    cleanup = track(callback, on_change)
  end

  -- TODO: manually register dependencies
  on_change()

  return function()
    -- TODO: cleanup dependencies
    if cleanup ~= nil then
      cleanup()
    end
  end
end

function M.batch(callback)
end

-- -----------------------------------------------------------------------------
-- DEV PLAYGROUND
--
-- TODO: REMOVE ME
-- -----------------------------------------------------------------------------

local x = M.create(4)
local watch_counter = 0

M.watch(function()
  local _ = x.value
  watch_counter = watch_counter + 1
end)

assert(x.value == 4)
x.value = 34
assert(x.value == 34)

local y = M.compute(function()
  return x.value + 1
end)

assert(x.value == 34)
assert(y.value == 35)
x.value = 99
assert(y.value == 100)

assert(watch_counter == 3)
