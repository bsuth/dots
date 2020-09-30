local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

--------------------------------------------------------------------------------
-- GRID
--------------------------------------------------------------------------------

local grid = {}

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function grid:fit(_, width, height)
    return width, height
end

function grid:draw(_, cr, width, height)
end

function grid:default_focus()
    local children = self:get_all_children()

    if #children > 0 then
        self:focus(children[1])
    end
end

function grid:focus(w)
    if self.focused_widget then
        self.focused_widget.shape_border_color = self.inactive_color
    end

    w.shape_border_color = self.active_color
    self.focused_widget = w
end

function grid:focus_by_direction(dir)
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

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return setmetatable(grid, {
    __call = function(self)
        local newgrid = wibox.widget.base.make_widget(nil, nil, {
            enable_properties = true,
        })

        -- Must use crush here! The table from make_widget already has a
        -- metatable set!
        gears.table.crush(newgrid, grid, true)
        return newgrid
    end,
})
