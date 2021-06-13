local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local layout = require('layout')
local wibox = require('wibox')

--
-- Prompt
--

local config = {
  normal = {
    width = 400,
    height = 70,
  },
  dmenu = {},
}

local prompt = {
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
-- Methods
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

local normalModeWidget = {
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

function prompt.normal_mode(callback)
  local screen = awful.screen.focused()

  gears.table.crush(prompt.wibox, {
    screen = screen,
    x = screen.geometry.x + (screen.geometry.width - config.normal.width) / 2,
    y = screen.geometry.y + (screen.geometry.height - config.normal.height) / 2,
    width = config.normal.width,
    height = config.normal.height,
  })

  gears.table.crush(rawPrompt, {
    exe_callback = callback or noop,
  })

  prompt.attach(normalModeWidget)
  rawPrompt:run()
  prompt.wibox.visible = not prompt.wibox.visible
end

--
-- Dmenu Mode
-- TODO
--

--
-- Return
--

return prompt
