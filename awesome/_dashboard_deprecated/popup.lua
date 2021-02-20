local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox' 

--------------------------------------------------------------------------------
-- POPUP
--------------------------------------------------------------------------------

local popup = awful.popup({
    widget = {
        markup = 'placeholder',
        widget = wibox.widget.textbox,
    },
    ontop = true,
    visible = false,
    bg = beautiful.colors.dimmed,
})

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function popup:init(widget)
    popup.widget = wibox.widget({
		{
			{
				widget,
				left = 120,
				right = 120,
				top = 70,
				bottom = 70,
				widget = wibox.container.margin,
			},
			forced_width = 1200,
			forced_height = 700,
			shape = gears.shape.rounded_rect,
			shape_border_width = 10,
			bg = beautiful.colors.black,
			widget = wibox.container.background,
		},
		widget = wibox.container.place,
    })
end

function popup:start()
    self.screen = awful.screen.focused()
    self.widget.forced_width = self.screen.geometry.width
    self.widget.forced_height = self.screen.geometry.height
    self.visible = true
end

function popup:stop()
    self.visible = false
end

function popup:register_hover(widget, cursor)
    widget:connect_signal('mouse::enter', function()
        popup.cursor = cursor or 'hand2' 
    end)

    widget:connect_signal('mouse::leave', function()
        popup.cursor = 'arrow' 
    end)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return popup
