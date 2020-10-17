local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local wibox = require 'wibox' 

local popup = require 'apps/dashboard/popup'
local dial = require 'widgets/dial' 

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- Constants --

local _MAX_LIST_ITEMS = 3

-- State --

local _state = {}
local _list_items = {}

-- Widgets --

local _list = {}
local _scroll_dial = {}

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function _list_item_factory(alias, command)
	local textbox = wibox.widget({
		markup = alias,
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
		alias = alias,
		callback = command.callback,
        filtered = true,

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

local function _button_factory(widget)
	return wibox.widget({
        {
            {
                widget,
                margins = 10,
                widget = wibox.container.margin,
            },
            widget = wibox.container.place,
        },
		shape = gears.shape.circle,
		bg = beautiful.colors.black,
		widget = wibox.container.background,
	})
end

local function _unselect()
	if _state.selected ~= 0 then
		_list_items[_state.selected].arrow.visible = false
		_state.selected = 0
	end
end

local function _select(index)
	if index < 1 or index > #_list_items then return end
	_unselect()

	if index < _state.scroll_offset + 1 then
		_state.scroll_offset = index - 1
	elseif index > _state.scroll_offset + _MAX_LIST_ITEMS then
		_state.scroll_offset = _state.scroll_offset + 
			index - (_state.scroll_offset + _MAX_LIST_ITEMS)
	end

	_state.selected = index
	_list_items[index].arrow.visible = true
end

local function _refresh(hard_refresh)
	if hard_refresh then _unselect(); _state.scroll_offset = 0 end
	_list:reset()

	local scroll_current = 0
	local scroll_total = 0
    local list_item_counter = 0

    for i, list_item in ipairs(_list_items) do
        list_item.filtered = true

		if list_item.alias:sub(1, #_state.filter) == _state.filter then
            list_item.filtered = false
			scroll_total = scroll_total + 1

			if i > _state.scroll_offset and list_item_counter < _MAX_LIST_ITEMS then
                list_item_counter = list_item_counter + 1
				list_item.textbox.markup = ("<span color='%s'>%s</span>%s"):format(
					beautiful.colors.cyan,
					_state.filter,
					list_item.alias:sub(#_state.filter + 1)
				)

				if _state.selected == 0 then _select(i) end
				if i == _state.selected then scroll_current = scroll_total end

				_list:add(list_item.widget)
			end
		end
    end

	if scroll_total == 0 then
		_scroll_dial.percent = 0
	elseif scroll_total == 1 then
		_scroll_dial.percent = 1
	else
		-- Offset the scroll values by one to get `_scroll_dial.percent = 0`,
		-- when the first item is selected
		_scroll_dial.percent = 100 * (scroll_current - 1) / (scroll_total - 1)
	end

	_scroll_dial:emit_signal('widget::redraw_needed')
	_list:emit_signal('widget::redraw_needed')
end

local function _shift_list(shift)
    for i = _state.selected + shift, (shift < 0 and 1 or #_list_items), shift do
        local list_item = _list_items[i]

        if not list_item.filtered then
            _select(i)
            _refresh()
            break
        end
    end
end

local function _commit(list_item)
    if list_item and list_item.callback then
        (list_item.callback)()
    end
end

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

gears.table.crush(_state, {
	filter = '',
	selected = 0,
	scroll_offset = 0,

	commands = {
		db = {
			icon = beautiful.icon('apps/cs-sound.svg'),
			callback = function()
				awful.spawn('st -e nvim -c ":DBUI"')
			end,
		},
		sleep = {
			icon = beautiful.icon('apps/cs-sound.svg'),
			callback = function() awful.spawn('systemctl suspend') end,
		},
		reboot = {
			alias = 'reboot',
			icon = beautiful.icon('apps/cs-sound.svg'),
			callback = function() awful.spawn('/sbin/reboot') end,
		},
		poweroff = {
			icon = beautiful.icon('apps/cs-sound.svg'),
			callback = function() awful.spawn('/sbin/poweroff') end,
		},
	},
})

local dmenu_config_file = io.open('/home/bsuth/dots/awesome/__config/dmenu.lua', 'r')

if dmenu_config_file ~= nil then
    io.close(dmenu_config_file)

    for alias, command in pairs(require('__config/dmenu')) do
        _state.commands[alias] = command
    end
end

--------------------------------------------------------------------------------
-- WIDGET: LIST
--------------------------------------------------------------------------------

_list = wibox.widget({
	forced_width = 400,
	spacing = 10,
	layout = wibox.layout.flex.vertical,
})

for alias, command in pairs(_state.commands) do
	local list_item = _list_item_factory(alias, command)
    local list_item_index = #_list_items + 1

    popup:register_hover(list_item.widget)
    list_item.widget:connect_signal('button::press', function(_, _, _, button, _, _)
        if button == 1 and list_item.callback then _commit(list_item) end
    end)

    list_item.widget:connect_signal('mouse::enter', function()
        _select(list_item_index)
        _refresh()
    end)

    _list:add(list_item.widget)
	table.insert(_list_items, list_item)
end

_list:connect_signal('button::press', function(_, _, _, button, _, _)
    if button == 4 then
        _shift_list(-1)
    elseif button == 5 then
        _shift_list(1)
    end
end)

--------------------------------------------------------------------------------
-- WIDGET: SCROLL DIAL
--------------------------------------------------------------------------------

_scroll_dial = wibox.widget({
	forced_width = 50,
	forced_height = 50,

	color = beautiful.colors.green,
	percent = 0,

	onscrollup = function(self) _shift_list(-1) end,
	onscrolldown = function(self) _shift_list(1) end,

	widget = dial,
})

popup:register_hover(_scroll_dial, 'dot')

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

_refresh()

return {
    icon = beautiful.icon('todo'),
    keygrabber = {
        keybindings = {
            {{ 'Control' }, 'p', function() _shift_list(-1) end},
            {{ 'Control' }, 'n', function() _shift_list(1) end},
            {{ }, 'Return', function() _commit(_list_items[_state.selected]) end},
        },

        stop_callback = function()
            _state.filter = ''
            _refresh(true)
        end,

        keypressed_callback = function(_, mods, key)
            if #mods == 0 and key:match('^[a-zA-Z -]$') then
                _state.filter = _state.filter .. key
                _refresh(true)
            elseif key == 'BackSpace' and #_state.filter > 0 then
                _state.filter = _state.filter:sub(1, #_state.filter - 1)
                _refresh(true)
            end
        end,
    },
    widget = wibox.widget({
        _button_factory(_scroll_dial),
        {
            {
                _list,
                margins = 50,
                widget = wibox.container.margin,
            },
            shape = gears.shape.rounded_rect,
            bg = beautiful.colors.black,
            widget = wibox.container.background,
        },
        spacing = 15,
        layout = wibox.layout.fixed.horizontal,
    }),
}
