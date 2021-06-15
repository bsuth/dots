local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local layout = require('layout')
local wibox = require('wibox')

--
-- Prompt
--

local prompt = {
  normal = {
    width = 400,
    height = 70,
  },
  dmenu = {
    width = 600,
    height = 350,
    filter = '',
  },
  wibox = wibox({
    ontop = true,
    visible = false,
    bg = beautiful.colors.transparent,
    type = 'dock', -- remove box shadows
  }),
}

local rawPrompt = awful.widget.prompt({
  prompt = '',

  keypressed_callback = function()
  end,

  done_callback = function()
    prompt.wibox.visible = false
  end,
})

--
-- Helpers
--

function noop()
end

--
-- Functions
--

function prompt.attach(widget)
  prompt.wibox:setup({
    {
      widget,
      margins = 20,
      widget = wibox.container.margin,
    },

    shape_border_width = 2,
    shape_border_color = beautiful.colors.white,
    bg = beautiful.colors.blacker,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 5)
    end,

    widget = wibox.container.background,
  })
end

--
-- Normal Mode
--

local function NormalModeWidget()
  return {
    {
      layout.center({
        {
          -- placeholder widget so container actually renders
          text = '',
          widget = wibox.widget.textbox,
        },

        forced_width = 30 + 4, -- + shape_border_width
        forced_height = 15 + 4, -- + shape_border_width

        shape_border_width = 4,
        shape_border_color = beautiful.colors.white,
        shape = function(cr, width, height)
          gears.shape.powerline(cr, 30, 15)
        end,

        widget = wibox.container.background,
      }),

      right = 10,
      widget = wibox.container.margin,
    },
    layout.center(rawPrompt.widget),
    layout = wibox.layout.fixed.horizontal,
  }
end

function prompt.normal_mode(callback)
  local screen = awful.screen.focused()

  gears.table.crush(prompt.wibox, {
    screen = screen,
    x = screen.geometry.x + (screen.geometry.width - prompt.normal.width) / 2,
    y = screen.geometry.y + (screen.geometry.height - prompt.normal.height) / 2,
    width = prompt.normal.width,
    height = prompt.normal.height,
  })

  gears.table.crush(rawPrompt, {
    exe_callback = callback or noop,
    keypressed_callback = noop,
  })

  prompt.attach(NormalModeWidget())
  rawPrompt:run()
  prompt.wibox.visible = not prompt.wibox.visible
end

--
-- Dmenu Mode
--

local function DmenuItemWidget(label)
  return wibox.widget({
    {
      {
        text = label,
        valign = 'center',
        widget = wibox.widget.textbox,
      },
      margins = 20,
      widget = wibox.container.margin,
    },
    widget = wibox.container.background,
  })
end

local function DmenuWidget(options)
  local dmenuWidget = {
    {
      {
        layout.center({
          {
            -- placeholder widget so container actually renders
            text = '',
            widget = wibox.widget.textbox,
          },

          forced_width = 30 + 4, -- + shape_border_width
          forced_height = 15 + 4, -- + shape_border_width

          shape_border_width = 4,
          shape_border_color = beautiful.colors.white,
          shape = function(cr, width, height)
            gears.shape.powerline(cr, 30, 15)
          end,

          widget = wibox.container.background,
        }),

        right = 10,
        widget = wibox.container.margin,
      },
      layout.center(rawPrompt.widget),

      layout = wibox.layout.fixed.horizontal,
    },

    layout = wibox.layout.fixed.vertical,
  }

  for i, option in ipairs(options) do
    if option.label:lower():find(prompt.dmenu.filter:lower()) then
      table.insert(dmenuWidget, DmenuItemWidget(option.label))
    end
  end

  return dmenuWidget
end

function prompt.dmenu_mode(options, callback)
  local screen = awful.screen.focused()

  prompt.dmenu.filter = ''

  gears.table.crush(prompt.wibox, {
    screen = screen,
    x = screen.geometry.x + (screen.geometry.width - prompt.dmenu.width) / 2,
    y = screen.geometry.y + (screen.geometry.height - prompt.dmenu.height) / 2,
    width = prompt.dmenu.width,
    height = prompt.dmenu.height,
  })

  gears.table.crush(rawPrompt, {
    exe_callback = callback or noop,
    keyreleased_callback = function(mods, key, cmd)
      prompt.dmenu.filter = cmd
      prompt.attach(DmenuWidget(options))
    end,
  })

  prompt.attach(DmenuWidget(options))
  rawPrompt:run()
  prompt.wibox.visible = not prompt.wibox.visible
end

--
-- Return
--

return prompt
