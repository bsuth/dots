local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local naughty = require 'naughty' 
local wibox = require 'wibox' 

local layouts = require 'layouts' 

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

local state = {
	filter = '',
	selected = nil,
	commands = {
		{
			alias = 'db',
			icon = beautiful.icon('apps/cs-sound.svg'),
			callback = function()
				awful.spawn('st -e nvim -c ":DBUI"')
			end,
		},
		{
			alias = 'sleep',
			icon = beautiful.icon('apps/cs-sound.svg'),
			callback = function() awful.spawn('systemctl suspend') end,
		},
		{
			alias = 'reboot',
			icon = beautiful.icon('apps/cs-sound.svg'),
			callback = function() awful.spawn('reboot') end,
		},
		{
			alias = 'poweroff',
			icon = beautiful.icon('apps/cs-sound.svg'),
			callback = function() awful.spawn('poweroff') end,
		},
	},
}

for _, command in ipairs(require('__config/dmenu')) do
	table.insert(state.commands, command)
end

--------------------------------------------------------------------------------
-- LIST
--------------------------------------------------------------------------------

function list_item_factory(command)
	local textbox = wibox.widget({
		markup = command.alias,
		valign = 'center',
		widget = wibox.widget.textbox,
	})

	local arrow = wibox.widget({
		forced_width = 30,
		forced_height= 30,
		image = beautiful.icon('../16x16/actions/arrow-left.svg'),
		visible = false,
		widget = wibox.widget.imagebox,
	})

	return {
		alias = command.alias,
		callback = command.callback,
		filtered = false,

		textbox = textbox,
		arrow = arrow ,
		widget = wibox.widget({
			{
				{
					{
						forced_width = 30,
						forced_height= 30,
						image = command.icon,
						widget = wibox.widget.imagebox,
					},
					widget = wibox.container.place,
				},
				{
					textbox,
					left = 20,
					right = 20,
					widget = wibox.container.margin,
				},
				{
					arrow,
					widget = wibox.container.place,
				},
				layout = wibox.layout.align.horizontal,
			},
			top = 10,
			bottom = 10,
			left = 20,
			right = 20,
			widget = wibox.container.margin,
		}),
	}
end

local list = wibox.widget({
	forced_width = 500,
	spacing = 10,
	layout = wibox.layout.flex.vertical,
})

local list_items = {}
for _, command in ipairs(state.commands) do
	local list_item = list_item_factory(command)
    list:add(list_item.widget)
	table.insert(list_items, list_item)
end

--------------------------------------------------------------------------------
-- POPUP (MAIN WRAPPER)
--------------------------------------------------------------------------------

local popup = awful.popup({
    widget = {
		{
			{
				list,
				margins = 50,
				widget = wibox.container.margin,
			},
			shape = gears.shape.rounded_rect,
			shape_border_width = 5,
			shape_border_color = beautiful.colors.cyan,
			bg = beautiful.colors.black,
			widget = wibox.container.background,
		},
        widget = wibox.container.place,
    },

    ontop = true,
    visible = false,
    bg = beautiful.colors.dimmed,
})

--------------------------------------------------------------------------------
-- FILTER
--------------------------------------------------------------------------------

local function unselect()
	if state.selected ~= nil then
		list_items[state.selected].arrow.visible = false
		state.selected = nil
	end
end

local function select(index)
	unselect()
	state.selected = index
	list_items[index].arrow.visible = true
end

local function shift_selected(shift)
	local limit = shift > 0 and #list_items or 1

    for i = state.selected + shift, limit, shift do
		if list_items[i].filtered ~= true then
			select(i)
			break
		end
	end
end

local function apply_filter()
	list:reset()
	unselect()

    for i, list_item in ipairs(list_items) do
        if list_item.alias:sub(1, #state.filter) == state.filter then
			list_item.textbox.markup = ("<span color='%s'>%s</span>%s"):format(
				beautiful.colors.cyan,
				state.filter,
				list_item.alias:sub(#state.filter + 1)
			)

			if state.selected == nil then select(i) end
			list_item.filtered = false
			list:add(list_item.widget)
		else
			list_item.filtered = true
        end
    end

	list:emit_signal('widget::redraw_needed')
end

--------------------------------------------------------------------------------
-- KEYGRABBER
--------------------------------------------------------------------------------

local modkey = 'Mod4'

apply_filter()

return awful.keygrabber({
    keybindings = {
        {{ modkey }, 'd', function(self) self:stop() end},
        {{ 'Control' }, 'bracketleft', function(self) self:stop() end},
        {{ }, 'Escape', function(self) self:stop() end},
        {{ 'Control' }, 'p', function(self) shift_selected(-1) end},
        {{ 'Control' }, 'n', function(self) shift_selected(1) end},
        {{ }, 'Return', function(self)
			popup.visible = false -- need to do this first for flameshot

			local selected_list_item = list_items[state.selected]
			if selected_list_item and selected_list_item.callback then
				(selected_list_item.callback)()
			end

			self:stop()
		end},
    },

    start_callback = function()
        local s = awful.screen.focused()
        popup.screen = s
        popup.minimum_width = s.geometry.width
        popup.minimum_height = s.geometry.height
        popup.visible = true
    end,

    stop_callback = function()
        popup.visible = false
		unselect()
		state.filter = ''
		apply_filter()
    end,

    keypressed_callback = function(self, mods, key)
        if #mods == 0 and key:match('^[a-zA-Z ]$') then
			state.filter = state.filter .. key
            apply_filter()
		elseif key == 'BackSpace' and #state.filter > 0 then
            state.filter = state.filter:sub(1, #state.filter - 1)
            apply_filter()
        end
    end,
})
