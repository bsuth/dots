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
-- LOCAL FUNCTIONS
--------------------------------------------------------------------------------

local function _refresh()
    local s = awful.screen.focused()
    _list:reset()

    for i, tag in pairs(_state.taglists[s.index]) do
        _list:add(tag.widget)
        tag.circle_widget.bg = _TAG_COLORS[i]

        if tag.tag == s.selected_tag then
            tag.widget.shape_border_color = beautiful.colors.cyan
        else
            tag.widget.shape_border_color = beautiful.colors.transparent
        end
    end
end

local function _focus(reversed)
    local s = awful.screen.focused()
    local taglist = _state.taglists[s.index]

    local increment = reversed and -1 or 1
    local wrap_tag = reversed and taglist[#taglist] or taglist[1]

    for i, tag in pairs(taglist) do
        if tag.tag == s.selected_tag then
            (taglist[i + increment] or wrap_tag).tag:view_only()
            break
        end
    end

    _refresh()
end

local function _shift(reversed)
    local s = awful.screen.focused()
    local taglist = _state.taglists[s.index]

    for i, tag in pairs(taglist) do
        if tag.tag == s.selected_tag then
            if i == 1 and reversed then
                table.remove(taglist, i)
                table.insert(taglist, tag)
            elseif i == #taglist and not reversed then
                table.remove(taglist, i)
                table.insert(taglist, 1, tag)
            else
                local swap_index = i + (reversed and -1 or 1)
                taglist[i] = taglist[swap_index]
                taglist[swap_index] = tag
            end

            break
        end
    end

    _refresh()
end

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function api.add(focus, screen)
    local s = screen or awful.screen.focused()
    local counter = _state.counters[s.index] + 1
    local taglist = _state.taglists[s.index]

    local circle_widget = wibox.widget({
        {
            margins = 10,
            widget = wibox.container.margin,
        },
        shape = gears.shape.circle,
        bg = _TAG_COLORS[1],
        widget = wibox.container.background,
    })

    local widget = wibox.widget({
        {
            circle_widget,
            margins = 10,
            widget = wibox.container.margin,
        },
        shape = gears.shape.circle,
		shape_border_width = 5,
		shape_border_color = beautiful.colors.cyan,
        widget = wibox.container.background,
    })

    table.insert(taglist, {
        tag = awful.tag.add(tostring(counter), {
            screen = s,
            layout = awful.layout.suit.tile,
        }),
        circle_widget = circle_widget,
        widget = widget,
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

    api.add(false, s)
    taglist[1].tag:view_only()

    s:connect_signal('tag::history::update', function()
        local last_tag = taglist[#taglist].tag
        if s.selected_tag == last_tag then return end

        if #taglist > 1 and #last_tag:clients() == 0 then
            while #last_tag:clients() == 0 do
                _state.counters[s.index] = _state.counters[s.index] - 1
                last_tag:delete()
                taglist[#taglist] = nil
                last_tag = taglist[#taglist].tag
            end

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
        { { submodkey }, 'Tab', function() _focus() end },
        { { submodkey, 'Shift' }, 'Tab', function() _focus(true) end },
        { { modkey, submodkey }, 'Tab', function() _shift() end },
        { { modkey, submodkey, 'Shift' }, 'Tab', function() _shift(true) end },
    },

    stop_key = submodkey,
    stop_event = 'release',

    start_callback = function() 
        _popup.screen = awful.screen.focused()
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
