local function join(t, sep)
  local joined = ''

  for k, v in ipairs(t) do
    joined = joined .. tostring(t[k]) .. (k == #t and '' or sep)
  end

  return joined
end
