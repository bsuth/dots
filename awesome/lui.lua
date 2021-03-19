--[[
-- Meta fields. These are not styles, but have to do with styling
__debug = true, -- show debug information + bounding boxes
__clear = true, -- clear all styles of this element up to this point
]]--
local beautiful = require 'beautiful'
local gears = require 'gears'
local _ = require 'utils'
local wibox = require 'wibox'

function render_margins(margins)
  margins = _.default(margins, { 0 })

  return _.merge {
    _.map(
      {
        top = margins[1] or 0,
        right = margins[2] or margins[1],
        bottom = margins[3] or margins[1],
        left = margins[4] or margins[2],
      },
      function(margin)
        if type(margin) == 'number' then
          return margin
        elseif type(margin) == 'string' then
          -- TODO: percent?
          return tonumber(margin)
        else
          return 0
        end
      end
    ),
    { widget = wibox.container.margin },
  }
end

function render_background_border(node)
  local border = _.default(node.border, {
    0,
    beautiful.colors.transparent,
    0,
  })

  return {
    bg = node.bg or beautiful.colors.transparent,

    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, border[3] or 0)
    end,
    shape_border_width = border[1],
    shape_border_color = border[2],

    widget = wibox.container.background,
  }
end

local function render_layout(node)
  local layout = wibox.layout.flex.horizontal

  if node.layout == 'fixed' then
    layout = wibox.layout.fixed[node.flow or 'horizontal']
  end

  return {
    layout = layout,
  }
end

function render(node)
  if type(node) == 'string' then
    return wibox.widget {
      text = node,
      widget = wibox.widget.textbox,
    }
  elseif node.widget ~= nil then
    return wibox.widget(node)
  else
    local margins = render_margins(node.margin)
    local border_background = render_background_border(node)
    local padding = render_margins(node.padding)

    local layout = _.merge {
      render_layout(node),
      _.map(node, function(child)
        return {
          render(child),
          halign = child.halign or 'center',
          valign = child.valign or 'center',
          widget = wibox.container.place,
        }
      end, ipairs),
    }

    return wibox.widget(_.merge {
      margins,
      {
        _.merge {
          border_background,
          {
            _.merge {
              padding,
              {
                layout,
              },
            },
          },
        },
      },
    })
  end
end

return {
	render = render,
}
