local function default(t, tdefaults)
  local defaulted = {}

  for k, v in pairs(tdefaults) do
    defaulted[k] = v
  end

  if type(t) == 'table' then
    for k, v in pairs(t) do
      defaulted[k] = v
    end
  end

  return defaulted
end

local function merge(ts)
  local merged = {}

  for _, t in ipairs(ts) do
    for k, v in pairs(t) do
      merged[k] = v
    end
  end

  return merged
end

local function map(t, mapper, iter)
  local mapped = {}

  for k, v in (iter or pairs)(t) do
    local _v, _k = mapper(v, k)
    _k = _k ~= nil and _k or k
    mapped[_k] = _v
  end

  return mapped
end

local function filter(t, filterer)
  local filtered = {}

  for k, v in pairs(t) do
    if filterer(v, k) then
      filtered[k] = v
    end
  end

  return filtered
end

local function reduce(t, reducer, reduction)
  for k, v in pairs(t) do
    reduction = reducer(reduction, v, k)
  end

  return reduction
end

local function range(n)
  local sequence = {}

  for i = 1, n do
    table.insert(sequence, i)
  end

  return sequence
end

return {
  default = default,
  merge = merge,
  map = map,
  filter = filter,
  reduce = reduce,
  range = range,
}
