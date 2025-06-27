local onedark = require('lib.onedark')

local M = {}

M.MAX_WINDOW_HEIGHT = 16

M.NAMESPACE_ID = vim.api.nvim_create_namespace('')
vim.api.nvim_set_hl(M.NAMESPACE_ID, 'OverflowEllipses', { fg = onedark.grey })
vim.api.nvim_set_hl(M.NAMESPACE_ID, 'FocusedIndex', { fg = onedark.cyan })

return M
