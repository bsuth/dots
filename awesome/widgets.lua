local gears = require 'gears'
local wibox = require 'wibox'

--------------------------------------------------------------------------------
-- ROTATOR
--------------------------------------------------------------------------------

local rotator = {
	rotatee = nil,
	theta = 0,

	fit = function(self, _, width, height)
		return width, height
	end,

	layout = function(self, _, width, height)
		return {
			wibox.widget.base.place_widget_via_matrix(
				self.rotatee,
				gears.matrix.create_rotate_at(
					width / 2,
					height / 2,
					self.theta
				),
				width,
				height
			)
		}
	end,
}

setmetatable(rotator, {
    __call = function(self)
        local newrotator = wibox.widget.base.make_widget(nil, nil, {
            enable_properties = true,
        })

        -- Must use crush here! The table from make_widget already has a
        -- metatable set!
        gears.table.crush(newrotator, rotator, true)
        return newrotator
    end,
})

--------------------------------------------------------------------------------
-- WIDGETS
--------------------------------------------------------------------------------

return {
	rotator = rotator,
}
