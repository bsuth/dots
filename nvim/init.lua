-- -----------------------------------------------------------------------------
-- SETUP
-- -----------------------------------------------------------------------------

DOTS = os.getenv('DOTS')
package.path = package.path .. (';%s/nvim/?.lua'):format(DOTS)
nvim = vim.api

-- -----------------------------------------------------------------------------
-- MODULES
-- -----------------------------------------------------------------------------

local config = {
	'globals',
}

for i, path in ipairs(config) do
	local fd = io.open(path, 'r')
	if f ~= nil then
		io.close(f)
		require('__config/' .. path)
	end
end

require 'options'
require 'plugins'
require 'mappings'
require 'buffers'
