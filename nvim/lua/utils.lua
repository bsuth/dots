-- -----------------------------------------------------------------------------
-- Module
-- -----------------------------------------------------------------------------

local _ = {}

-- -----------------------------------------------------------------------------
-- Iterators
-- -----------------------------------------------------------------------------

function _.pairs(t)
  return pairs(t)
end

function _.kpairs(t)
  -- TODO
  return ipairs(t)
end

function _.ipairs(t)
  return ipairs(t)
end

-- -----------------------------------------------------------------------------
-- ipairs
-- -----------------------------------------------------------------------------

function _.insert(t, idx, ...)
  local varargs = { ... }

  if #varargs == 0 then
    varargs = { idx }
    idx = #t + 1
  else
    idx = idx < 0 and idx + #t + 1 or idx
  end

  for i, v in ipairs(varargs) do
    table.insert(t, idx + (i - 1), v)
  end

  return t
end

function _.remove(t, idx, n)
  local removed = {}

  idx = idx and (idx < 0 and idx + #t + 1 or idx) or #t
  n = n or 1

  for i = 1, n do
    _.insert(removed, table.remove(t, idx))
  end

  return unpack(removed)
end

function _.join(t, sep)
  sep = sep or ''
  local joined = ''

  for i, v in _.ipairs(t) do
    joined = joined .. tostring(v) .. (i < #t and sep or '')
  end

  return joined
end

function _.slice(t, istart, iend)
  local sliced = {}

  istart = istart < 0 and istart + #t + 1 or istart
  iend = iend and (iend < 0 and iend + #t + 1 or iend) or #t

  for i = istart, iend do
    _.insert(sliced, t[i])
  end

  return sliced
end

-- -----------------------------------------------------------------------------
-- kpairs
-- -----------------------------------------------------------------------------

function _.keys(t)
  -- TODO
end

function _.values(t)
  -- TODO
end

-- -----------------------------------------------------------------------------
-- pairs
-- -----------------------------------------------------------------------------

function _.each(t, f, iter)
  iter = iter or pairs

  for a, v in iter(t) do
    f(v, a)
  end
end

function _.map(t, f, iter)
  iter = iter or pairs
  local mapped = {}

  for a, v in iter(t) do
    local mapV, mapA = f(v, a)

    if mapA == nil then
      mapA = type(a) == 'number' and #mapped or a
    end

    mapped[mapA] = mapV
  end

  return mapped
end

function _.filter(t, f, iter)
  iter = iter or pairs
  local filtered = {}

  for a, v in iter(t) do
    if f(v, a) then
      filtered[type(a) == 'number' and #filtered or a] = v
    end
  end

  return filtered
end

function _.reduce(t, f, accumulator, iter)
  iter = iter or pairs

  for a, v in iter(t) do
    accumulator = f(accumulator, v, a)
  end

  return accumulator
end

function _.find(t, f, iter)
  iter = iter or pairs

  for a, v in iter(t) do
    if f(v, a) then
      return v, a
    end
  end

  return nil, nil
end

-- -----------------------------------------------------------------------------
-- Strings
-- -----------------------------------------------------------------------------

function _.split(s, sep)
  sep = sep or '%s'
  local parts = {}

  for match in s:gmatch('([^' .. sep .. ']+)') do
    table.insert(parts, match)
  end

  return parts
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return _
