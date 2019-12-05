
local gears = require('gears')
local awful = require('awful')
local wibox = require('wibox')
local naughty = require('naughty')
local utils = require('utils')

local notifymanager = require('widgets.notifymanager')

local keys = {}


---------------------------------------
-- SETTINGS
---------------------------------------

local modkey = 'Mod4'


---------------------------------------
-- HELPERS
---------------------------------------

function change_volume(dir)
    local set_vol_cmd = "amixer sset Master 4%" .. dir

    awful.spawn.easy_async_with_shell(set_vol_cmd, function()
        notifymanager:volume()
    end)
end


---------------------------------------
-- GLOBAL KEYS
---------------------------------------

keys.global = gears.table.join(

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
                notifymanager:volume()
            end)
        end,
    {description = 'lower volume'}),

    awful.key({ }, 'XF86AudioRaiseVolume',
        function()
            local set_vol_cmd = [[ amixer sset -D pulse Master 6%+ ]]
            awful.spawn.easy_async_with_shell(set_vol_cmd, function()
                notifymanager:volume()
            end)
        end,
    {description = 'raise volume'}),

    awful.key({ }, 'XF86AudioMute',
        function()
            awful.spawn.with_shell('amixer -D pulse set Master 1+ toggle')
            notifymanager.volume()
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
            notifymanager:brightness('-', 6)
            awful.spawn.with_shell([[ xbacklight -6 ]])
        end,
    {description = 'lower brightness'}),

    awful.key({ }, 'XF86MonBrightnessUp',
        function()
            notifymanager:brightness('+', 6)
            awful.spawn.with_shell([[ xbacklight +6 ]])
        end,
    {description = 'raise brightness'}),


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
            awful.screen.focus_bydirection('left')
        end,
    {description = 'focus screen down'}),

    awful.key({ modkey, 'Control' }, 'k',
        function()
            awful.screen.focus_relative(-1)
        end,
    {description = 'focus screen up'}),

    awful.key({ modkey, 'Control' }, 'l',
        function()
            awful.screen.focus_bydirection('right')
        end,
    {description = 'focus screen right'}),

    awful.key({ modkey, 'Shift', 'Control' }, 'h',
        function()
            awful.tag.incmwfact(-0.05)
        end,
    {description = 'decrease master width'}),

    awful.key({ modkey, 'Shift', 'Control' }, 'j',
        function()
            awful.tag.incncol(-1, nil, true)
        end,
    {description = 'decrease number of columns'}),

    awful.key({ modkey, 'Shift', 'Control' }, 'k',
        function()
            awful.tag.incncol(1, nil, true)
        end,
    {description = 'increase number of columns'}),

    awful.key({ modkey, 'Shift', 'Control' }, 'l',
        function()
            awful.tag.incmwfact(0.05)
        end,
    {description = 'increase master width'}),


    -- ------------------
    -- Tags
    -- ------------------

    awful.key({ modkey }, '=',
        function()
            awful.screen.focused().tagmanager:add()
        end,
    {description = 'spawn a new tag'}),

    awful.key({ modkey }, '-',
        function()
            awful.screen.focused().tagmanager:remove()
        end,
    {description = 'remove a tag'}),
    

    -- ------------------
    -- Spawners
    -- ------------------
    
    awful.key({ modkey }, 'd',
        function()
            awful.spawn.with_shell('$SCRIPTS_CORE/dmenu.sh')
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
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
    {description = '(un)maximize vertically'}),

    awful.key({ modkey, 'Shift' }, 'm',
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
    {description = '(un)maximize horizontal'})
)


---------------------------------------
-- KEYGRABBERS
---------------------------------------

awful.keygrabber({
    keybindings = {
        {{ modkey }, 'Tab', function() awful.screen.focused().tagmanager:view_prev() end},
    },

    start_callback = function() 
        awful.screen.focused().tagmanager.tagbar.visible = true
    end,

    stop_key = modkey,
    stop_event = 'release',
    stop_callback = function() 
        awful.screen.focused().tagmanager.history:commit() 
        awful.screen.focused().tagmanager.tagbar.visible = false 
    end,

    export_keybindings = true,
})


---------------------------------------
-- TAGS
---------------------------------------

-- Bind key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    keys.global = gears.table.join(keys.global,
        awful.key({ modkey }, '#' .. i + 9,
            function()
                local tag = awful.screen.focused().tags[i]

                if tag then
                    tag:view_only()
                end
            end,
        {description = 'switch to tag'}),

        awful.key({ modkey, 'Shift' }, '#' .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]

                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
        {description = 'move focused client to tag'}),

        awful.key({ modkey, 'Control' }, '#' .. i + 9,
            function ()
                local tag = awful.screen.focused().tags[i]

                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
        {description = 'toggle tag'})
    )
end


return keys

