local wibox = require 'wibox'

return {
	center = function(w, halign, valign)
		return wibox.widget {
			w,
			halign = halign or 'center',
			valign = valign or 'center',
			widget = wibox.container.place,
		}
	end,

	hpad = function(space)
		return wibox.widget {
			left = space,
			widget = wibox.container.margin,
		}
	end,

	vpad = function(space)
		return wibox.widget {
			top = space,
			widget = wibox.container.margin,
		}
	end,
}
