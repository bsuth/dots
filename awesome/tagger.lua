local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

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
        popup = awful.popup({
            widget = wibox.widget({
                forced_width = 200 * #taglayout[1],
                forced_height = 200 * #taglayout,

                forced_num_rows = #taglayout,
                forced_num_cols= #taglayout[1],

                spacing = 10,
                expand = true,
                homogeneous = true,

                layout = wibox.layout.grid,
            }),

            bg = '#00000000',
            placement = awful.placement.centered,
            ontop = true,
            visible = false,
        }),
    }

    for j, row in ipairs(taglayout) do
        _tagger.tags[j] = _tagger.tags[j] or {}
        for i, tagname in ipairs(row) do
            _tagger.tags[j][i] = awful.tag.add(tagname, {
                screen = s, 
                layout = awful.layout.layouts[1],
            })

            _tagger.popup.widget:add_widget_at(wibox.widget({
                {
                    markup = tagname,
                    align  = 'center',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },

                bg = '#000000ee',
                shape = gears.shape.rounded_rect,
                shape_border_width = 5,
                shape_border_color = beautiful.colors.dark_grey,
                widget = wibox.container.background,
            }), i, j, 1, 1)
        end
    end

    w = _tagger.popup.widget:get_widgets_at(_tagger.y, _tagger.x)[1]
    w.shape_border_color = beautiful.colors.green
    _tagger.tags[1][1]:view_only()

    s.tagger = _tagger
    setmetatable(_tagger, { __index = self })
    return _tagger
end

function tagger:viewdir(dir)
    local wold = self.popup.widget:get_widgets_at(self.y, self.x)[1]

    if dir == 'left' and self.x > 1 then
        self.x = self.x - 1
    elseif dir == 'right' and self.x < #self.tags[self.y] then
        self.x = self.x + 1
    elseif dir == 'up' and self.y > 1 then
        self.y = self.y - 1
    elseif dir == 'down' and self.y < #self.tags then
        self.y = self.y + 1
    else
        return
    end

    local wnew = self.popup.widget:get_widgets_at(self.y, self.x)[1]
    wold.shape_border_color = beautiful.colors.dark_grey
    wnew.shape_border_color = beautiful.colors.green

    self.tags[self.y][self.x]:view_only()
end

---------------------------------------
-- KEYGRABBER
---------------------------------------

local modkey = 'Mod4'

tagger.kg = awful.keygrabber({
    keybindings = {
        { { modkey, 'Control' }, 'h', function() 
            awful.screen.focused().tagger:viewdir('left')
        end },
        { { modkey, 'Control' }, 'l', function() 
            awful.screen.focused().tagger:viewdir('right')
        end },
        { { modkey, 'Control' }, 'k', function() 
            awful.screen.focused().tagger:viewdir('up')
        end },
        { { modkey, 'Control' }, 'j', function() 
            awful.screen.focused().tagger:viewdir('down')
        end },
    },

    stop_key = modkey,
    stop_event = 'release',

    start_callback = function() 
        awful.screen.focused().tagger.popup.visible = true
    end,
    stop_callback = function() 
        awful.screen.focused().tagger.popup.visible = false
    end,
})

---------------------------------------
-- RETURN
---------------------------------------

return tagger
