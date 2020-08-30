-- -----------------------------------------------------------------------------
-- SETUP
-- -----------------------------------------------------------------------------

DOTS = os.getenv('DOTS')
package.path = package.path .. (';%s/nvim/?.lua'):format(DOTS)
package.path = package.path .. (';%s/config/live/nvim/?.lua'):format(DOTS)
nvim = vim.api

-- -----------------------------------------------------------------------------
-- WORKSTATION CONFIG
-- -----------------------------------------------------------------------------

local f = io.open(DOTS .. '/config/live/nvim/config.lua', 'r')

if f ~= nil then
	require 'config'
	f:close()
end

-- -----------------------------------------------------------------------------
-- MODULES
-- -----------------------------------------------------------------------------

require 'options'
require 'plugins'
require 'mappings'
require 'buffers'
