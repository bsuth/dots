local Widget = {}
local WidgetMT = { __index = Widget }

function Widget:request_update()
  if self.__request_update then
    self:__request_update()
  end

  for parent in self.parents do
    parent:request_redraw()
  end
end

function Widget:flow(parent_layout)
  local layout = {
    x = self.x,
    y = self.y,
    width = self.width,
    height = self.height,
  }

  if self.__preresolve then
    self.__preflow(layout, parent_layout)
  end

  for _, child in ipairs(self.children) do
    table.insert(layout, child:resolve(layout))
  end

  if self.__postresolve then
    self.__postflow(layout, parent_layout)
  end

  return layout
end

function Widget:draw(canvas, layout)
  if self.__draw then
    self:__draw(canvas, layout)
  end

  for i, child in ipairs(self.children) do
    child:draw(canvas, layout[i])
  end
end

return function(props)
  local widget = setmetatable({
    __draw = props.__draw,
    parents = {},
    children = {},
  }, WidgetMT)

  for _, child in ipairs(props) do
    table.insert(widget.children, child)
    child.parents[widget] = true
  end

  return widget
end
