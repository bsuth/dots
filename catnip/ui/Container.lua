local Widget = require('Widget')

local function __draw(self, canvas, layout)
  local path = {
    fill_color = self.fill_color,
    fill_opacity = self.fill_opacity,
    stroke_color = self.stroke_color,
    stroke_opacity = self.stroke_opacity,
    stroke_size = self.stroke_size,
  }

  local radius = type(self.radius) == 'number'
    and { self.radius, self.radius, self.radius, self.radius }
    or type(self.radius) == 'table'
    and self.radius

  if radius then
    table.insert(path, { 'move', layout.x, layout.y + radius[1] })
    table.insert(path, { 'arc', radius[1], 0, math.pi / 2 })
    table.insert(path, { 'line', layout.width - radius[1] - radius[2], 0 })
    table.insert(path, { 'arc', 0, radius[2], math.pi / 2 })
    table.insert(path, { 'line', 0, layout.height - radius[2] - radius[3] })
    table.insert(path, { 'arc', -radius[3], 0, math.pi / 2 })
    table.insert(path, { 'line', -layout.width + radius[3] + radius[4], 0 })
    table.insert(path, { 'arc', 0, -radius[4], math.pi / 2 })
  else
    table.insert(path, { 'move', layout.x, layout.y })
    table.insert(path, { 'line', layout.width, 0 })
    table.insert(path, { 'line', 0, layout.height })
    table.insert(path, { 'line', -layout.width, 0 })
    table.insert(path, { 'line', 0, -layout.height })
  end

  table.insert(path, { 'close' })
  canvas:path(path)
end

return function(props)
  local widget_props = {
    __draw = __draw,
  }

  for _, child in ipairs(props) do
    table.insert(widget_props, child)
  end

  local container = {
    widget = Widget(widget_props),
    fill_color = props.fill_color,
    fill_opacity = props.fill_opacity,
    stroke_color = props.stroke_color,
    stroke_opacity = props.stroke_opacity,
    stroke_size = props.stroke_size,
    radius = props.radius,
  }

  return container
end
