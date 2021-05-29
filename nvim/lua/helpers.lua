local Array = require 'luascript/Array'

function docs()
	local filetype = nvim_buf_get_option(0, 'filetype')
	local cWORD = nvim_call_function('expand', { '<cWORD>' })

	if Array({ 'vim', 'help' }):find(filetype) then
		nvim_command('h '..cWORD)
	else
		nvim_command('Man '..cWORD)
	end
end

function get_visual_selection()
	local _, line_start, column_start = unpack(nvim_call_function('getpos', { "'<" }))
	local _, line_end, column_end = unpack(nvim_call_function('getpos', { "'>" }))

	local lines = Array(nvim_call_function('getline', { line_start, line_end }))
	nvim_call_function('setpos', { '.', {{ 0, line_start, column_start, 0 }} })

	if lines:len() == 1 then
		lines[0] = lines[0]:sub(column_start, column_end)
	elseif lines:len() > 1 then
		lines[0] = lines[0]:sub(column_start)
		lines[-1] = lines[-1]:sub(1, column_end)
	end

	return lines:join('\n')
end

function search_visual_selection()
	nvim_call_function('setreg', { '/', get_visual_selection() })
	nvim_command('normal n')
end

function on_bufenter()
	-- TODO: use luascript path functions
	local buffer = {
		name = nvim_buf_get_name(0),
		dir = nvim_call_function('fnamemodify', { nvim_buf_get_name(0), ':p:h' }),
		filetype = nvim_buf_get_option(0, 'filetype')
	}

	if buffer.name:match('^term://') then
		return
	end

	nvim_command('cd '..buffer.dir)
	if buffer.filetype == 'dirvish' then
		nvim_command('Dirvish')
	end
end

function dirvish_open()
	-- TODO: use luascript path functions
	local file = nvim_call_function('expand', { '<cWORD>' })
	local dir = nvim_call_function('fnamemodify', { file, ':p:h' })
	local ext = nvim_call_function('fnamemodify', { file, ':e' })

	if ext == 'png' then
		os.execute('xdg-open '..file..' &>/dev/null')
	else
		nvim_call_function('dirvish#open', { 'edit', 0 })
		nvim_command('cd '..dir)
	end
end
