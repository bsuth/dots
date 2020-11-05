local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local wibox = require 'wibox' 

local tag_manager_model = require 'models/tag_manager'

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- Constants --

local TAG_COLORS = {
    beautiful.colors.blue,
    beautiful.colors.red,
    beautiful.colors.purple,
    beautiful.colors.yellow,
    beautiful.colors.green,
    beautiful.colors.cyan,
}

-- Widgets --

local circle_widgets = {}
local list_widget = {}

-- Other --

local popup = {}
local keygrabber = {}

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

for _, tag_color in ipairs(TAG_COLORS) do
	table.insert(circle_widgets, wibox.widget({
		{
			{
				{
					margins = 10,
					widget = wibox.container.margin,
				},
				shape = gears.shape.circle,
				bg = tag_color,
				widget = wibox.container.background,
			},
			margins = 10,
			widget = wibox.container.margin,
		},
		shape = gears.shape.circle,
		shape_border_width = 5,
		shape_border_color = beautiful.colors.cyan,
		widget = wibox.container.background,
	}))
end

--------------------------------------------------------------------------------
-- WIDGET: LIST
--------------------------------------------------------------------------------

list_widget = wibox.widget({
	circle_widgets[1],
	spacing = 10,
	layout = wibox.layout.flex.vertical,
})

--------------------------------------------------------------------------------
-- POPUP
--------------------------------------------------------------------------------

popup = awful.popup({
    widget = {
        {
            {
                list_widget,
                margins = 15,
                widget = wibox.container.margin,
            },
            shape = gears.shape.rounded_bar,
            bg = beautiful.colors.black,
            widget = wibox.container.background,
        },
        left = 30,
        widget = wibox.container.margin,
    },
    placement = awful.placement.left,
    ontop = true,
    visible = false,
    bg = beautiful.colors.transparent,
})

--------------------------------------------------------------------------------
-- KEYGRABBER
--------------------------------------------------------------------------------

keygrabber = awful.keygrabber({
    keybindings = {
        { { submodkey }, 'Tab', function() tag_manager_model:focus() end },
        { { submodkey, 'Shift' }, 'Tab', function() tag_manager_model:focus(true) end },
        { { modkey, submodkey }, 'Tab', function() tag_manager_model:move() end },
        { { modkey, submodkey, 'Shift' }, 'Tab', function() tag_manager_model:move(true) end },
    },

    stop_key = submodkey,
    stop_event = 'release',

    start_callback = function() 
        popup.screen = awful.screen.focused()
        popup.visible = true
    end,

    stop_callback = function() 
        popup.visible = false
    end,
})

--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------

tag_manager_model:connect_signal('update', function()
    local s = awful.screen.focused()
    list_widget:reset()

    for i, tag in ipairs(tag_manager_model.taglists[s.index]) do
        list_widget:add(circle_widgets[i])

		circle_widgets[i].shape_border_color = 
			(tag == s.selected_tag) and beautiful.colors.cyan or
			beautiful.colors.transparent
    end
end)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return keygrabber
