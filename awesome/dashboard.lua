local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local models = require('models')
local wibox = require('wibox')

--
-- Dashboard
--

local dashboard = {
  gridWidthRatio = (800 / 1920),
  gridHeightRatio = (450 / 1080),
  gridWidget = nil,

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

    -- Scale gridWidget to match wallpaper
    self.gridWidget.forced_width = self.gridWidthRatio * s.geometry.width
    self.gridWidget.forced_height = self.gridHeightRatio * s.geometry.height
  else
    self.wibox.visible = false
  end
end

--
-- ProfileWidget
--

local function ProfileWidget()
  return wibox.widget({
    {
      {
        {
          {
            {
              forced_width = 128,
              forced_height = 128,
              image = beautiful.assets('profile.png'),
              widget = wibox.widget.imagebox,
            },

            widget = wibox.container.place,
          },

          bottom = 24,
          widget = wibox.container.margin,
        },
        {
          {
            text = 'bsuth',
            font = 'Hack Regular 24',
            align = 'center',
            valign = 'center',
            widget = wibox.widget.textbox,
          },

          bottom = 8,
          widget = wibox.container.margin,
        },
        {
          text = '“ Code is like humor. When you have to explain it, it’s bad.”',
          font = 'Hack Regular 12',
          align = 'center',
          valign = 'center',
          widget = wibox.widget.textbox,
        },
        {
          text = '-Cory House',
          font = 'Hack Regular 12',
          align = 'center',
          valign = 'center',
          widget = wibox.widget.textbox,
        },

        layout = wibox.layout.fixed.vertical,
      },

      widget = wibox.container.place,
    },

    bg = beautiful.colors.black,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })
end

--
-- TimeWidget
--

local function ClockGridWidget()
  local clockGridWidget = wibox.widget({
    layout = wibox.layout.grid,
  })

  clockGridWidget:add_widget_at(
    wibox.widget({
      {
        format = ('<span color="%s" font_family="%s" size="xx-large">%s</span>'):format(
          beautiful.colors.blue,
          'Hack Regular',
          '%H'
        ),
        widget = wibox.widget.textclock,
      },

      widget = wibox.container.place,
    }),
    1,
    1,
    2,
    1
  )

  clockGridWidget:add_widget_at(
    wibox.widget({
      {
        format = ('<span color="%s" font_family="%s" size="xx-large">%s</span>'):format(
          beautiful.colors.purple,
          'Hack Regular',
          '%M'
        ),
        widget = wibox.widget.textclock,
      },

      widget = wibox.container.place,
    }),
    1,
    2,
    2,
    1
  )

  clockGridWidget:add_widget_at(
    wibox.widget({
      {
        format = ('<span color="%s" font_family="%s" size="small">%s</span>'):format(
          beautiful.colors.cyan,
          'Fredoka One',
          '%d-%m-%Y'
        ),
        widget = wibox.widget.textclock,
      },

      widget = wibox.container.place,
    }),
    3,
    1,
    1,
    2
  )

  return clockGridWidget
end

local function TimeWidget()
  return wibox.widget({
    {
      ClockGridWidget(),
      widget = wibox.container.place,
    },

    bg = beautiful.colors.black,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })
end

--
-- PowerWidget
--

local function PowerItemWidget(args)
  local safety_check = true

  local powerItemWidget = wibox.widget({
    forced_width = 64,
    forced_height = 64,
    image = args.icon,
    widget = wibox.widget.imagebox,
  })

  local safety_check_timer = gears.timer({
    timeout = 0.25,
    single_shot = true,
    callback = function()
      safety_check = true
    end,
  })

  powerItemWidget:connect_signal('mouse::enter', function()
    mouse.current_wibox.cursor = 'hand1'
  end)

  powerItemWidget:connect_signal('mouse::leave', function()
    mouse.current_wibox.cursor = 'arrow'
  end)

  powerItemWidget:connect_signal(
    'button::release',
    function(self, lx, ly, button, mods)
      if button == 1 then
        if safety_check then
          safety_check = false
          safety_check_timer:again()
        else
          awful.spawn.easy_async_with_shell(args.cmd)
          dashboard:toggle()
        end
      end
    end
  )

  return powerItemWidget
end

local function PowerWidget()
  return wibox.widget({
    {
      {
        PowerItemWidget({
          icon = beautiful.assets('lock.svg'),
          cmd = 'systemctl suspend',
        }),
        PowerItemWidget({
          icon = beautiful.assets('restart.svg'),
          cmd = '/sbin/reboot',
        }),
        PowerItemWidget({
          icon = beautiful.assets('power.svg'),
          cmd = '/sbin/poweroff',
        }),

        spacing = 16,
        layout = wibox.layout.flex.horizontal,
      },

      widget = wibox.container.place,
    },

    bg = beautiful.colors.black,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })
end

--
-- SystemWidget
--

local function SystemStatBarWidget(args)
  local systemStatBarWidget = wibox.widget({
    forced_width = 160,
    forced_height = 16,
    max_value = 100,
    value = args.model.percent,
    color = args.color,
    background_color = beautiful.colors.blacker,
    bar_shape = gears.shape.rounded_bar,
    shape = gears.shape.rounded_bar,
    widget = wibox.widget.progressbar,
  })

  args.model:connect_signal('update', function()
    systemStatBarWidget.value = args.model.percent

    if args.on_bar_update ~= nil then
      args.on_bar_update(systemStatBarWidget)
    end
  end)

  return {
    systemStatBarWidget,
    widget = wibox.container.place,
  }
end

local function SystemStatWidget(args, isBattery)
  local iconWidget = wibox.widget({
    image = isBattery and (args.model.discharging and args.dischargingIcon or args.chargingIcon) or args.icon,
    widget = wibox.widget.imagebox,
  })

  local systemStatWidget = wibox.widget({
    {
      SystemStatBarWidget(args),
      direction = 'south',
      widget = wibox.container.rotate,
    },
    {
      iconWidget,
      left = 40,
      right = 40,
      widget = wibox.container.margin,
    },
    SystemStatBarWidget(args),

    expand = 'outside',
    layout = wibox.layout.align.horizontal,
  })

  if isBattery then
    args.model:connect_signal('update', function()
      iconWidget.image = args.model.discharging
          and args.dischargingIcon
        or args.chargingIcon
    end)
  end

  systemStatWidget:connect_signal(
    'button::press',
    function(self, lx, ly, button, mods)
      if button == 4 then
        args.model:set(args.model.percent + 5)
      elseif button == 5 then
        args.model:set(args.model.percent - 5)
      end
    end
  )

  return systemStatWidget
end

local function SystemWidget()
  return wibox.widget({
    {
      {
        {
          SystemStatWidget({
            model = models.volume,
            color = beautiful.colors.green,
            icon = beautiful.assets('volume.svg'),
          }),
          SystemStatWidget({
            model = models.brightness,
            color = beautiful.colors.yellow,
            icon = beautiful.assets('brightness.svg'),
          }),
          SystemStatWidget({
            model = models.battery,
            color = beautiful.colors.red,
            chargingIcon = beautiful.assets('battery-charging.svg'),
            dischargingIcon = beautiful.assets('battery-discharging.svg'),
          }, true),

          spacing = 16,
          layout = wibox.layout.flex.vertical,
        },

        margins = 16,
        widget = wibox.container.margin,
      },

      widget = wibox.container.place,
    },

    bg = beautiful.colors.black,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })
end

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
  {
    icon = beautiful.assets('apps/inkscape.svg'),
    cmd = 'inkscape',
  },
  {
    icon = beautiful.assets('apps/vivaldi.svg'),
    cmd = 'vivaldi-stable',
  },
  {
    icon = beautiful.assets('apps/terminal.svg'),
    cmd = 'st -e nvim -c ":Dirvish"',
  },
}

local function AppWidget(app)
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

  appWidget:connect_signal(
    'button::release',
    function(self, lx, ly, button, mods)
      if button == 1 then
        if app.shell then
          awful.spawn.easy_async_with_shell(app.cmd)
        else
          awful.spawn(app.cmd)
        end

        dashboard:toggle()
      end
    end
  )

  return appWidget
end

local function AppsWidget()
  return wibox.widget({
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
end

--
-- LocaleWidget
--

local function get_locale_icon()
  local locale = models.locale.list[models.locale.index]

  if locale == 'mozc' then
    return beautiful.assets('ja_JP.svg')
  else
    return beautiful.assets('en_US.svg')
  end
end

local function LocaleWidget()
  local iconWidget = wibox.widget({
    image = get_locale_icon(),
    widget = wibox.widget.imagebox,
  })

  models.locale:connect_signal('update', function()
    iconWidget.image = get_locale_icon()
  end)

  iconWidget:connect_signal('mouse::enter', function()
    mouse.current_wibox.cursor = 'hand1'
  end)

  iconWidget:connect_signal('mouse::leave', function()
    mouse.current_wibox.cursor = 'arrow'
  end)

  iconWidget:connect_signal(
    'button::release',
    function(self, lx, ly, button, mods)
      if button == 1 then
        models.locale:cycle()
      end
    end
  )

  return wibox.widget({
    {
      {
        iconWidget,
        margins = 16,
        widget = wibox.container.margin,
      },

      widget = wibox.container.place,
    },

    bg = beautiful.colors.black,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })
end

--
-- NotificationWidget
--

local function get_notification_icon()
  if models.notifications.active then
    return beautiful.assets('notifications-active.svg')
  else
    return beautiful.assets('notifications-inactive.svg')
  end
end

local function NotificationWidget()
  local iconWidget = wibox.widget({
    forced_width = 50,
    forced_height = 50,
    image = get_notification_icon(),
    widget = wibox.widget.imagebox,
  })

  models.notifications:connect_signal('update', function()
    iconWidget.image = get_notification_icon()
  end)

  iconWidget:connect_signal('mouse::enter', function()
    mouse.current_wibox.cursor = 'hand1'
  end)

  iconWidget:connect_signal('mouse::leave', function()
    mouse.current_wibox.cursor = 'arrow'
  end)

  iconWidget:connect_signal(
    'button::release',
    function(self, lx, ly, button, mods)
      if button == 1 then
        models.notifications:toggle()
      end
    end
  )

  return wibox.widget({
    {
      iconWidget,
      widget = wibox.container.place,
    },

    bg = beautiful.colors.black,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })
end

--
-- DashboardGridWidget
--

local function DashboardGridWidget()
  local dashboardGridWidget = wibox.widget({
    spacing = 10,
    expand = true,
    homogeneous = true,
    layout = wibox.layout.grid,
  })

  dashboardGridWidget:add_widget_at(ProfileWidget(), 1, 1, 4, 3)
  dashboardGridWidget:add_widget_at(TimeWidget(), 1, 4, 2, 2)
  dashboardGridWidget:add_widget_at(PowerWidget(), 1, 6, 2, 3)
  dashboardGridWidget:add_widget_at(SystemWidget(), 3, 4, 2, 5)
  dashboardGridWidget:add_widget_at(AppsWidget(), 5, 1, 1, 6)
  dashboardGridWidget:add_widget_at(LocaleWidget(), 5, 7, 1, 1)
  dashboardGridWidget:add_widget_at(NotificationWidget(), 5, 8, 1, 1)

  return dashboardGridWidget
end

--
-- Setup
--

dashboard.gridWidget = DashboardGridWidget()

dashboard.wibox:setup({
  {
    image = beautiful.assets('dashboard.svg'),
    widget = wibox.widget.imagebox,
  },
  {
    dashboard.gridWidget,
    halign = 'center',
    valign = 'center',
    widget = wibox.container.place,
  },

  layout = wibox.layout.stack,
})

--
-- Return
--

return dashboard
