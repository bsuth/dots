
local gears = require('gears')
local awful = require('awful')
local wibox = require('wibox')
local naughty = require('naughty')
local utils = require('utils')

local notifymanager = require('widgets.notifymanager')
local clientbuffer = require('widgets.clientbuffer')


---------------------------------------
-- INIT
---------------------------------------

local keys = {
    state = {
        kb_layout = 1,
    }
}

local modkey = 'Mod4'


---------------------------------------
-- KEYGRABBERS
---------------------------------------

-- ------------------
-- Tagger
-- ------------------

local function taggerPrev()
    awful.screen.focused().tagger:prev() 
end

local function taggerNext()
    awful.screen.focused().tagger:next() 
end

local taggerKeygrabber = awful.keygrabber({
    keybindings = {
        { { modkey }, 'Tab', taggerPrev },
        { { modkey, 'Shift' }, 'Tab', taggerNext },
    },

    stop_key = modkey,
    stop_event = 'release',
    stop_callback = function()
        awful.screen.focused().tagger:commit()
    end,
})

-- ------------------
-- Tabtile
-- ------------------

local function tabtilePrev()
    awful.screen.focused().selected_tag.layout.api:prev() 
end

local function tabtileNext()
    awful.screen.focused().selected_tag.layout.api:next() 
end

local tabtileCycleKeygrabber = awful.keygrabber({
    keybindings = {
        { { modkey }, ' ', tabtilePrev },
        { { modkey, 'Shift' }, ' ', tabtileNext },
    },

    stop_key = modkey,
    stop_event = 'release',
    stop_callback = function()
        awful.screen.focused().selected_tag.layout.api:commit() 
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
            taggerKeygrabber:start()
            taggerPrev()
        end,
    { description = 'start tagger keygrabber, init prev' }),

    awful.key({ modkey, 'Shift' }, 'Tab',
        function() 
            taggerKeygrabber:start()
            taggerNext()
        end,
    { description = 'start tagger keygrabber, init next' }),

    awful.key({ modkey }, ' ',
        function() 
            tabtileCycleKeygrabber:start()
            tabtilePrev()
        end,
    {description = 'start tabtile keygrabber, init prev'}),

    awful.key({ modkey, 'Shift' }, ' ',
        function() 
            tabtileCycleKeygrabber:start()
            tabtileNext()
        end,
    {description = 'start tabtile keygrabber, init next'}),

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
            -- local layout = awful.screen.focused().selected_tag.layout
            -- return layout.api.client_mv_rel_dir and
            --     layout.api:client_mv_rel_dir(client.focus, 'left') or
            --     awful.client.swap.bydirection('left')
        end,
    {description = 'swap client left'}),

    awful.key({ modkey, 'Shift' }, 'j',
        function()
            awful.client.swap.bydirection('down')
            -- local layout = awful.screen.focused().selected_tag.layout
            -- return layout.api.client_mv_rel_dir and
            --     layout.api:client_mv_rel_dir(client.focus, 'down') or
            --     awful.client.swap.bydirection('down')
        end,
    {description = 'swap client down'}),

    awful.key({ modkey, 'Shift' }, 'k',
        function()
            awful.client.swap.bydirection('up')
            -- local layout = awful.screen.focused().selected_tag.layout
            -- return layout.api.client_mv_rel_dir and
            --     layout.api:client_mv_rel_dir(client.focus, 'up') or
            --     awful.client.swap.bydirection('up')
        end,
    {description = 'swap client up'}),

    awful.key({ modkey, 'Shift' }, 'l',
        function()
            awful.client.swap.bydirection('right')
            -- local layout = awful.screen.focused().selected_tag.layout
            -- return layout.api.client_mv_rel_dir and
            --     layout.api:client_mv_rel_dir('right', client.focus) or
            --     awful.client.swap.bydirection('right')
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

    awful.key({ modkey, 'Shift', 'Control' }, 'j',
        function()
            local layout = awful.screen.focused().selected_tag.layout
            layout.api:incnmaster(-1)
        end,
    {description = 'decrement master_count'}),

    awful.key({ modkey, 'Shift', 'Control' }, 'k',
        function()
            local layout = awful.screen.focused().selected_tag.layout
            layout.api:incnmaster(1)
        end,
    {description = 'increment master_count'}),

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

    -- ------------------
    -- Tags
    -- ------------------

    awful.key({ modkey }, '=',
        function()
            awful.screen.focused().tagger:push()
        end,
    {description = 'spawn a new tag'}),

    awful.key({ modkey }, '-',
        function()
            awful.screen.focused().tagger:pop()
        end,
    {description = 'remove a tag'}),

    awful.key({ modkey }, 'n',
        function()
            clientbuffer.pop()
        end,
    {description = 'restore client'}),

    -- ------------------
    -- test
    -- ------------------
    awful.key({ modkey }, 'r',
        function()
            awful.layout.inc(1)
        end,
    {description = 'test: change layout'}),
    awful.key({ modkey, 'Shift' }, 'r',
        function()
            local clients = awful.screen.focused().selected_tag.layout.api.state.masters[1].client_stack
            for i = 1, #clients do
                if not clients[i].valid then
                    naughty.notify({ text = 'hi' })
                else
                    naughty.notify({ text = tostring(clients[i]) })
                end
            end
        end,
    {description = 'test: change layout'}),
    
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
-- CLIENT KEYS
---------------------------------------

keys.client = gears.table.join(

    -- ------------------
    -- System
    -- ------------------

    awful.key({ modkey, 'Shift' }, 'q',
        function(c)
            return c.tabtile_kill and c.tabtile_kill() or c:kill()
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
            clientbuffer.push(c)
        end,
    {description = 'store client'})
)


---------------------------------------
-- RETURN
---------------------------------------

return keys

