local C = require('constants')
local path = require('lib.path')
local plugins = require('lib.plugins')

-- -----------------------------------------------------------------------------
-- Erde
-- -----------------------------------------------------------------------------

plugins.use(path.join(C.HOME, 'repos/vim-erde'), { symlink = true })
