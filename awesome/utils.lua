local _ = {}

function _.default(t, defaults)
  local _t = {}

  for k, v in pairs(defaults) do
    _t[k] = v
  end

  if type(t) == 'table' then
    for k, v in pairs(t) do
      _t[k] = v
    end
  end

  return _t
end

function _.filter(t, f)
  local _t = {}

  for k, v in pairs(t) do
    if f(v, k) then
      _t[k] = v
    end
  end

  return _t 
end

function _.map(t, f, iter)
  local _t = {}

  for k, v in (iter or pairs)(t) do
    local _v, _k = f(v, k)
    _k = _k ~= nil and _k or k
    _t[_k] = _v
  end

  return _t
end

function _.merge(T)
  local _t = {}

  for _, t in ipairs(T) do
    for k, v in pairs(t) do
      _t[k] = v
    end
  end

  return _t
end

function _.range(n)
  local _t = {}

  for i = 1, n do
    table.insert(_t, i)
  end

  return _t
end

function _.reduce(t, f, r)
  for k, v in pairs(t) do
    r = reducer(r, v, k)
  end

  return r 
end

return _
