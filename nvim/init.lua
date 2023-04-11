-- When resolving modules, neovim looks for 'lua/?.lua;lua/?/init.lua' for all
-- paths in `runtimepath`. However, since package managers often manipulate this
-- value at runtime, neovim opts to provide a custom package loader instead of
-- manipulating package.path in order to always get the correct `runtimepath`
-- value _at require time_.
--
-- This causes some problems (such as erde not being able to find our neovim
-- modules), so we adjust package.path for our neovim modules manually.
--
-- @see https://github.com/neovim/neovim/blob/master/runtime/lua/vim/_init_packages.lua
local nvim_package_path = os.getenv('DOTS') .. '/nvim'

if not package.path:find(nvim_package_path) then
  package.path = ('%s/?.lua;%s/?/init.lua;%s'):format(nvim_package_path, nvim_package_path, package.path)
end

local erde = require('erde')
erde.load()

package.loaded.rc = nil -- force reload rc
local ok, result = xpcall(function() require('rc') end, erde.rewrite)
if not ok then error(result) end
