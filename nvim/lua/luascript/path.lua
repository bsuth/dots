local typecheck = require 'typecheck'

local path = {
  separator = '/',
}

function path.dirname(path)
  typecheck(path, 'string')

  local parts = split(path, '/')
  return join(slice(parts, 0, #parts - 1), '/')
end

function path.basename(path)
  typecheck(path, 'string')

  local parts = split(path, '/')
  return parts[#parts]
end

function path.ext(path)
  typecheck(path, 'string')

  local basename = basename(path)
end

return path
