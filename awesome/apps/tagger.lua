local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local wibox = require 'wibox' 

local wgrid = require 'widgets/grid' 

---------------------------------------
-- TAGGER
---------------------------------------

local tagger = {}

---------------------------------------
-- API
---------------------------------------

function tagger:new(s, taglayout)
    local _tagger = {
        x = 1,
        y = 1,
        tags = {},
    }

    _tagger.grid = wgrid.grid({
        forced_width = 150 * #taglayout[1],
        forced_height = 150 * #taglayout,

        forced_num_rows = #taglayout,
        forced_num_cols= #taglayout[1],

        spacing = 10,
        expand = true,
        homogeneous = true,
    })

    _tagger.popup = awful.popup({
        widget = {
            _tagger.grid,
            valign = 'center',
            halign = 'center',
            widget = wibox.container.place,
        },

        bg = beautiful.colors.dimmed,
        placement = awful.placement.centered,
        ontop = true,
        visible = false,
        screen = s,
        minimum_width = s.geometry.width,
        minimum_height = s.geometry.height,
    })

    for j, row in ipairs(taglayout) do
        _tagger.tags[j] = _tagger.tags[j] or {}
        for i, tagname in ipairs(row) do
            _tagger.tags[j][i] = awful.tag.add(tagname, {
                screen = s, 
                layout = awful.layout.layouts[1],
            })

            _tagger.grid:add_widget_at(wibox.widget({
                {
                    markup = tagname,
                    align  = 'center',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },

                shape = gears.shape.rectangle,
                shape_border_width = 5,
                shape_border_color = beautiful.colors.dark_grey,
                widget = wibox.container.background,
            }), j, i, 1, 1)
        end
    end

    w = _tagger.grid:get_widgets_at(_tagger.y, _tagger.x)[1]
    w.shape_border_color = beautiful.colors.green
    _tagger.tags[1][1]:view_only()

    s.tagger = _tagger
    setmetatable(_tagger, { __index = self })
    return _tagger
end

function tagger:viewdir(dir)
    self.grid:focus_by_direction(dir)
    local wpos = self.grid:get_widget_position(self.grid.focused_widget)
    self.tags[wpos.row][wpos.col]:view_only()
end

---------------------------------------
-- KEYGRABBER
---------------------------------------

local modkey = 'Mod4'

tagger.kg = awful.keygrabber({
    keybindings = {
        { { modkey }, 'h', function() 
            awful.screen.focused().tagger:viewdir('left')
        end },
        { { modkey }, 'l', function() 
            awful.screen.focused().tagger:viewdir('right')
        end },
        { { modkey }, 'k', function() 
            awful.screen.focused().tagger:viewdir('up')
        end },
        { { modkey }, 'j', function() 
            awful.screen.focused().tagger:viewdir('down')
        end },
    },

    stop_key = modkey,
    stop_event = 'release',

    start_callback = function() 
        awful.screen.focused().tagger.popup.visible = true
    end,
    stop_callback = function() 
        local s = awful.screen.focused()
		local popup = awful.screen.focused().tagger.popup
        popup.screen = s
        popup.visible = false
    end,
})

---------------------------------------
-- RETURN
---------------------------------------

return tagger
