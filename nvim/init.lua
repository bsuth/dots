-- -----------------------------------------------------------------------------
-- SETUP
-- -----------------------------------------------------------------------------

DOTS = os.getenv('DOTS')
package.path = package.path .. (';%s/nvim/?.lua'):format(DOTS)
nvim = vim.api

-- -----------------------------------------------------------------------------
-- MODULES
-- -----------------------------------------------------------------------------

require '__config/globals'

require 'options'
require 'plugins'
require 'mappings'
require 'buffers'
