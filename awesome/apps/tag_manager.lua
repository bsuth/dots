local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local wibox = require 'wibox' 

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- Constants --

local _TAG_COLORS = {
    beautiful.colors.blue,
    beautiful.colors.red,
    beautiful.colors.purple,
    beautiful.colors.yellow,
    beautiful.colors.green,
    beautiful.colors.cyan,
}

-- State --

local _state = {}

-- Widgets --

local _list = {}
local _popup = {}

-- Other --

local keygrabber = {}
local api = {}

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function _tag_factory(color_index)
    while color_index > #_TAG_COLORS do
        color_index = color_index - #_TAG_COLORS
    end

    return wibox.widget({
        {
            {
                {
                    margins = 10,
                    widget = wibox.container.margin,
                },
                shape = gears.shape.circle,
                bg = _TAG_COLORS[color_index],
                widget = wibox.container.background,
            },
            margins = 10,
            widget = wibox.container.margin,
        },
        shape = gears.shape.circle,
		shape_border_width = 5,
		shape_border_color = beautiful.colors.cyan,
        widget = wibox.container.background,
    })
end

local function _refresh()
    local s = awful.screen.focused()
    _list:reset()

    for _, tag in pairs(_state.taglists[s.index]) do
        _list:add(tag.widget)

        if tag.tag == s.selected_tag then
            tag.widget.shape_border_color = beautiful.colors.cyan
        else
            tag.widget.shape_border_color = beautiful.colors.transparent
        end
    end
end

local function _shift(dir)
    local s = awful.screen.focused()
    local taglist = _state.taglists[s.index]
    local wrap_tag = dir > 0 and taglist[1] or taglist[#taglist]

    for i, tag in pairs(taglist) do
        if tag.tag == s.selected_tag then
            (taglist[i + dir] or wrap_tag).tag:view_only()
            break
        end
    end
end

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function api.add(focus, screen)
    s = screen or awful.screen.focused()
    local counter = _state.counters[s.index] + 1
    local taglist = _state.taglists[s.index]

    table.insert(taglist, {
        tag = awful.tag.add(tostring(counter), {
            screen = s,
            layout = awful.layout.suit.tile,
        }),
        widget = _tag_factory(counter),
    })

    if focus then taglist[counter].tag:view_only() end
    _state.counters[s.index] = counter
end

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

gears.table.crush(_state, {
    taglists = {},
    counters = {},
})

awful.screen.connect_for_each_screen(function(s)
    local taglist = {}

    _state.taglists[s.index] = taglist
    _state.counters[s.index] = 0

    for i = 1, 2 do api.add() end
    taglist[1].tag:view_only()

    s:connect_signal('tag::history::update', function()
        local last_tag = taglist[#taglist].tag
        if s.selected_tag == last_tag then return end

        if #last_tag:clients() == 0 then
            _state.counters[s.index] = _state.counters[s.index] - 1
            last_tag:delete()
            taglist[#taglist] = nil
            _refresh()
        end
    end)
end)

--------------------------------------------------------------------------------
-- WIDGET: LIST
--------------------------------------------------------------------------------

_list = wibox.widget({
	spacing = 10,
	layout = wibox.layout.flex.vertical,
})

--------------------------------------------------------------------------------
-- WIDGET: POPUP
--------------------------------------------------------------------------------

_popup = awful.popup({
    widget = {
        {
            {
                _list,
                margins = 15,
                widget = wibox.container.margin,
            },
            shape = gears.shape.rounded_bar,
            bg = beautiful.colors.black,
            widget = wibox.container.background,
        },
        left = 30,
        widget = wibox.container.margin,
    },

    placement = awful.placement.left,
    ontop = true,
    visible = false,
    bg = beautiful.colors.transparent,
})

--------------------------------------------------------------------------------
-- KEYGRABBER
--------------------------------------------------------------------------------

local modkey = 'Mod4'
local submodkey = 'Mod1'

keygrabber = awful.keygrabber({
    keybindings = {
        { { submodkey }, 'Tab', function() _shift(1); _refresh() end },
        { { submodkey, 'Shift' }, 'Tab', function() _shift(-1); _refresh() end },
    },

    stop_key = submodkey,
    stop_event = 'release',

    start_callback = function() 
        local s = awful.screen.focused()
        _popup.screen = s
        _popup.visible = true
        _refresh()
    end,

    stop_callback = function() 
        _popup.visible = false
    end,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return {
    keygrabber = keygrabber,
    api = api,
}
