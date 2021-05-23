--
-- lua env
-- 1) expose vim.api to global scope
-- 2) expose global helper functions
--

for k, v in pairs(vim.api) do
  if type(v) == 'function' and k:match('^nvim_') then
    _G[k] = v
  end
end

function nvim_cword()
  return nvim_call_function('expand', { '<cword>' })
end

function nvim_cWORD()
  return nvim_call_function('expand', { '<cWORD>' })
end

--
-- packages
--

local packages = {
  'plugins',
  'options',
  'helpers',
  'autocommands',
  'mappings',
}

for _, v in ipairs(packages) do
  package.loaded[v] = nil
  require(v)
end
