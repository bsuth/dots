-- -----------------------------------------------------------------------------
-- SETUP
-- -----------------------------------------------------------------------------

DOTS = os.getenv('DOTS')
package.path = package.path .. (';%s/nvim/?.lua'):format(DOTS)
nvim = vim.api

-- -----------------------------------------------------------------------------
-- CONFIG
-- -----------------------------------------------------------------------------

local config = {
	'globals',
}

local missing_configs = {}

for _, path in ipairs(config) do
	if not pcall(require, '__config/' .. path) then
		table.insert(missing_configs, path)
	end
end

if #missing_configs > 0 then
	local msg = 'Missing Config Files:'

	for _, path in ipairs(missing_configs) do
		msg = ('%s\n%s'):format(msg, path)
	end

	nvim.nvim_call_function('confirm', { msg, '&confirm', 1 })
end

-- -----------------------------------------------------------------------------
-- MODULES
-- -----------------------------------------------------------------------------

require 'options'
require 'plugins'
require 'mappings'
require 'buffers'
