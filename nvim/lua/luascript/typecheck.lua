local unsafe = require '_unsafe'

return setmetatable({}, {
  __call = function(self, value, ...)
    local validtypes = {...}
    local valuetype = type(value)

    for i, v in ipairs(validtypes) do
      if type(v) ~= 'string' then
        error('typecheck usage: expected types must be strings')
      end
    end

    for i, v in ipairs(validtypes) do
      if valuetype == v then
        return
      end
    end

    error(('expected %s, got %s'):format(
      '('..unsafe.join(validtypes, ', ')..')',
      valuetype
    ))
  end,
})
