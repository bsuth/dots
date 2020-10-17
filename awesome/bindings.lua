local awful = require 'awful' 
local gears = require 'gears' 
local naughty = require 'naughty' 

local dashboard = require 'apps/dashboard' 
local dmenu = require 'apps/dmenu' 
local tag_manager = require 'apps/tag_manager' 
local kb_switcher = require 'apps/kb_switcher' 

local volume = require 'singletons/volume'
local brightness = require 'singletons/brightness'

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

local modkey = 'Mod4'
local bindings = { modkey = modkey }

local restore_tag = nil
local clientbuffer = {}

awesome.connect_signal('startup', function()
    for s in screen do
        for _, c in ipairs(s.tags[1]:clients()) do
            if c.minimized == true then
                table.insert(clientbuffer, c)
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- GLOBAL KEYS
--------------------------------------------------------------------------------

bindings.globalkeys = gears.table.join(
    
    -- -------------------------------------------------------------------------
    -- System
    -- -------------------------------------------------------------------------
    
    awful.key({ modkey, 'Shift' }, 'r', function() awesome.restart() end),
    awful.key({ modkey, 'Shift' }, 'Escape', function() awesome.quit() end),

    awful.key({ }, 'XF86AudioLowerVolume', function() volume:shift(-5) end),
    awful.key({ }, 'XF86AudioRaiseVolume', function() volume:shift(5) end),
    awful.key({ }, 'XF86AudioMute', function() volume:toggle() end),

    awful.key({ }, 'XF86MonBrightnessDown', function() brightness:shift(-8) end),
    awful.key({ }, 'XF86MonBrightnessUp', function() brightness:shift(8) end),

    awful.key({ 'Control' }, 'space', function() kb_switcher:start() end),

    -- -------------------------------------------------------------------------
    -- Movement
    -- -------------------------------------------------------------------------
    
    awful.key({ modkey }, 'h', function() awful.client.focus.bydirection('left') end),
    awful.key({ modkey }, 'j', function() awful.client.focus.bydirection('down') end),
    awful.key({ modkey }, 'k', function() awful.client.focus.bydirection('up') end),
    awful.key({ modkey }, 'l', function() awful.client.focus.bydirection('right') end),

    awful.key({ modkey, 'Shift' }, 'h', function() awful.client.swap.bydirection('left') end),
    awful.key({ modkey, 'Shift' }, 'j', function() awful.client.swap.bydirection('down') end),
    awful.key({ modkey, 'Shift' }, 'k', function() awful.client.swap.bydirection('up') end),
    awful.key({ modkey, 'Shift' }, 'l', function() awful.client.swap.bydirection('right') end),

    awful.key({ modkey, 'Control' }, 'h', function() awful.screen.focus_bydirection('left') end),
    awful.key({ modkey, 'Control' }, 'j', function() awful.screen.focus_bydirection('down') end),
    awful.key({ modkey, 'Control' }, 'k', function() awful.screen.focus_bydirection('up') end),
    awful.key({ modkey, 'Control' }, 'l', function() awful.screen.focus_bydirection('right') end),

    awful.key({ modkey }, ";",
        function()
            local current_screen = awful.screen.focused()

            if current_screen.selected_tag.name ~= 'music' then
                for s in screen do
                    local music_tag = awful.tag.find_by_name(s, 'music')
                    local music_clients = {
                        ['Google-chrome'] = 'google-chrome-stable --app="https://open.spotify.com"',
                    }

                    if music_tag ~= nil then
                        local clients = music_tag:clients()

                        for _, existing_client in ipairs(music_tag:clients()) do
                            music_clients[existing_client.class] = nil
                        end

                        for _, missing_client in pairs(music_clients) do
                            awful.spawn(missing_client)
                        end

                        restore_tag = current_screen.selected_tag
                        music_tag.screen = current_screen 
                        music_tag:view_only()
                        break
                    end
                end
            elseif restore_tag ~= nil then
                restore_tag:view_only()
                restore_tag = nil
            end
        end,
    {description = 'toggle music'}),

    -- -------------------------------------------------------------------------
    -- Layout
    -- -------------------------------------------------------------------------

    awful.key({ modkey, 'Shift', 'Control' }, 'h', function() awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, 'Shift', 'Control' }, 'l', function() awful.tag.incmwfact(0.05) end),
    awful.key({ modkey }, ',', function () awful.layout.inc(1) end),

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

    -- -------------------------------------------------------------------------
    -- Apps
    -- -------------------------------------------------------------------------

    awful.key({ modkey }, 'd', function() dmenu:start() end),
    awful.key({ modkey }, 'space', function() dashboard.start() end),
    awful.key({ modkey }, 'Alt_L', function() tag_manager.keygrabber:start() end),
    awful.key({ modkey, 'Shift' }, '=', function() tag_manager.api.add(true) end),
    awful.key({ modkey }, '-', function() tag_manager.api.remove() end),

    -- -------------------------------------------------------------------------
    -- Spawners
    -- -------------------------------------------------------------------------
    
    awful.key({ modkey }, 'Return', function() awful.spawn('st -e nvim -c ":Dirvish"') end),
    awful.key({ modkey }, "'", function() awful.spawn('google-chrome-stable') end)
)

--------------------------------------------------------------------------------
-- CLIENT KEYS
--------------------------------------------------------------------------------

bindings.clientkeys = gears.table.join(

    -- -------------------------------------------------------------------------
    -- System
    -- -------------------------------------------------------------------------

    awful.key({ modkey, 'Shift' }, 'q', function(c) c:kill() end),

    -- -------------------------------------------------------------------------
    -- Layout
    -- -------------------------------------------------------------------------

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

            -- Move to first tag to properly allow for automatic tag removal
            c:move_to_tag(awful.screen.focused().tags[1])
        end,
    {description = 'store client'})
)

--------------------------------------------------------------------------------
-- GLOBAL BUTTONS
--------------------------------------------------------------------------------

bindings.globalbuttons = gears.table.join(
)

--------------------------------------------------------------------------------
-- CLIENT BUTTONS
--------------------------------------------------------------------------------

bindings.clientbuttons = gears.table.join(

    -- -------------------------------------------------------------------------
    -- Move/Resize
    -- -------------------------------------------------------------------------

    awful.button({ }, 1, function (c)
        c:emit_signal('request::activate', 'mouse_click', {raise = true})
    end),

    awful.button({ 'Shift' }, 1, function (c)
        c:emit_signal('request::activate', 'mouse_click', {raise = true})
        awful.mouse.client.move(c)
    end),

    awful.button({ 'Control', 'Shift' }, 1, function (c)
        c:emit_signal('request::activate', 'mouse_click', {raise = true})
        awful.mouse.client.resize(c)
    end)
)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return bindings
