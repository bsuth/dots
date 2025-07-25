local M = {}

-- -----------------------------------------------------------------------------
-- Top Level
-- -----------------------------------------------------------------------------

local function _kpairs_iter(a, i)
  local key, value = i, nil

  repeat
    key, value = next(a, key)
  until type(key) ~= 'number'

  return key, value
end

---@generic V
---@param t table<string, V>
---@return fun(a: { [string]: V }, i?: string): string, V
---@return V
---@return nil
function M.kpairs(t)
  return _kpairs_iter, t, nil
end

---@param a unknown
---@param b unknown
---@return boolean
function M.compare(a, b)
  if type(a) ~= 'table' or type(b) ~= 'table' then
    return a == b
  end

  if a == b then
    return true
  end

  for key in pairs(a) do
    if b[key] == nil then
      return false
    end
  end

  for key in pairs(b) do
    if a[key] == nil then
      return false
    end
  end

  for key in pairs(a) do
    if not M.compare(a[key], b[key]) then
      return false
    end
  end

  return true
end

-- -----------------------------------------------------------------------------
-- Coroutine
-- -----------------------------------------------------------------------------

---@class coroutine: coroutinelib
local coroutine = setmetatable({}, { __index = coroutine })

-- -----------------------------------------------------------------------------
-- Debug
-- -----------------------------------------------------------------------------

---@class debug: debuglib
local debug = setmetatable({}, { __index = debug })

-- -----------------------------------------------------------------------------
-- IO
-- -----------------------------------------------------------------------------

---@class io: iolib
local io = setmetatable({}, { __index = io })

---@param path string
---@return boolean
function io.exists(path)
  local file = io.open(path, 'r')

  if file == nil then
    return false
  end

  file:close()

  return true
end

---@param path string
---@return string
function io.readfile(path)
  local file = assert(io.open(path, 'r'))
  local content = assert(file:read('*a'))
  file:close()
  return content
end

---@param path string
---@param content string
function io.writefile(path, content)
  local file = assert(io.open(path, 'w'))
  assert(file:write(content))
  file:close()
end

-- -----------------------------------------------------------------------------
-- Math
-- -----------------------------------------------------------------------------

---@class math: mathlib
local math = setmetatable({}, { __index = math })

---@param x number
---@param min number
---@param max number
---@return number
function math.clamp(x, min, max)
  return math.min(math.max(x, min), max)
end

---@param x number
---@return number
function math.round(x)
  if x < 0 then
    return math.ceil(x - 0.5)
  else
    return math.floor(x + 0.5)
  end
end

-- -----------------------------------------------------------------------------
-- OS
-- -----------------------------------------------------------------------------

---@class os: oslib
local os = setmetatable({}, { __index = os })

---@param cmd string
---@return string
function os.capture(cmd)
  local file = assert(io.popen(cmd, 'r'))
  local stdout = assert(file:read('*a'))
  file:close()
  return stdout
end

-- -----------------------------------------------------------------------------
-- Package
-- -----------------------------------------------------------------------------

-- EMPTY
---@class package: packagelib
local package = setmetatable({}, { __index = package })

-- -----------------------------------------------------------------------------
-- String
-- -----------------------------------------------------------------------------

---@class string: stringlib
local string = setmetatable({}, { __index = string })

local function _string_chars_iter(a, i)
  i = i + 1
  local char = a:sub(i, i)
  if char ~= '' then
    return i, char
  end
end

---@param s string
---@return fun(a: string, i?: number): number, string
---@return string
---@return number
function string.chars(s)
  return _string_chars_iter, s, 0
end

---@param s string
---@return string
function string.escape(s)
  -- Wrap in parentheses to ensure we return only 1 value.
  return (s:gsub('[().%%+%-*?[^$]', '%%%1'))
end

---@param s string
---@param separator? string
---@return string[]
function string.split(s, separator)
  separator = separator or '%s+'

  local result = {}
  local i, j = s:find(separator)

  while i ~= nil do
    table.insert(result, s:sub(1, i - 1))
    s = s:sub(j + 1) or ''
    i, j = s:find(separator)
  end

  table.insert(result, s)
  return result
end

---@param s string
---@param pattern? string
---@return string
function string.trim(s, pattern)
  pattern = pattern or '%s+'
  -- Wrap in parentheses to ensure we return only 1 value.
  return (s:gsub('^' .. pattern, ''):gsub(pattern .. '$', ''))
end

-- -----------------------------------------------------------------------------
-- Table
-- -----------------------------------------------------------------------------

---@class table: tablelib
local table = setmetatable({}, { __index = table })

-- Polyfill `table.pack` and `table.unpack`
if _VERSION == 'Lua 5.1' then
  ---@diagnostic disable-next-line: duplicate-set-field
  table.pack = function(...) return { n = select('#', ...), ... } end
  ---@diagnostic disable-next-line: deprecated
  table.unpack = unpack
end

---@param t table
---@param ... table
function table.assign(t, ...)
  for _, _t in pairs({ ... }) do
    for key, value in pairs(_t) do
      if type(key) == 'number' then
        table.insert(t, value)
      else
        t[key] = value
      end
    end
  end
end

---@generic K, V
---@param t table<K, V>
---@param condition V | fun(value: V, key: K): boolean
function table.clear(t, condition)
  if type(condition) == 'function' then
    for key, value in M.kpairs(t) do
      if condition(value, key) then
        t[key] = nil
      end
    end

    for i = #t, 1, -1 do
      if condition(t[i], i) then
        table.remove(t, i)
      end
    end
  else
    for key, value in M.kpairs(t) do
      if value == condition then
        t[key] = nil
      end
    end

    for i = #t, 1, -1 do
      if t[i] == condition then
        table.remove(t, i)
      end
    end
  end
end

---@param iterator fun(): unknown, unknown | nil
---@param ... unknown
---@return table
function table.collect(iterator, ...)
  local result = {}

  for key, value in iterator, ... do
    if value == nil then
      table.insert(result, key)
    else
      result[key] = value
    end
  end

  return result
end

---@generic K, V
---@param t table<K, V>
---@return table<K, V>
function table.deepcopy(t)
  local result = {}

  for key, value in pairs(t) do
    if type(value) == 'table' then
      result[key] = table.deepcopy(value)
    else
      result[key] = value
    end
  end

  return result
end

---@generic K, V
---@param t table<K, V>
---@param callback fun(value: V, key: K): boolean
---@return table<K, V>
function table.filter(t, callback)
  local result = {}

  for key, value in pairs(t) do
    if callback(value, key) then
      if type(key) == 'number' then
        table.insert(result, value)
      else
        result[key] = value
      end
    end
  end

  return result
end

---@generic K, V
---@param t table<K, V>
---@param condition V | fun(value: V, key: K): boolean
---@return V | nil
---@return K | nil
function table.find(t, condition)
  if type(condition) == 'function' then
    for key, value in pairs(t) do
      if condition(value, key) then
        return value, key
      end
    end
  else
    for key, value in pairs(t) do
      if value == condition then
        return value, key
      end
    end
  end
end

---@generic K, V
---@param t table<K, V>
---@param condition V | fun(value: V, key: K): boolean
---@return boolean
function table.has(t, condition)
  local _, key = table.find(t, condition)
  return key ~= nil
end

---@generic K
---@param t table<K>
---@return K[]
function table.keys(t)
  local result = {}

  for key in pairs(t) do
    table.insert(result, key)
  end

  return result
end

---@generic K, V, nK, nV
---@param t table<K, V>
---@param callback fun(value: V, key: K): unknown, unknown | nil
---@return table
function table.map(t, callback)
  local result = {}

  for key, value in pairs(t) do
    local newValue, newKey = callback(value, key)

    if newKey ~= nil then
      result[newKey] = newValue
    elseif type(key) == 'number' then
      table.insert(result, newValue)
    else
      result[key] = newValue
    end
  end

  return result
end

---@param ... table
---@return table
function table.merge(...)
  local result = {}
  table.assign(result, ...)
  return result
end

---@generic K, V, I, R
---@param t table<K, V>
---@param initial I
---@param callback fun(result: I | R, value: V, key: K): R
---@return I | R
function table.reduce(t, initial, callback)
  local result = initial

  for key, value in pairs(t) do
    result = callback(result, value, key)
  end

  return result
end

---@param t table
function table.reverse(t)
  local len = #t

  for i = 1, math.floor(len / 2) do
    t[i], t[len - i + 1] = t[len - i + 1], t[i]
  end
end

---@generic K, V
---@param t table<K, V>
---@return table<K, V>
function table.shallowcopy(t)
  local result = {}

  for key, value in pairs(t) do
    result[key] = value
  end

  return result
end

---@generic V
---@param t V[]
---@return V[]
function table.slice(t, i, j)
  local len = #t

  i = i or 1
  j = j or len

  local result = {}

  if i < 0 then i = i + len + 1 end
  if j < 0 then j = j + len + 1 end

  for k = math.max(i, 1), math.min(j, len) do
    table.insert(result, t[k])
  end

  return result
end

---@generic K, V
---@param t table<K, V>
---@return V[]
function table.values(t)
  local result = {}

  for _, value in pairs(t) do
    table.insert(result, value)
  end

  return result
end

-- -----------------------------------------------------------------------------
-- Return
--
-- Note: Libraries are declared as standalone tables and then injected here in
-- order to get proper `@class` annotations from LuaCATS.
-- -----------------------------------------------------------------------------

M.coroutine = coroutine
M.debug = debug
M.io = io
M.math = math
M.os = os
M.package = package
M.string = string
M.table = table

return M
