-- Expose all nvim api functions to global scope
for k, v in pairs(vim.api) do
  if type(v) == 'function' and k:match('^nvim_') then
    _G[k] = v
  end
end

require('luascript').expose()
require 'plugins'
require 'options'
require 'autocommands'
require 'mappings'
