--
-- internal helpers
--

local function _join(t, sep)
  local joined = ''

  for k, v in ipairs(t) do
    joined = joined .. tostring(t[k]) .. (k == #t and '' or sep)
  end

  return joined
end

--
-- error handling functions
--

function typecheck(value, ...)
  local valuetype = type(value)

  for i, v in ipairs(arg) do
    if type(v) ~= 'string' then
      error('typecheck usage: expected types must be strings')
    end
  end

  for i, v in ipairs(arg) do
    if valuetype == v then
      return
    end
  end

  error(('expected %s, got %s'):format(
    '('.._join(arg, ', ')..')',
    valuetype
  ))
end

--
-- table functions
--

function join(t, sep)
  typecheck(t, 'table')
  typecheck(sep, 'string')
  _join(t, sep)
end

-- TODO: negative indices?
function slice(t, istart, iend)
  typecheck(istart, 'number')
  typecheck(iend, 'number')
  assert(istart <= iend)

  local sliced = {}

  for i = istart, iend do
    table.insert(sliced, t[i])
  end

  return sliced
end

--
-- string functions
--

function split(str, sep)
  typecheck(sep, 'string', 'nil')
  sep = type(sep) == 'string' and sep or '%s'

  local parts = {}

  for match in string.gmatch(str, "([^"..sep.."]+)") do
    table.insert(parts, match)
  end

  return parts
end

--
-- path functions
--

function dirname(path)
  local parts = split(path, '/')
  return join(slice(parts, 0, #parts - 1), '/')
end
