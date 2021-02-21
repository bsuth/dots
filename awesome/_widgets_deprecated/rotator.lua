local gears = require 'gears' 
local wibox = require 'wibox' 

--------------------------------------------------------------------------------
-- ROTATOR
--------------------------------------------------------------------------------

local rotator = {
	origin_x = 0,
	origin_y = 0,
	theta = 0,
	rotatee = nil,
}

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function rotator:fit(_, width, height)
    return width, height
end

function rotator:layout(_, width, height)
    return {
		wibox.widget.base.place_widget_via_matrix(
			self.rotatee,
			gears.matrix.create_rotate_at(
				self.origin_x,
				self.origin_y,
				self.theta
			),
			width,
			height
		)
	}
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return setmetatable(rotator, {
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
