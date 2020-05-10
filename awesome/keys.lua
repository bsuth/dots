local awful = require('awful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

local notifier = require('widgets.notifier')
local clientbuffer = require('widgets.clientbuffer')
local Alttab = require('widgets.alttab')

---------------------------------------
-- INIT
---------------------------------------

local keys = {}

local modkey = 'Mod4'

---------------------------------------
-- KEYGRABBERS
---------------------------------------

-- ------------------
-- Alttab
-- ------------------

local function alttabPrev()
    Alttab:get():prev()
end

local function alttabNext()
    Alttab:get():next()
end

local alttabKeygrabber = awful.keygrabber({
    keybindings = {
        { { modkey }, 'Tab', alttabPrev },
        { { modkey, 'Shift' }, 'Tab', alttabNext },
    },

    stop_key = modkey,
    stop_event = 'release',
    stop_callback = function()
        Alttab:get():commit()
    end,
})

---------------------------------------
-- GLOBAL KEYS
---------------------------------------

keys.global = gears.table.join(

    -- ------------------
    -- Keygrabbers
    -- ------------------

    awful.key({ modkey }, 'Tab',
        function() 
            alttabKeygrabber:start()
            alttabPrev()
        end,
    { description = 'start alttab keygrabber, init prev' }),

    awful.key({ modkey, 'Shift' }, 'Tab',
        function() 
            alttabKeygrabber:start()
            alttabNext()
        end,
    { description = 'start alttab keygrabber, init next' }),
    
    -- ------------------
    -- System
    -- ------------------
    
    awful.key({ modkey, 'Control' }, 'r', 
        function()
            awesome.restart()
        end,
    {description = 'reload awesome'}),

    awful.key({ modkey, 'Shift' }, 'Escape',
        function()
            awesome.quit()
        end,
    {description = 'quit awesome'}),

    -- ------------------
    -- Volume
    -- ------------------

    awful.key({ }, 'XF86AudioLowerVolume', 
        function()
            local set_vol_cmd = [[ amixer sset -D pulse Master 6%- ]]
            awful.spawn.easy_async_with_shell(set_vol_cmd, function()
                notifier:volume()
            end)
        end,
    {description = 'lower volume'}),

    awful.key({ }, 'XF86AudioRaiseVolume',
        function()
            local set_vol_cmd = [[ amixer sset -D pulse Master 6%+ ]]
            awful.spawn.easy_async_with_shell(set_vol_cmd, function()
                notifier:volume()
            end)
        end,
    {description = 'raise volume'}),

    awful.key({ }, 'XF86AudioMute',
        function()
            awful.spawn.with_shell('amixer -D pulse set Master 1+ toggle')
            notifier:volume()
        end,
    {description = 'toggle mute volume'}),

    -- ------------------
    -- Brightness
    -- ----------
    -- Note: xbacklight is SLOW. If we wait for xbacklight to finish before
    -- sending the notification, there is a considerable amount of lag. Thus,
    -- we precompute the new brightness percentage when sending the notification
    -- and only change it after.
    -- ------------------

    awful.key({ }, 'XF86MonBrightnessDown',
        function()
            notifier:brightness('-', 6)
            awful.spawn.with_shell([[ xbacklight -6 ]])
        end,
    {description = 'lower brightness'}),

    awful.key({ }, 'XF86MonBrightnessUp',
        function()
            notifier:brightness('+', 6)
            awful.spawn.with_shell([[ xbacklight +6 ]])
        end,
    {description = 'raise brightness'}),

    -- ------------------
    -- Keyboard
    -- ------------------

    awful.key({ 'Control' }, ' ', 
        function()
            notifier:keyboard()
        end,
    {description = 'change keyboard'}),

    -- ------------------
    -- Movement
    -- ------------------
    
    awful.key({ modkey }, 'h',
        function()
            awful.client.focus.bydirection('left')
        end,
    {description = 'focus client left'}),

    awful.key({ modkey }, 'j',
        function()
            awful.client.focus.bydirection('down')
        end,
    {description = 'focus client down'}),

    awful.key({ modkey }, 'k',
        function()
            awful.client.focus.bydirection('up')
        end,
    {description = 'focus client up'}),

    awful.key({ modkey }, 'l',
        function()
            awful.client.focus.bydirection('right')
        end,
    {description = 'focus client right'}),

    awful.key({ modkey, 'Shift' }, 'h',
        function()
            awful.client.swap.bydirection('left')
        end,
    {description = 'swap client left'}),

    awful.key({ modkey, 'Shift' }, 'j',
        function()
            awful.client.swap.bydirection('down')
        end,
    {description = 'swap client down'}),

    awful.key({ modkey, 'Shift' }, 'k',
        function()
            awful.client.swap.bydirection('up')
        end,
    {description = 'swap client up'}),

    awful.key({ modkey, 'Shift' }, 'l',
        function()
            awful.client.swap.bydirection('right')
        end,
    {description = 'swap client right'}),

    awful.key({ modkey, 'Control' }, 'h',
        function()
            awful.screen.focus_bydirection('left')
        end,
    {description = 'focus screen left'}),

    awful.key({ modkey, 'Control' }, 'j',
        function()
            awful.screen.focus_bydirection('down')
        end,
    {description = 'focus screen down'}),

    awful.key({ modkey, 'Control' }, 'k',
        function()
            awful.screen.focus_bydirection('up')
        end,
    {description = 'focus screen up'}),

    awful.key({ modkey, 'Control' }, 'l',
        function()
            awful.screen.focus_bydirection('right')
        end,
    {description = 'focus screen right'}),

    -- ------------------
    -- Layout
    -- ------------------

    awful.key({ modkey, 'Shift', 'Control' }, 'h',
        function()
            awful.tag.incmwfact(-0.05)
        end,
    {description = 'decrease master width'}),

    awful.key({ modkey, 'Shift', 'Control' }, 'l',
        function()
            awful.tag.incmwfact(0.05)
        end,
    {description = 'increase master width'}),

    awful.key({ modkey }, ',', 
        function ()
            awful.layout.inc(1)
        end,
    {description = 'next layout'}),

    awful.key({ modkey, 'Shift' }, 'm',
        function()
            clientbuffer:pop()
        end,
    {description = 'restore client'}),

    -- ------------------
    -- Spawners
    -- ------------------
    
    awful.key({ modkey }, 'd',
        function()
            awful.spawn.with_shell('$DOTS/rofi/scripts/dmenu')
        end,
    {description = 'spawn custom dmenu'}),

    awful.key({ modkey }, 'Return',
        function()
            awful.spawn(terminal)
        end,
    {description = 'open terminal'}),

    awful.key({ modkey }, "'",
        function()
            awful.spawn('firefox')
        end,
    {description = 'open browser'})
)

---------------------------------------
-- TAG KEYS
---------------------------------------

for i = 1, 9 do
    keys.global = gears.table.join(keys.global,
        awful.key({ modkey }, i,
            function ()
                local tag = awful.screen.focused().tags[i]
                if tag then tag:view_only() end
            end,
        {description = 'view tag'}),

        awful.key({ modkey, 'Shift' }, i,
            function ()
                local tag = awful.screen.focused().tags[i]
                if tag then awful.tag.viewtoggle(tag) end
            end,
        {description = 'toggle tag'})
    )
end

---------------------------------------
-- CLIENT KEYS
---------------------------------------

keys.client = gears.table.join(

    -- ------------------
    -- System
    -- ------------------

    awful.key({ modkey, 'Shift' }, 'q',
        function(c)
            c:kill()
        end,
    {description = 'close client'}),


    -- ------------------
    -- Layout
    -- ------------------

    awful.key({ modkey }, 'f',
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
    {description = 'toggle fullscreen'}),

    awful.key({ modkey }, 'm',
        function(c)
            clientbuffer:push(c)
        end,
    {description = 'store client'}),

    -- ------------------
    -- Debugging
    -- ------------------

    awful.key({ modkey, 'Shift' }, 'i',
        function(c)
            local info = { 'name', 'class', 'role' }
            local msg = ''
            
            for i, prop in pairs(info) do
                msg = string.format('%s%s: %s', msg, prop, c[prop])
                if i ~= #info then msg = msg .. '\n' end
            end

            naughty.notify({text = msg })
        end,
    {description = 'print client info'})
)

---------------------------------------
-- RETURN
---------------------------------------

return keys
