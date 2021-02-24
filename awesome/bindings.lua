local awful = require 'awful' 
local dashboard = require 'dashboard'
local gears = require 'gears' 
local models = require 'models'
local naughty = require 'naughty' 
local taglist = require 'taglist'

--------------------------------------------------------------------------------
-- KEYBINDINGS
--------------------------------------------------------------------------------

local bindings = {}
local restore_tag = nil

awesome.connect_signal('startup', function()
    for s in screen do
        for _, tag in ipairs(s.tags) do
			for _, c in ipairs(tag:clients()) do
				if c.minimized then
			        c:move_to_tag(awful.clientbuffer)
				end
			end
		end
    end
end)

--------------------------------------------------------------------------------
-- ALT TAB
--------------------------------------------------------------------------------

local function alt_tab(idx)
	awful.tag.history.restore()
end

awful.keygrabber {
    keybindings = {
        {{ 'Mod1' }, 'Tab', function() alt_tab(1) end},
        {{ 'Mod1', 'Shift' }, 'Tab', function() alt_tab(-1) end},
    },

    stop_key = 'Mod1',
    stop_event = 'release',

    start_callback = awful.client.focus.history.disable_tracking,
    stop_callback = awful.client.focus.history.enable_tracking,

    export_keybindings = true,
}

--------------------------------------------------------------------------------
-- GLOBAL KEYS
--------------------------------------------------------------------------------

bindings.globalkeys = gears.table.join(
    
    -- -------------------------------------------------------------------------
    -- System
    -- -------------------------------------------------------------------------
    
    awful.key({ 'Mod4', 'Shift' }, 'r', function() awesome.restart() end),
    awful.key({ 'Mod4', 'Shift' }, 'Escape', function() awesome.quit() end),

    awful.key({ }, 'XF86AudioLowerVolume', function() models.volume:set(models.volume.percent - 5) end),
    awful.key({ }, 'XF86AudioRaiseVolume', function() models.volume:set(models.volume.percent + 5) end),
    awful.key({ }, 'XF86AudioMute', function() models.volume:toggle() end),

    awful.key({ }, 'XF86MonBrightnessDown', function() models.brightness:set(models.brightness.percent - 8) end),
    awful.key({ }, 'XF86MonBrightnessUp', function() models.brightness:set(models.brightness.percent + 8) end),

    awful.key({ 'Mod4', 'Control' }, 'space', function() models.kb_layout:cycle() end),

    -- -------------------------------------------------------------------------
    -- Movement
    -- -------------------------------------------------------------------------
    
    awful.key({ 'Mod4' }, 'h', function() awful.client.focus.global_bydirection('left') end),
    awful.key({ 'Mod4' }, 'j', function() awful.client.focus.global_bydirection('down') end),
    awful.key({ 'Mod4' }, 'k', function() awful.client.focus.global_bydirection('up') end),
    awful.key({ 'Mod4' }, 'l', function() awful.client.focus.global_bydirection('right') end),

    awful.key({ 'Mod4', 'Shift' }, 'h', function() awful.client.swap.global_bydirection('left') end),
    awful.key({ 'Mod4', 'Shift' }, 'j', function() awful.client.swap.global_bydirection('down') end),
    awful.key({ 'Mod4', 'Shift' }, 'k', function() awful.client.swap.global_bydirection('up') end),
    awful.key({ 'Mod4', 'Shift' }, 'l', function() awful.client.swap.global_bydirection('right') end),

    awful.key({ 'Mod4' }, ";", function()
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

    awful.key({ 'Mod4', 'Shift', 'Control' }, 'h', function() awful.tag.incmwfact(-0.05) end),
    awful.key({ 'Mod4', 'Shift', 'Control' }, 'l', function() awful.tag.incmwfact(0.05) end),
    awful.key({ 'Mod4' }, ',', function () awful.layout.inc(1) end),
    awful.key({ 'Mod4', 'Shift' }, 'm', function()
        local clients = awful.clientbuffer:clients()
		if #clients > 0 then
			local c = clients[#clients]
			c:move_to_tag(awful.screen.focused().selected_tag)
			c.minimized = false
			client.focus = c
		end
	end),

    -- -------------------------------------------------------------------------
    -- Apps
    -- -------------------------------------------------------------------------

    awful.key({ 'Mod4' }, 'space', function() awful.spawn('rofi -show run') end),

    -- -------------------------------------------------------------------------
    -- Spawners
    -- -------------------------------------------------------------------------
    
    awful.key({ 'Mod4' }, 'Return', function() awful.spawn('gnome-terminal') end),
    awful.key({ 'Mod4' }, "'", function() awful.spawn('vivaldi') end),
    awful.key({ 'Mod4' }, 'p', function() dashboard.toggle() end),
    awful.key({ 'Mod4' }, 'n', function() taglist.toggle() end)
)

for i = 1, 9 do
    bindings.globalkeys = gears.table.join(bindings.globalkeys,
        awful.key({ 'Mod4' }, "#" .. i + 9, function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]

            if tag then
                tag:view_only()
            end
        end)
    )
end

--------------------------------------------------------------------------------
-- CLIENT KEYS
--------------------------------------------------------------------------------

bindings.clientkeys = gears.table.join(

    -- -------------------------------------------------------------------------
    -- System
    -- -------------------------------------------------------------------------

    awful.key({ 'Mod4', 'Shift' }, 'q', function(c) c:kill() end),

    awful.key({ 'Mod4', 'Mod1', 'Shift' }, 'i', function(c)
        local msg = 'name: ' .. c.name

        local attrs= { 
            'instance',
            'class',
            'role',
            'type',
            'floating',
            'maximized',
        }

        for i, attr in ipairs(attrs) do
            msg = ("%s\n%s: %s"):format(msg, attr, c[attr])
        end

        naughty.notify {text = msg}
    end),

    -- -------------------------------------------------------------------------
    -- Layout
    -- -------------------------------------------------------------------------

    awful.key({ 'Mod4' }, 'f', function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end),

    awful.key({ 'Mod4' }, 'm', function(c)
		c:move_to_tag(awful.clientbuffer)
		c.minimized = true
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

    awful.button({ 'Mod1', 'Control' }, 1, function (c)
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

root.keys(bindings.globalkeys)
return bindings
