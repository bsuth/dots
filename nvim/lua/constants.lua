local path = require('utils.path')

local M = {}

M.HOME = os.getenv('HOME')
M.DOTS = os.getenv('DOTS')

---@as string
M.DATA_DIR = vim.fn.stdpath('data')
M.PLUGINS_DIR = path.join(M.DATA_DIR, 'site/pack/plugins/start')
M.SWAP_DIR = path.join(M.DATA_DIR, 'swap')

M.TRACK_CWD_FILTERS = {}

return M
