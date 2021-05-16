-- Expose all nvim api functions to global scope
for k, v in pairs(vim.api) do
  if type(v) == 'function' and k:match('^nvim_') then
    _G[k] = v
  end
end

package.loaded.plugins = nil
package.loaded.options = nil
package.loaded.autocommands = nil
package.loaded.mappings= nil

require('luascript').expose()
require 'plugins'
require 'options'
require 'autocommands'
require 'mappings'
