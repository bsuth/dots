local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

local layouts = require('layouts')
local wgrid = require('widgets.grid')

--------------------------------------------------------------------------------
-- COMMANDS
--------------------------------------------------------------------------------

local commands = {
    {
        alias = 'music',
        callback = function()
			for s in screen do
				local music_tag = awful.tag.find_by_name(s, 'music')
				local music_clients = {
					['st-256color'] = 'st -e cava',
					['Google-chrome'] = 'google-chrome-stable --app="https://music.youtube.com"',
				}

				if music_tag ~= nil then
					local clients = music_tag:clients()

					for _, existing_client in ipairs(music_tag:clients()) do
						music_clients[existing_client.class] = nil
					end

					for _, missing_client in pairs(music_clients) do
						awful.spawn(missing_client)
					end

					music_tag.screen = awful.screen.focused()
					music_tag:view_only()
					return
				end
			end
        end,
    },
    {
        alias = 'db',
        callback = function()
            awful.spawn('st -e nvim -c ":DBUI"')
        end,
    },
    {
        alias = 'sleep',
        callback = function()
            awful.spawn('systemctl suspend')
        end,
    },
    {
        alias = 'reboot',
        callback = function()
            awful.spawn('reboot')
        end,
    },
    {
        alias = 'poweroff',
        callback = function()
            awful.spawn('poweroff')
        end,
    },
}

for _, command in ipairs(require('__config/dmenu')) do
	table.insert(commands, command)
end

local command_widgets = {}

--------------------------------------------------------------------------------
-- FILTER
--------------------------------------------------------------------------------

local filter = wibox.widget({
    markup = '',
    forced_height = 100,
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
})

--------------------------------------------------------------------------------
-- GRID
--------------------------------------------------------------------------------

local grid = wgrid.grid({
    forced_num_cols = 3,
    expand = true,
    vertical_expand = false,
    spacing = 10,
    homogeneous = true,
})

for _, command in ipairs(commands) do
    local w = wibox.widget({
        {
            markup = command.alias,
            align  = 'center',
            valign = 'center',
            widget = wibox.widget.textbox,
        },

        forced_height = 100,

        shape = gears.shape.rectangle,
        shape_border_width = 5,
        shape_border_color = beautiful.colors.dark_grey,

        filter = command.alias,
        callback = command.callback,
        widget = wibox.container.background,
    })

    grid:add(w)
    table.insert(command_widgets, w)
end

--------------------------------------------------------------------------------
-- CONTENT (FILTER + GRID WRAPPER)
--------------------------------------------------------------------------------

local content = wibox.widget({
    filter,
    {
        {
            span_ratio = 0.5,
            forced_height = 5,
            thickness = 5,
            color = beautiful.colors.dark_grey,
            widget = wibox.widget.separator,
        },

        bottom = 50,
        layout = wibox.container.margin,
    },
    grid,

    expand = 'outside',
    layout = wibox.layout.fixed.vertical,
})

--------------------------------------------------------------------------------
-- POPUP (MAIN WRAPPER)
--------------------------------------------------------------------------------

local popup = awful.popup({
    widget = {
        content,
        valign = 'center',
        halign = 'center',
        widget = wibox.container.place,
    },

    ontop = true,
    visible = false,
    bg = '#000000e8',
})

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function apply_filter()
    grid:reset()

    for _, w in pairs(command_widgets) do
        if w.filter:sub(1, #filter.markup) == filter.markup then
            grid:add(w)
        end
    end

    grid:default_focus()
end

--------------------------------------------------------------------------------
-- KEYGRABBER
--------------------------------------------------------------------------------

local modkey = 'Mod4'

return awful.keygrabber({
    keybindings = {
        {{ modkey }, 'h', function() grid:focus_by_direction('left') end},
        {{ modkey }, 'j', function() grid:focus_by_direction('down') end},
        {{ modkey }, 'k', function() grid:focus_by_direction('up') end},
        {{ modkey }, 'l', function() grid:focus_by_direction('right') end},
        {{ modkey }, 'd', function(self) self:stop() end},
        {{ 'Control' }, 'u', function() filter.markup = ''; apply_filter(true) end},
        {{ 'Control' }, 'bracketleft', function(self) self:stop() end},
        {{ }, 'Escape', function(self) self:stop() end},
        {{ }, 'Return', function(self)
			popup.visible = false -- need this for flameshot
			grid.focused_widget.callback()
			self:stop()
		end},
    },

    start_callback = function()
        local s = awful.screen.focused()

        popup.screen = s
        popup.minimum_width = s.geometry.width
        popup.minimum_height = s.geometry.height
        popup.visible = true

        content.forced_width = 0.6 * s.geometry.width
        content.forced_height = 0.6 * s.geometry.height

        grid:default_focus()
    end,

    stop_callback = function()
        popup.visible = false
        filter.markup = ''
        apply_filter()
    end,

    keypressed_callback = function(self, mods, key)
        if key == 'BackSpace' and #filter.markup > 0 then
            filter.markup = filter.markup:sub(1, #filter.markup - 1)
            apply_filter()
        elseif #mods == 0 and key:match('^[a-zA-Z ]$') then
            filter.markup = filter.markup .. key
            apply_filter()
        end
    end,
})
