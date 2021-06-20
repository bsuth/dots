local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')

-- Autofocus another client when the current one is closed
require('awful/autofocus')

-- Order matters here!
require('theme')
local TagTabs = require('TagTabs')
local bindings = require('bindings')

--
-- Layout
--

awful.layout.layouts = {
  {
    name = 'mylayout',
    arrange = function(p)
      if #p.clients < 4 then
        awful.layout.suit.spiral.dwindle.arrange(p)
      else
        awful.layout.suit.fair.horizontal.arrange(p)
      end
    end,
  },
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

      floating = false,
      maximized = false,

      focus = awful.client.focus.filter,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    },
  },

  {
    rule_any = {
      type = {
        'dialog',
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

--
-- Startup
--

awful.screen.connect_for_each_screen(function(s)
  awful.tag({ '1' }, s, awful.layout.layouts[1])

  beautiful.set_wallpaper(s)
  s.tagTabs = TagTabs(s)

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

awful.clientbuffer = awful.tag.add('_clientbuffer', {
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
