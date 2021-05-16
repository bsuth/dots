local unsafe = require '_unsafe'
local typecheck = require 'typecheck'

local Array = {}

function Array.join(t, sep)
  typecheck(t, 'table')
  typecheck(sep, 'string')
  unsafe.join(t, sep)
end

-- -- TODO: negative indices?
function Array.slice(t, istart, iend)
  typecheck(istart, 'number')
  typecheck(iend, 'number')
  assert(istart <= iend)

  local sliced = {}

  for i = istart, iend do
    table.insert(sliced, t[i])
  end

  return sliced
end

return setmetatable(Array, {
  __call = function(self, t)
    typecheck(t, 'table')

    return setmetatable({}, {
      __index = function(self, k)
        if type(k) == 'number' then
          if k > #self - 1 or k < -(#self - 1) then
            error('out of bounds access: '..tostring(k))
          elseif k < 0 then
            k = k + #self - 1
          end

          return self[k]
        else
          return Array[k]
        end
      end,
    })
  end,
})
