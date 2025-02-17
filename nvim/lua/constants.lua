local path = require('lib.path')

local M = {}

M.HOME = os.getenv('HOME')
M.DOTS = os.getenv('DOTS')

M.DATA_DIR = vim.fn.stdpath('data') --[[@as string]]
M.PLUGINS_DIR = path.join(M.DATA_DIR, 'site/pack/plugins/start')
M.SWAP_DIR = path.join(M.DATA_DIR, 'swap')

M.TRACK_CWD_FILTERS = {}

return M
