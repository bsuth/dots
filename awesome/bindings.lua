local awful = require 'awful' 
local gears = require 'gears' 
local naughty = require 'naughty' 

local dashboard = require 'dashboard' 
local kb_switcher_view = require 'views/kb_switcher' 
local volume_model = require 'models/volume'
local brightness_model = require 'models/brightness'

--------------------------------------------------------------------------------
-- KEYBINDINGS
--------------------------------------------------------------------------------

local bindings = {
	restore_tag = nil,
}

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
    client.focus.above = false
    awful.client.focus.byidx(idx)
    client.focus.above = true
end

local function alt_backtick(idx)
    local s = awful.screen.focused()
    local n = tonumber(s.selected_tag.name)
    if n == nil then return end

    for i = idx, 7 * idx, idx do
        local tag = s.tags[1 + (n - 1 + i) % 9]
        if #tag:clients() > 0 then
            tag:view_only()
            return
        end
    end
end

awful.keygrabber({
    keybindings = {
        {{ submodkey }, 'Tab', function() alt_tab(1) end},
        {{ submodkey, 'Shift' }, 'Tab', function() alt_tab(-1) end},
        {{ submodkey }, '`', function() alt_backtick(1) end},
        {{ submodkey, 'Shift' }, '`', function() alt_backtick(-1) end},
    },

    stop_key = submodkey,
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

    awful.key({ }, 'XF86AudioLowerVolume', function() volume_model:shift(-5) end),
    awful.key({ }, 'XF86AudioRaiseVolume', function() volume_model:shift(5) end),
    awful.key({ }, 'XF86AudioMute', function() volume_model:toggle() end),

    awful.key({ }, 'XF86MonBrightnessDown', function() brightness_model:shift(-8) end),
    awful.key({ }, 'XF86MonBrightnessUp', function() brightness_model:shift(8) end),

    awful.key({ modkey, 'Control' }, 'space', function() kb_switcher_view:start() end),

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
					bindings.restore_tag = current_screen.selected_tag
					scratchpad.screen = current_screen 
					scratchpad:view_only()
					break
				end
			end
		elseif bindings.restore_tag ~= nil then
			bindings.restore_tag:view_only()
			bindings.restore_tag = nil
		end
	end),

    -- -------------------------------------------------------------------------
    -- Layout
    -- -------------------------------------------------------------------------

    awful.key({ modkey, 'Shift', 'Control' }, 'h', function() awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, 'Shift', 'Control' }, 'l', function() awful.tag.incmwfact(0.05) end),
    awful.key({ modkey }, ',', function () awful.layout.inc(1) end),
    awful.key({ modkey, 'Shift' }, 'm', function()
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

    awful.key({ modkey }, 'space', function() dashboard.start() end),
    -- awful.key({ modkey }, 'Alt_L', function() tag_manager_view:start() end),
    -- awful.key({ modkey, 'Shift' }, '=', function() tag_manager_model:add(true) end),

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

    awful.key({ modkey, submodkey, 'Shift' }, 'i', function(c)
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

        naughty.notify({text = msg})
    end),

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

    awful.button({ submodkey, 'Control' }, 1, function (c)
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

-- Bind all key numbers to tags.
for i = 1, 9 do
    bindings.globalkeys = gears.table.join(bindings.globalkeys,
        awful.key({ modkey }, "#" .. i + 9, function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]

            if tag then
                tag:view_only()
            end
        end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function ()
            local c = client.focus
            if c ~= nil then
                local tag = c.screen.tags[i]
                if tag then c:move_to_tag(tag) end
            end
        end)
    )
end

root.keys(bindings.globalkeys)
return bindings
