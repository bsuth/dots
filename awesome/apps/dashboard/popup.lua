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
    bg = beautiful.colors.black,
})

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function popup:init(widget)
    popup.widget = wibox.widget({
		{
			widget,
			left = 50,
			right = 50,
			top = 50,
			bottom = 50,
			widget = wibox.container.margin,
		},
		shape = gears.shape.rounded_rect,
		shape_border_width = 10,
		widget = wibox.container.background,
    })
end

function popup:start()
    self.screen = awful.screen.focused()

	self.x = self.screen.geometry.width * 0.1
	self.y = self.screen.geometry.height * 0.1
    self.widget.forced_width = self.screen.geometry.width * 0.8
    self.widget.forced_height = self.screen.geometry.height * 0.8

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
