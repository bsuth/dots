local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty'
local wibox = require 'wibox'

local cjson = require 'cjson'

local slider = require 'widgets/slider' 

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

local curl = 'curl "wttr.in/~Frankfurt+Hauptbahnhof?format=j1"'

--------------------------------------------------------------------------------
-- WEATHER
--------------------------------------------------------------------------------

local current_weather = wibox.widget({
    markup = '-',
    widget = wibox.widget.textbox,
})

local weather = wibox.widget({
    {
        current_weather,
        shape = gears.shape.rounded_rect,
        bg = '#181818',
        widget = wibox.container.background,
    },
    widget = wibox.container.place,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

-- awful.spawn.easy_async(curl, function(stdout, stderr, exitreason, exitcode)
--     local weather_data = cjson.decode(stdout)
--     local current_condition = weather_data.current_condition[1]
--     current_weather.markup = current_condition.temp_C
-- end)

return weather
