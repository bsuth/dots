local catnip = require('catnip')
local Widget = require('Widget')

local root_registry = setmetatable({}, { __mode = 'k' })

catnip.subscribe('tick', function()
  for root in pairs(root_registry) do
    if root.update_requested then
      local layout = root.widget:flow()
      root.widget:draw(root.canvas, layout)
      root.update_requested = false
    end
  end
end)

local function __request_update(self)
  self.update_requested = true
end

return function(props)
  local widget_props = {
    __request_update = __request_update,
  }

  for _, child in ipairs(props) do
    table.insert(widget_props, child)
  end

  local root = {
    widget = Widget(widget_props),
    update_requested = false,
    canvas = catnip.canvas({
      x = props.x,
      y = props.y,
      z = props.z,
      width = props.width,
      height = props.height,
      visible = props.visible,
    }),
  }

  root_registry[root] = true

  return root
end
