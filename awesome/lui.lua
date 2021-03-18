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

function render(node)
  if node.widget ~= nil or node.layout ~= nil then
    return wibox.widget(node)
  else
    local margins = render_margins(node.margin)
    local border_background = render_background_border(node)
    local padding = _.merge {
      render_margins(node.padding),
      _.map(node, function(child)
        return render(child)
      end, ipairs),
    }

    return wibox.widget(_.merge {
      margins,
      {
        _.merge {
          border_background,
          {
            padding,
          },
        },
      },
    })
  end
end

return {
	render = render,
}
