local function dirvish_open()
  local filename = nvim_call_function('expand', '<cWORD>')
  local dir = dirname(filename)
end
