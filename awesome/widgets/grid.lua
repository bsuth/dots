local beautiful = require 'beautiful' 
local wibox = require 'wibox' 

---------------------------------------
-- WGRID
---------------------------------------

local wgrid = {}

---------------------------------------
-- API
---------------------------------------

function wgrid.grid(args)
    args.layout = wibox.layout.grid
    local grid = wibox.widget(args)

    -- defaults
    grid.inactive_color = grid.inactive_color or beautiful.colors.dark_grey
    grid.active_color = grid.active_color or beautiful.colors.green

    return setmetatable(grid, { __index = wgrid })
end

function wgrid:default_focus()
    local children = self:get_all_children()

    if #children > 0 then
        self:focus(children[1])
    end
end

function wgrid:focus(w)
    if self.focused_widget then
        self.focused_widget.shape_border_color = self.inactive_color
    end

    w.shape_border_color = self.active_color
    self.focused_widget = w
end

function wgrid:focus_by_direction(dir)
    if not self.focused_widget then
        self:default_focus()
    end

    local rows, cols = self:get_dimension()
    local wpos = self:get_widget_position(self.focused_widget)
    local wnew, start, limit, inc, getw

    if (dir == 'left') then
        start = wpos.col - 1
        inc = -1
        limit = 0
        getw = function(i) return self:get_widgets_at(wpos.row, i) end
    elseif (dir == 'right') then
        start = wpos.col + 1
        inc = 1
        limit = cols
        getw = function(i) return self:get_widgets_at(wpos.row, i) end
    elseif (dir == 'up') then
        start = wpos.row - 1
        inc = -1
        limit = 0
        getw = function(i) return self:get_widgets_at(i, wpos.col) end
    elseif (dir == 'down') then
        start = wpos.row + 1
        inc = 1
        limit = rows
        getw = function(i) return self:get_widgets_at(i, wpos.col) end
    else
        return
    end

    for i = start, limit, inc do
        wnew = getw(i)
        if wnew ~= nil then
            self:focus(wnew[1])
            return
        end
    end
end

---------------------------------------
-- RETURN
---------------------------------------

return setmetatable(wgrid, {
    __call = function(...) return wgrid.grid(...) end
})
