local path = require('utils.path')

local M = {}

M.HOME = os.getenv('HOME')
M.DOTS = os.getenv('DOTS')

M.DATA_DIR = vim.fn.stdpath('data')
M.PLUGINS_DIR = path.join(M.DATA_DIR, 'site/pack/plugins/start')
M.SWAP_DIR = path.join(M.DATA_DIR, 'swap')

M.TERM_PATTERNS = { 'term://*' }
M.C_PATTERNS = { '*.h', '*.c' }
M.JS_PATTERNS = { '*.js', '*.mjs', '*.jsx', '*.ts', '*.tsx', '*.vue' }
M.CSS_PATTERNS = { '*.css', '*.scss', '*.less' }
M.HTML_PATTERNS = { '*.html' }
M.JSON_PATTERNS = { '*.json', '*.cjson' }

M.TRACK_CWD_FILTERS = {}

return M
