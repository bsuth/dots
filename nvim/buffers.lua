-- -----------------------------------------------------------------------------
-- BUFFER LIST
-- -----------------------------------------------------------------------------

local bl = {}

function bl_enter()
	local lines = {}

	bl.win_restore = nvim.nvim_get_current_win()
	bl.map = {}

	for _, v in ipairs(nvim.nvim_list_bufs()) do
		if nvim.nvim_buf_get_option(v, 'buflisted') then
			local bname = nvim.nvim_buf_get_name(v)

			if bname:sub(0, 11) == '/home/bsuth' then
				bname = '~' .. bname:sub(12)
			end

			bl.map[bname] = v
			table.insert(lines, bname)
		end
	end

	local b = nvim.nvim_create_buf(false, false)
	nvim.nvim_buf_set_name(b, '[Buffer List]')

	nvim.nvim_command(('botright split#%d|resize %d'):format(b, #lines))

	nvim.nvim_buf_set_lines(b, 0, #lines, false, lines)
	nvim.nvim_buf_set_option(b, 'modifiable', false)
	nvim.nvim_buf_set_option(b, 'buftype', 'nowrite')
	nvim.nvim_buf_set_option(b, 'bufhidden', 'delete')
	nvim.nvim_buf_set_option(b, 'buflisted', false)
	nvim.nvim_buf_set_option(b, 'swapfile', false)

	nvim.nvim_buf_set_keymap(b, 'n', '<cr>', ':lua bl_select()<cr>', { noremap = true })

	bl.win = nvim.nvim_get_current_win()
	bl.buffer = b
end

function bl_select()
	local bselect = bl.map[nvim.nvim_get_current_line()]
	nvim.nvim_command(('bd %d'):format(bl.buffer))

	nvim.nvim_set_current_win(bl.win_restore)
	nvim.nvim_command(('b %d'):format(bselect))
end

nvim.nvim_set_keymap('n', '<leader>ls', ':lua bl_enter()<cr>', { noremap = true })
