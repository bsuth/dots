local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

--
-- Dashboard
--

local dashboard = {
  wibox = wibox({
    visible = false,
    ontop = true,
    type = 'dock',
    bg = beautiful.colors.transparent,
  }),
}

--
-- Methods
--

function dashboard:toggle()
  local s = awful.screen.focused()

  if not self.wibox.visible then
    gears.table.crush(self.wibox, {
      screen = s,
      visible = true,

      x = s.geometry.x,
      y = s.geometry.y,
      width = s.geometry.width,
      height = s.geometry.height,
    })
  else
    self.wibox.visible = false
  end
end

--
-- ProfileWidget
--

local ProfileWidget = wibox.widget({
  {
    {
      {
        image = '/home/bsuth/dots/wallpaper.png',
        widget = wibox.widget.imagebox,
      },
      {
        {
          text = 'bsuth',
          align = 'center',
          valign = 'center',
          widget = wibox.widget.textbox,
        },

        top = 8,
        widget = wibox.container.margin,
      },

      layout = wibox.layout.fixed.vertical,
    },

    widget = wibox.container.place,
  },

  bg = beautiful.colors.black,
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background,
})

--
-- TimeWidget
--

local ClockGridWidget = wibox.widget({
  layout = wibox.layout.grid,
})

ClockGridWidget:add_widget_at(
  wibox.widget({
    format = ('<span color="%s" size="xx-large">%s</span>'):format(
      beautiful.colors.blue,
      '%H'
    ),
    widget = wibox.widget.textclock,
  }),
  1,
  1,
  2,
  1
)

ClockGridWidget:add_widget_at(
  wibox.widget({
    format = ('<span color="%s" size="xx-large">%s</span>'):format(
      beautiful.colors.purple,
      '%M'
    ),
    widget = wibox.widget.textclock,
  }),
  1,
  2,
  2,
  1
)

ClockGridWidget:add_widget_at(
  wibox.widget({
    format = ('<span color="%s" size="small">%s</span>'):format(
      beautiful.colors.white,
      '%d-%m-%Y'
    ),
    widget = wibox.widget.textclock,
  }),
  3,
  1,
  1,
  2
)

local TimeWidget = wibox.widget({
  {
    ClockGridWidget,
    widget = wibox.container.place,
  },

  bg = beautiful.colors.black,
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background,
})

--
-- SystemWidget
--

local SystemWidget = wibox.widget({
  {
    text = 'system',
    widget = wibox.widget.textbox,
  },

  bg = beautiful.colors.black,
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background,
})

--
-- BarsWidget
--

local BarsWidget = wibox.widget({
  {
    text = 'apps',
    widget = wibox.widget.textbox,
  },

  bg = beautiful.colors.black,
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background,
})

--
-- AppsWidget
--

local apps = {
  {
    icon = beautiful.assets('apps/flameshot.svg'),
    cmd = 'flameshot gui',
  },
  {
    icon = beautiful.assets('apps/simplescreenrecorder.svg'),
    cmd = 'simplescreenrecorder',
  },
  {
    icon = beautiful.assets('apps/gpick.svg'),
    cmd = 'gpick -s -o | tr -d "\n" | xclip -sel c',
    shell = true,
  },
}

function AppWidget(app)
  local appWidget = wibox.widget({
    {
      forced_width = 50,
      forced_height = 50,
      image = app.icon,
      widget = wibox.widget.imagebox,
    },

    widget = wibox.container.place,
  })

  appWidget:connect_signal('mouse::enter', function()
    mouse.current_wibox.cursor = 'hand1'
  end)

  appWidget:connect_signal('mouse::leave', function()
    mouse.current_wibox.cursor = 'arrow'
  end)

  appWidget:connect_signal('button::release', function(_, _, _, button)
    if button == 1 then
      if app.shell then
        awful.spawn.easy_async_with_shell(app.cmd)
      else
        awful.spawn(app.cmd)
      end

      dashboard:toggle()
    end
  end)

  return appWidget
end

local AppsWidget = wibox.widget({
  {
    {
      (function()
        local appWidgets = {
          spacing = 16,
          layout = wibox.layout.fixed.horizontal,
        }

        for i, app in ipairs(apps) do
          table.insert(appWidgets, AppWidget(app))
        end

        return appWidgets
      end)(),

      widget = wibox.container.place,
    },

    margins = 8,
    widget = wibox.container.margin,
  },

  bg = beautiful.colors.black,
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background,
})

--
-- NotificationWidget
--

local NotificationWidget = wibox.widget({
  {
    {
      forced_width = 40,
      forced_height = 40,
      image = beautiful.assets('notifs-on.svg'),
      widget = wibox.widget.imagebox,
    },

    widget = wibox.container.place,
  },

  bg = beautiful.colors.black,
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background,
})

--
-- DashboardGridWidget
--

local DashboardGridWidget = wibox.widget({
  forced_width = 800,
  forced_height = 450,
  spacing = 10,
  expand = true,
  homogeneous = true,
  layout = wibox.layout.grid,
})

DashboardGridWidget:add_widget_at(ProfileWidget, 1, 1, 4, 2)
DashboardGridWidget:add_widget_at(TimeWidget, 1, 3, 2, 2)
DashboardGridWidget:add_widget_at(SystemWidget, 1, 5, 2, 3)
DashboardGridWidget:add_widget_at(BarsWidget, 3, 3, 2, 5)
DashboardGridWidget:add_widget_at(AppsWidget, 5, 1, 1, 6)
DashboardGridWidget:add_widget_at(NotificationWidget, 5, 7, 1, 1)

--
-- Setup
--

dashboard.wibox:setup({
  {
    DashboardGridWidget,
    halign = 'center',
    valign = 'center',
    widget = wibox.container.place,
  },

  bgimage = beautiful.assets('dashboard.svg'),
  widget = wibox.container.background,
})

--
-- Return
--

return dashboard
