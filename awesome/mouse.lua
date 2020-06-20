local awful = require('awful')
local gears = require('gears')

---------------------------------------
-- INIT
---------------------------------------

local mouse = {}

local modkey = 'Mod4'

---------------------------------------
-- GLOBAL BUTTONS
---------------------------------------

mouse.global = gears.table.join(
)

---------------------------------------
-- CLIENT BUTTONS
---------------------------------------

mouse.client = gears.table.join(
    -- ------------------
    -- Move/Resize
    -- ------------------

    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),

    awful.button({ 'Shift' }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),

    awful.button({ 'Control', 'Shift' }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

---------------------------------------
-- RETURN
---------------------------------------

return mouse
