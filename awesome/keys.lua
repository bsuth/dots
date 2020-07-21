local awful = require('awful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

local db = require('dashboard')
local dmenu = require('dmenu')
local notifier = require('widgets.notifier')

--------------------------------------------------------------------------------
-- INIT/STATE
--------------------------------------------------------------------------------

local keys = {}
local modkey = 'Mod4'

local clientbuffer = {}

--------------------------------------------------------------------------------
-- GLOBAL KEYS
--------------------------------------------------------------------------------

keys.global = gears.table.join(
    
    -- ------------------
    -- System
    -- ------------------
    
    awful.key({ modkey, 'Shift' }, 'r', 
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
            if #clientbuffer > 0 then
                local c = table.remove(clientbuffer)
                c:move_to_tag(awful.screen.focused().selected_tag)
                c.minimized = false
                client.focus = c
            end
        end,
    {description = 'restore client'}),

    -- ------------------
    -- Spawners
    -- ------------------

    awful.key({ modkey }, 'Alt_L',
        function()
            awful.screen.focused().tagger.kg:start()
        end,
    {description = 'spawn tagger'}),
    
    awful.key({ modkey }, 'd',
        function()
            dmenu:start()
        end,
    {description = 'spawn custom dmenu'}),

    awful.key({ modkey }, ' ',
        function()
            db.kg:start()
        end,
    {description = 'spawn dashboard'}),

    awful.key({ modkey }, 'Return',
        function()
            awful.spawn('alacritty')
        end,
    {description = 'open terminal'}),

    awful.key({ modkey }, "'",
        function()
            awful.spawn('qutebrowser')
        end,
    {description = 'open browser'})
)

--------------------------------------------------------------------------------
-- TAG KEYS
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- CLIENT KEYS
--------------------------------------------------------------------------------

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
            table.insert(clientbuffer, c)
            c.minimized = true
        end,
    {description = 'store client'})
)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return keys
