local C = require('constants')
local path = require('utils.path')
local plugins = require('utils.plugins')

-- -----------------------------------------------------------------------------
-- Erde
-- -----------------------------------------------------------------------------

plugins.use(path.join(C.HOME, 'repos/vim-erde'), { symlink = true })
