local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local wibox = require 'wibox' 

local popup = require 'dashboard/popup'
local dial = require 'widgets/dial' 

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- Constants --

local MAX_LIST_ITEMS = 8

-- State --

local state = {}
local list_items = {}

-- Widgets --

local list_widget = {}
local scroll_dial_widget = {}

--------------------------------------------------------------------------------
-- LOCAL FUNCTIONS
--------------------------------------------------------------------------------

local function select(i)
	if i < 1 or i > #list_items then return end

	if i < state.scroll_offset + 1 then
		state.scroll_offset = i - 1
	elseif i > state.scroll_offset + MAX_LIST_ITEMS then
		state.scroll_offset = state.scroll_offset + 
			i - (state.scroll_offset + MAX_LIST_ITEMS)
	end

	state.selected = i
end

local function update(hard_reset)
	if hard_reset then
		state.selected = nil
		state.scroll_offset = 0
	end

	list_widget:reset()

	local scroll_current = 0
	local scroll_total = 0
    local list_item_counter = 0

    for i, list_item in ipairs(list_items) do
		if list_item.alias:sub(1, #state.filter) == state.filter then
			scroll_total = scroll_total + 1

			if i > state.scroll_offset and list_item_counter < MAX_LIST_ITEMS then
                list_item_counter = list_item_counter + 1
				list_item.textbox.markup = ("<span color='%s'>%s</span>%s"):format(
					beautiful.colors.cyan,
					state.filter,
					list_item.alias:sub(#state.filter + 1)
				)

				if state.selected == nil or i == state.selected then
					state.selected = i
					list_item.arrow.visible = true
					scroll_current = scroll_total
				else
					list_item.arrow.visible = false
				end

				list_widget:add(list_item.widget)
			end
		end
    end

	if scroll_total == 0 then
		scroll_dial_widget.percent = 0
	elseif scroll_total == 1 then
		scroll_dial_widget.percent = 1
	else
		-- Offset the scroll values by one to get `scroll_dial_widget.percent = 0`,
		-- when the first item is selected
		scroll_dial_widget.percent = 100 * (scroll_current - 1) / (scroll_total - 1)
	end

	scroll_dial_widget:emit_signal('widget::redraw_needed')
	list_widget:emit_signal('widget::redraw_needed')
end

local function scroll(inc)
    for i = state.selected + inc, (inc < 0 and 1 or #list_items), inc do
        local list_item = list_items[i]

        if list_item.alias:sub(1, #state.filter) == state.filter then
            select(i)
            update()
            break
        end
    end
end

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

gears.table.crush(state, {
	filter = '',
	selected = nil,
	scroll_offset = 0,

	commands = {
		flameshot = function() awful.spawn('flameshot gui') end,
		sleep = function() awful.spawn('systemctl suspend') end,
		reboot = function() awful.spawn('/sbin/reboot') end,
		poweroff = function() awful.spawn('/sbin/poweroff') end,
	},
})

local dmenu_config_file = io.open(ROOT .. '/__config/dmenu.lua', 'r')

if dmenu_config_file ~= nil then
    io.close(dmenu_config_file)

    for alias, command in pairs(require('__config/dmenu')) do
        state.commands[alias] = command
    end
end

for alias, command in pairs(state.commands) do
	table.insert(list_items, {
		alias = alias,
		command = command,
	})
end

--------------------------------------------------------------------------------
-- WIDGET: LIST
--------------------------------------------------------------------------------

list_widget = wibox.widget({
	forced_width = 400,
	spacing = 10,
	layout = wibox.layout.flex.vertical,
})

for i, list_item in ipairs(list_items) do
	list_item.textbox = wibox.widget({
		markup = alias,
		valign = 'center',
		widget = wibox.widget.textbox,
	})

	list_item.arrow = wibox.widget({
		forced_width = 30,
		forced_height= 30,
		image = beautiful.icon('arrow-left'),
		visible = false,
		widget = wibox.widget.imagebox,
	})

	list_item.widget = wibox.widget({
		{
			{
				list_item.textbox,
				left = 20,
				right = 20,
				widget = wibox.container.margin,
			},
			nil,
			{
				list_item.arrow,
				widget = wibox.container.place,
			},
			layout = wibox.layout.align.horizontal,
		},
		top = 10,
		bottom = 10,
		left = 20,
		right = 20,
		widget = wibox.container.margin,
	})

    popup:register_hover(list_item.widget)
    list_widget:add(list_item.widget)
end

--------------------------------------------------------------------------------
-- WIDGET: SCROLL DIAL
--------------------------------------------------------------------------------

scroll_dial_widget = wibox.widget({
	forced_width = 50,
	forced_height = 50,

	color = beautiful.colors.green,
	percent = 0,

	onscrollup = function(self) scroll(-1) end,
	onscrolldown = function(self) scroll(1) end,

	widget = dial,
})

popup:register_hover(scroll_dial_widget, 'dot')

--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------

list_widget:connect_signal('button::press', function(_, _, _, button, _, _)
    if button == 4 then
        scroll(-1)
    elseif button == 5 then
        scroll(1)
    end
end)

for i, list_item in ipairs(list_items) do
    list_item.widget:connect_signal('button::press', function(_, _, _, button, _, _)
        if button == 1 then
			(list_item.command)()
			self:emit_signal('close_dashboard')
		end
    end)

    list_item.widget:connect_signal('mouse::enter', function()
        select(i)
		update()
    end)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

update()

return {
    icon = beautiful.icon('spaceship'),
    keygrabber = {
        keybindings = {
            {{ 'Control' }, 'p', function() scroll(-1) end},
            {{ 'Control' }, 'n', function() scroll(1) end},
            {{ }, 'Return', function(self)
				(list_items[state.selected].command)()
				self:emit_signal('close_dashboard')
			end},
        },

        stop_callback = function()
            state.filter = ''
            update(true)
        end,

        keypressed_callback = function(_, mods, key)
            if #mods == 0 and key:match('^[a-zA-Z -]$') then
                state.filter = state.filter .. key
                update(true)
            elseif key == 'BackSpace' and #state.filter > 0 then
                state.filter = state.filter:sub(1, #state.filter - 1)
                update(true)
            end
        end,
    },
    widget = wibox.widget({
		{
			{
				{
					scroll_dial_widget,
					margins = 10,
					widget = wibox.container.margin,
				},
				widget = wibox.container.place,
			},
			shape = gears.shape.circle,
			bg = beautiful.colors.black,
			widget = wibox.container.background,
		},
		{
			list_widget,
			margins = 50,
			widget = wibox.container.margin,
		},
        spacing = 15,
        layout = wibox.layout.fixed.horizontal,
    }),
}
