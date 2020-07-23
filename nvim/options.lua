-- -----------------------------------------------------------------------------
-- OPTIONS
-- -----------------------------------------------------------------------------

local global_options = {
    ignorecase = true,
    smartcase = true,
    termguicolors = true,
	splitright = true,
	splitbelow = true,
	clipboard = 'unnamedplus',
}

local buf_options = {
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
}

local win_options = {
    number = true,
    wrap = false,
	colorcolumn = '80',
	signcolumn = 'yes',
}

-- VimScript's :set command is actually an alias for both :setlocal and
-- :setglobal. We don't have an equivalent api function so we have to remember
-- to change both the local and global options!

for k, v in pairs(global_options) do
    nvim.nvim_set_option(k, v)
end

for k, v in pairs(buf_options) do
    nvim.nvim_set_option(k, v)
    nvim.nvim_buf_set_option(0, k, v)
end

for k, v in pairs(win_options) do
    nvim.nvim_set_option(k, v)
    nvim.nvim_win_set_option(0, k, v)
end

nvim.nvim_command([[ highlight ColorColumn guibg=#585858 ]])
