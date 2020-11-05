local awful = require 'awful' 
local gears = require 'gears' 
local naughty = require 'naughty' 

local dashboard = require 'apps/dashboard' 
local tag_manager = require 'apps/tag_manager' 
local kb_switcher = require 'apps/kb_switcher' 

local volume = require 'models/volume'
local brightness = require 'models/brightness'

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

local modkey = 'Mod4'
local bindings = { modkey = modkey }

local restore_tag = nil

local clientbuffer = {}

awesome.connect_signal('startup', function()
    for s in screen do
        for _, tag in ipairs(s.tags) do
			for _, c in ipairs(tag:clients()) do
				if c.minimized then
					table.insert(_state.clients, c)
				end
			end
		end
    end
end)

--------------------------------------------------------------------------------
-- ALT TAB
--------------------------------------------------------------------------------

awful.keygrabber({
    keybindings = {
        {{ 'Mod1' }, 'Tab', function() awful.client.focus.byidx(1) end},
        {{ 'Mod1', 'Shift' }, 'Tab', function() awful.client.focus.byidx(-1) end},
    },

    -- Note that it is using the key name and not the modifier name.
    stop_key = 'Mod1',
    stop_event = 'release',

    start_callback = awful.client.focus.history.disable_tracking,
    stop_callback = awful.client.focus.history.enable_tracking,

    export_keybindings = true,
})

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

    awful.key({ modkey, 'Control' }, 'space', function() kb_switcher:start() end),

    -- -------------------------------------------------------------------------
    -- Movement
    -- -------------------------------------------------------------------------
    
    awful.key({ modkey }, 'h', function() awful.client.focus.global_bydirection('left') end),
    awful.key({ modkey }, 'j', function() awful.client.focus.global_bydirection('down') end),
    awful.key({ modkey }, 'k', function() awful.client.focus.global_bydirection('up') end),
    awful.key({ modkey }, 'l', function() awful.client.focus.global_bydirection('right') end),

    awful.key({ modkey, 'Shift' }, 'h', function() awful.client.swap.global_bydirection('left') end),
    awful.key({ modkey, 'Shift' }, 'j', function() awful.client.swap.global_bydirection('down') end),
    awful.key({ modkey, 'Shift' }, 'k', function() awful.client.swap.global_bydirection('up') end),
    awful.key({ modkey, 'Shift' }, 'l', function() awful.client.swap.global_bydirection('right') end),

    awful.key({ modkey }, ";", function()
		local current_screen = awful.screen.focused()

		if current_screen.selected_tag.name ~= 'scratchpad' then
			for s in screen do
				local scratchpad = awful.tag.find_by_name(s, 'scratchpad')

				if scratchpad ~= nil then
					restore_tag = current_screen.selected_tag
					scratchpad.screen = current_screen 
					scratchpad:view_only()
					break
				end
			end
		elseif restore_tag ~= nil then
			restore_tag:view_only()
			restore_tag = nil
		end
	end),

    -- -------------------------------------------------------------------------
    -- Layout
    -- -------------------------------------------------------------------------

    awful.key({ modkey, 'Shift', 'Control' }, 'h', function() awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, 'Shift', 'Control' }, 'l', function() awful.tag.incmwfact(0.05) end),
    awful.key({ modkey }, ',', function () awful.layout.inc(1) end),
    awful.key({ modkey, 'Shift' }, 'm', function()
		if #clientbuffer > 0 then
			local c = table.remove(clientbuffer)
			c:move_to_tag(awful.screen.focused().selected_tag)
			c.minimized = false
			client.focus = c
		end
	end),

    -- -------------------------------------------------------------------------
    -- Apps
    -- -------------------------------------------------------------------------

    awful.key({ modkey }, 'space', function() dashboard.start() end),
    awful.key({ modkey }, 'Alt_L', function() tag_manager.keygrabber:start() end),
    awful.key({ modkey, 'Shift' }, '=', function() tag_manager.api.add(true) end),
    awful.key({ modkey }, '-', function() tag_manager.api.remove() end),

    -- -------------------------------------------------------------------------
    -- Spawners
    -- -------------------------------------------------------------------------
    
    awful.key({ modkey }, 'Return', function() awful.spawn('st -e nvim -c ":Dirvish"') end),
    awful.key({ modkey }, "'", function() awful.spawn('vivaldi') end)
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

    awful.key({ modkey }, 'm', function(c)
		table.insert(clientbuffer, c)
		c.minimized = true

		-- Move to first tag to properly allow for automatic tag removal
		c:move_to_tag(awful.screen.focused().tags[1])
	end)
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

    -- awful.button({ 'Shift' }, 1, function (c)
    --     c:emit_signal('request::activate', 'mouse_click', {raise = true})
    --     awful.mouse.client.move(c)
    -- end),

    awful.button({ 'Control', 'Shift' }, 1, function (c)
        c:emit_signal('request::activate', 'mouse_click', {raise = true})
        awful.mouse.client.resize(c)
    end)
)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return bindings
