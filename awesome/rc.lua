local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')

-- Autofocus another client when the current one is closed
require('awful/autofocus')

-- Order matters here!
require('theme')
local taglist = require('taglist')
local TagTabber = require('TagTabber')
local bindings = require('bindings')

--
-- Layouts
--

awful.layout.layouts = {
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.magnifier,
}

--
-- Rules
--

awful.rules.rules = {
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,

      keys = bindings.clientkeys,
      buttons = bindings.clientbuttons,

      raise = true,
      floating = false,
      maximized = false,

      focus = awful.client.focus.filter,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    },
  },

  {
    rule_any = {
      instance = {
        'gcr-prompter', -- pass prompts
        'simplescreenrecorder',
        'gpick',
      },
      name = {
        'Event Tester', -- xev
      },
      role = {
        'pop-up', -- Google Chrome's (detached) Developer Tools.
      },
    },
    properties = {
      floating = true,
    },
  },
}

--
-- Signals
--

-- Signal function to execute when a new client appears.
client.connect_signal('manage', function(c)
  if awesome.startup then
    -- Prevent clients from being unreachable after screen count changes.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_offscreen(c)
    end
  else
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it as master.
    client.focus.above = false
    awful.client.setslave(c)
    c.above = true
  end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal('mouse::enter', function(c)
  c:emit_signal('request::activate', 'mouse_enter', { raise = false })
end)

-- Re-set wallpaper when screen geometry changes (e.g. resolution change)
screen.connect_signal('property::geometry', beautiful.set_wallpaper)

-- Focus changes border color
client.connect_signal('focus', function(c)
  c.border_color = beautiful.border_focus
end)
client.connect_signal('unfocus', function(c)
  c.border_color = beautiful.border_normal
end)

--
-- Startup
--

awful.screen.connect_for_each_screen(function(s)
  awful.tag(
    { '1', '2', '3', '4', '5', '6', '7', '8', '9' },
    s,
    awful.layout.layouts[1]
  )

  beautiful.set_wallpaper(s)
  s.tagTabber = TagTabber(s)

  s:connect_signal('tag::history::update', function()
    -- restore focus to above client
    for _, c in ipairs(s.selected_tag:clients()) do
      if c.above then
        c:emit_signal('request::activate')
        return
      end
    end
  end)
end)

awful.clientbuffer = awful.tag.add('clientbuffer', {
  layout = awful.layout.suit.fair.horizontal,
  screen = awful.screen.focused(),
})

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
