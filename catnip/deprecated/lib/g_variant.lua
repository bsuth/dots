local ffi = require('ffi')
local glib = require('ffi.glib')

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

---@param g_variant_type ffi.cdata*
---@return string
local function g_variant_type_string(g_variant_type)
  return ffi.string(
    glib.g_variant_type_peek_string(g_variant_type),
    glib.g_variant_type_get_string_length(g_variant_type)
  )
end

---@param g_variant_type ffi.cdata*
---@return ffi.cdata*
local function g_variant_from_type(g_variant_type, ...)
  return glib.g_variant_new(g_variant_type_string(g_variant_type), ...)
end

-- -----------------------------------------------------------------------------
-- Lua -> GVariant
-- -----------------------------------------------------------------------------

-- Forward declared
local g_variant_from_lua

---@param g_variant_type ffi.cdata*
---@param value unknown
---@return ffi.cdata*
local function g_variant_basic_from_lua(g_variant_type, value)
  local type_string = g_variant_type_string(g_variant_type)

  -- NOTE: Favor dedicated constructors for basic types over the generic
  -- `g_variant_new`, since FFI may not be able to properly convert types for
  -- varargs (specifically, all of the varying number types)

  if type_string == 'b' then
    return glib.g_variant_new_boolean(value)
  elseif type_string == 'y' then
    return glib.g_variant_new_byte(value)
  elseif type_string == 'n' then
    return glib.g_variant_new_int16(value)
  elseif type_string == 'q' then
    return glib.g_variant_new_uint16(value)
  elseif type_string == 'i' then
    return glib.g_variant_new_int32(value)
  elseif type_string == 'u' then
    return glib.g_variant_new_uint32(value)
  elseif type_string == 'x' then
    return glib.g_variant_new_int64(value)
  elseif type_string == 't' then
    return glib.g_variant_new_uint64(value)
  elseif type_string == 'd' then
    return glib.g_variant_new_double(value)
  elseif type_string == 's' then
    return glib.g_variant_new_string(value)
  elseif type_string == 'o' then
    return glib.g_variant_new_object_path(value)
  elseif type_string == 'g' then
    return glib.g_variant_new_signature(value)
  else
    error(("unknown basic variant type '%s'"):format(type_string))
  end
end

---@param g_variant_type ffi.cdata*
---@param value unknown | nil
---@return ffi.cdata*
local function g_variant_maybe_from_lua(g_variant_type, value)
  return value == nil
      and g_variant_from_type(g_variant_type, nil)
      or g_variant_from_lua(glib.g_variant_type_element(g_variant_type), value)
end

---@param g_variant_type ffi.cdata*
---@param value unknown[]
---@return ffi.cdata*
local function g_variant_tuple_from_lua(g_variant_type, value)
  -- NOTE: GVariantBuilder does not seem to work properly for tuples (perhaps
  -- due to the LuaJIT FFI?), so instead we convert all children to variants and
  -- use the generic `g_variant_new`, prefixing all subtypes with `@` so we can
  -- properly extract the variant values.

  local children = {}
  local child_type_strings = {}
  local child_variant_type = glib.g_variant_type_first(g_variant_type)

  for i = 1, tonumber(glib.g_variant_type_n_items(g_variant_type)) do
    table.insert(children, g_variant_from_lua(child_variant_type, value[i]))
    table.insert(child_type_strings, '@' .. g_variant_type_string(child_variant_type))
    child_variant_type = glib.g_variant_type_next(child_variant_type)
  end

  return glib.g_variant_new('(' .. table.concat(child_type_strings) .. ')', unpack(children))
end

---@param g_variant_type ffi.cdata*
---@param value table
---@return ffi.cdata*
local function g_variant_array_from_lua(g_variant_type, value)
  local children = glib.g_variant_builder_new(g_variant_type)
  local child_variant_type = glib.g_variant_type_element(g_variant_type)

  if glib.g_variant_type_is_dict_entry(child_variant_type) == 0 then
    for _, child_value in ipairs(value) do
      glib.g_variant_builder_add_value(children, g_variant_from_lua(child_variant_type, child_value))
    end
  else
    local dict_key_variant_type = glib.g_variant_type_key(child_variant_type)
    local dict_value_variant_type = glib.g_variant_type_value(child_variant_type)

    for dict_key, dict_value in pairs(value) do
      glib.g_variant_builder_add_value(children, glib.g_variant_new_dict_entry(
        g_variant_from_lua(dict_key_variant_type, dict_key),
        g_variant_from_lua(dict_value_variant_type, dict_value)
      ))
    end
  end

  local variant = g_variant_from_type(g_variant_type, children)
  glib.g_variant_builder_unref(children)

  return variant
end

---@param g_variant_type ffi.cdata* | string
---@param value unknown
---@return ffi.cdata*
function g_variant_from_lua(g_variant_type, value)
  if type(g_variant_type) == 'string' then
    g_variant_type = glib.g_variant_type_new(g_variant_type)
    local g_variant = g_variant_from_lua(g_variant_type, value)
    glib.g_variant_type_free(g_variant_type)
    glib.g_variant_ref_sink(g_variant)
    return ffi.gc(g_variant, glib.g_variant_unref)
  elseif glib.g_variant_type_is_maybe(g_variant_type) == 1 then
    return g_variant_maybe_from_lua(g_variant_type, value)
  elseif glib.g_variant_type_is_array(g_variant_type) == 1 then
    return g_variant_array_from_lua(g_variant_type, value)
  elseif glib.g_variant_type_is_tuple(g_variant_type) == 1 then
    return g_variant_tuple_from_lua(g_variant_type, value)
  else
    return g_variant_basic_from_lua(g_variant_type, value)
  end
end

-- -----------------------------------------------------------------------------
-- GVariant -> Lua
-- -----------------------------------------------------------------------------

-- Forward declared
local g_variant_to_lua

---@param g_variant ffi.cdata*
---@return any
local function g_variant_basic_to_lua(g_variant)
  local g_variant_type = glib.g_variant_get_type(g_variant)
  local type_string = g_variant_type_string(g_variant_type)

  if type_string == 'b' then
    return glib.g_variant_get_boolean(g_variant) ~= 0
  elseif type_string == 'y' then
    return tonumber(glib.g_variant_get_byte(g_variant))
  elseif type_string == 'n' then
    return glib.g_variant_get_int16(g_variant)
  elseif type_string == 'q' then
    return glib.g_variant_get_uint16(g_variant)
  elseif type_string == 'i' then
    return glib.g_variant_get_int32(g_variant)
  elseif type_string == 'u' then
    return glib.g_variant_get_uint32(g_variant)
  elseif type_string == 'x' then
    return tonumber(glib.g_variant_get_int64(g_variant))
  elseif type_string == 't' then
    return tonumber(glib.g_variant_get_uint64(g_variant))
  elseif type_string == 'd' then
    return glib.g_variant_get_double(g_variant)
  elseif type_string == 's' or type_string == 'o' or type_string == 'g' then
    return ffi.string(glib.g_variant_get_string(g_variant, nil))
  else
    error(("unknown basic variant type '%s'"):format(type_string))
  end
end

---@param g_variant ffi.cdata*
---@return any | nil
local function g_variant_maybe_to_lua(g_variant)
  local value = glib.g_variant_get_maybe(g_variant)

  if value == nil then
    return nil
  end

  return g_variant_to_lua(value)
end

---@param g_variant ffi.cdata*
---@return any[]
local function g_variant_tuple_to_lua(g_variant)
  local children = {}

  for i = 1, tonumber(glib.g_variant_n_children(g_variant)) do
    table.insert(children, g_variant_to_lua(glib.g_variant_get_child_value(g_variant, i - 1)))
  end

  return children
end

---@param g_variant ffi.cdata*
---@return table
local function g_variant_array_to_lua(g_variant)
  local children = {}
  local g_variant_type = glib.g_variant_get_type(g_variant)
  local child_variant_type = glib.g_variant_type_element(g_variant_type)
  local num_children = tonumber(glib.g_variant_n_children(g_variant))

  if glib.g_variant_type_is_dict_entry(child_variant_type) == 0 then
    for i = 1, num_children do
      table.insert(children, g_variant_to_lua(glib.g_variant_get_child_value(g_variant, i - 1)))
    end
  else
    for i = 1, num_children do
      local tuple = glib.g_variant_get_child_value(g_variant, i - 1)
      local dict_key = g_variant_to_lua(glib.g_variant_get_child_value(tuple, 0))
      local dict_value = g_variant_to_lua(glib.g_variant_get_child_value(tuple, 1))
      children[dict_key] = dict_value
    end
  end

  return children
end

---@param g_variant ffi.cdata*
---@return any
function g_variant_to_lua(g_variant)
  local g_variant_type = glib.g_variant_get_type(g_variant)

  if glib.g_variant_type_is_maybe(g_variant_type) == 1 then
    return g_variant_maybe_to_lua(g_variant)
  elseif glib.g_variant_type_is_array(g_variant_type) == 1 then
    return g_variant_array_to_lua(g_variant)
  elseif glib.g_variant_type_is_tuple(g_variant_type) == 1 then
    return g_variant_tuple_to_lua(g_variant)
  elseif glib.g_variant_type_is_tuple(g_variant_type) == 1 then
    return g_variant_tuple_to_lua(g_variant)
  elseif glib.g_variant_type_is_variant(g_variant_type) == 1 then
    return g_variant_to_lua(glib.g_variant_get_variant(g_variant))
  else
    return g_variant_basic_to_lua(g_variant)
  end
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return {
  from_lua = g_variant_from_lua,
  to_lua = g_variant_to_lua,
}
