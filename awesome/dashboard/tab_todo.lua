local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

local cjson = require 'cjson'

--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------

local model = {
	todos = {},
	new_todo_widget = nil,
}

local todo_fd = io.open(ROOT .. '/__storage/todo.json', 'r')

if todo_fd ~= nil then
	model.todos = cjson.decode(todo_fd:read())
	todo_fd:close()
else
	require('naughty').notify({text=''})
end

--------------------------------------------------------------------------------
-- VIEW
--------------------------------------------------------------------------------

-- list --

local list_children = {}

for _, todo in ipairs(model.todos) do
	table.insert(list_children, wibox.widget({
		markup = todo,
		widget = wibox.widget.textbox,
	}))
end

local list = wibox.widget({ layout = wibox.layout.flex.vertical })
list:set_children(list_children)

-- add button --

local add_button = wibox.widget({
	markup = '+',
	widget = wibox.widget.textbox,
})

--------------------------------------------------------------------------------
-- CONTROLLER
--------------------------------------------------------------------------------

local function new_todo_widget_add()
	local todo_widget = wibox.widget({
			markup = '',
			widget = wibox.widget.textbox,
		})

	table.insert(list_children, todo_widget)
	list:set_children(list_children)
	model.new_todo_widget = todo_widget
end

local function new_todo_widget_commit()
	table.insert(model.todos, model.new_todo_widget.markup)
	model.new_todo_widget = nil

	local fd = io.open('/home/bsuth/dots/awesome/__storage/todo.json', 'w')
	if fd ~= nil then
		fd:write(cjson.encode(model.todos))
		fd:close()
	end
end

local function new_todo_widget_update(mods, key)
	local w = model.new_todo_widget
	if #mods ~= 0 then return end

	if key:match('^[a-zA-Z -]$') then
		w.markup = w.markup .. key
	elseif key == 'BackSpace' and #w.markup > 0 then
	elseif key == 'Return' then
		new_todo_widget_commit()
	end
end

--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------

add_button:connect_signal('button::press', function(_, _, _, button, _, _)
    if button == 1 then new_todo_widget_add() end
end)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return {
    icon = beautiful.icon('todo'),
    keygrabber = {
        keypressed_callback = function(_, mods, key)
			if model.new_todo_widget == nil then return end
			new_todo_widget_update(mods, key)
        end,
	},
    widget = wibox.widget({
		add_button,
		list,
		layout = wibox.layout.flex.vertical,
	}),
}
