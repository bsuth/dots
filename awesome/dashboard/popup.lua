local awful = require 'awful'
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
    bg = '#00000088',
})

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function popup:set(content)
    popup.widget = wibox.widget({
        content,
        left = 50,
        right = 50,
        top = 50,
        bottom = 50,
        widget = wibox.container.margin,
    })
end

function popup:toggle()
    if not self.visible then
        self.screen = awful.screen.focused()
        self.widget.forced_width = self.screen.geometry.width
        self.widget.forced_height = self.screen.geometry.height
        self.visible = true
    else
        self.visible = false
    end
end

function popup:register_hover(widget)
    widget:connect_signal('mouse::enter', function()
        popup.cursor = 'hand2' 
    end)

    widget:connect_signal('mouse::leave', function()
        popup.cursor = 'arrow' 
    end)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return popup
