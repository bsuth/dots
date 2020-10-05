local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears'

local cjson = require 'cjson'

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------

local weather = gears.object()

local _private = {
    current = {},
    forecast = {},
    maxc = -99,
    minc = -99,
    maxf = -99,
    minf = -99,
}

--------------------------------------------------------------------------------
-- ICON DATA
--------------------------------------------------------------------------------

local ICON_DATA = {
    { icon = '', codes = { 113 } }, -- Sunny
    { icon = '', codes = { 116 } }, -- PartlyCloudy
    { icon = '', codes = { 119 } }, -- Cloudy
    { icon = '', codes = { 122 } }, -- VeryCloudy
    { icon = '', codes = { 143, 248, 260 } }, -- Fog
    { icon = '', codes = { 176, 263, 353 } }, -- LightShowers
    { icon = '', codes = { 179, 362, 365, 374 } }, -- LightSleetShowers
    { icon = '', codes = { 182, 185, 281, 284, 311, 314, 317, 350, 377 } }, -- LightSleet
    { icon = '', codes = { 200, 386 } }, -- ThunderyShowers
    { icon = '', codes = { 227, 320 } }, -- LightSnow
    { icon = '', codes = { 230, 329, 332, 338 } }, -- HeavySnow
    { icon = '', codes = { 266, 293, 296 } }, -- LightRain
    { icon = '', codes = { 299, 305, 356 } }, -- HeavyShowers
    { icon = '', codes = { 302, 308, 359 } }, -- HeavyRain
    { icon = '', codes = { 323, 326, 368 } }, -- LightSnowShowers
    { icon = '', codes = { 335, 371, 395 } }, -- HeavySnowShowers
    { icon = '', codes = { 389 } }, -- ThunderyHeavyRain
    { icon = '', codes = { 392 } }, -- ThunderySnowShowers
}

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function getIcon(code)
    for _, iconData in ipairs(ICON_DATA) do
        for _, _code in ipairs(iconData.codes) do
            if code == _code then
                return iconData.icon
            end
        end
    end

    return 'No Icon'
end

local function extractWeatherData(data, current)
    return {
        tempc = tonumber(current and data.temp_C or data.tempC),
        tempf = tonumber(current and data.temp_F or data.tempF),
        feelc = tonumber(data.FeelsLikeC),
        feelf = tonumber(data.FeelsLikeF),
        humidity = tonumber(data.humidity),
        code = tonumber(data.weatherCode),
        icon = getIcon(tonumber(data.weatherCode)),
    }
end

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function weather:get(param, forecast_hour)
    if forecast_hour ~= nil then
        return _private.forecast[forecast_hour][param]
    else
        return _private[param] or _private.current[param]
    end
end

function weather:update()
    awful.spawn.easy_async([[
        curl "wttr.in/~Frankfurt+Hauptbahnhof?format=j1"
    ]], function(stdout)
        local weather_data = cjson.decode(stdout)
        local current_condition = weather_data.current_condition[1]

        _private.current = extractWeatherData(weather_data.current_condition[1], true)

        local weather_today = weather_data.weather[1]
        _private.maxc = weather_today.maxtempC
        _private.minc = weather_today.mintempC
        _private.maxf = weather_today.maxtempF
        _private.minf = weather_today.mintempF

        for i, hourly_data in ipairs(weather_today.hourly) do
            _private.forecast[i] = extractWeatherData(hourly_data)
        end

        self:emit_signal('update')
    end)
end

--------------------------------------------------------------------------------
-- DAEMONS
--------------------------------------------------------------------------------

gears.timer({
    timeout = 1200,
    autostart = true,
    callback = function() weather:update() end,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

weather:update()
return weather
