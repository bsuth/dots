local catnip = require('catnip')
local catmint = require('utils.catmint')
local onedark = require('utils.onedark')

local keylog = {
  press = "",
  release = "",
  canvas = catnip.canvas({
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    visible = false,
  }),
}

function keylog:render()
  if not self.canvas.visible then
    return
  end

  self.canvas:rectangle({
    width = self.canvas.width,
    height = self.canvas.height,
    fill_color = onedark.dark_gray,
    fill_opacity = 0.8,
  })

  local text = ("Press: %s\nRelease: %s"):format(self.press, self.release)

  self.canvas:text(text, {
    x = 0,
    y = 0,
    width = self.canvas.width,
    height = self.canvas.height,
    color = onedark.white,
  })
end

function keylog:toggle()
  if keylog.canvas.visible then
    keylog.canvas.visible = false
    return
  end

  local cursor_output = catmint.get_cursor_outputs()[1]
  if cursor_output == nil then return end

  keylog.canvas.x = cursor_output.x
  keylog.canvas.y = cursor_output.y
  keylog.canvas.z = 99
  keylog.canvas.width = cursor_output.width
  keylog.canvas.height = cursor_output.height
  keylog.canvas.visible = true

  keylog:render()
end

---@param event CatnipKeyEvent
local function serialize_key_event(event)
  local parts = {}

  if event.shift then table.insert(parts, "Shift") end
  if event.ctrl then table.insert(parts, "Ctrl") end
  if event.mod1 then table.insert(parts, "Mod1") end
  if event.mod2 then table.insert(parts, "Mod2") end
  if event.mod3 then table.insert(parts, "Mod3") end
  if event.mod4 then table.insert(parts, "Mod4") end
  if event.mod5 then table.insert(parts, "Mod5") end

  table.insert(parts, event.name)
  table.insert(parts, "[" .. event.code .. "]")

  return table.concat(parts, " ")
end

catnip.subscribe('keyboard::key::press', function(_, event)
  keylog.press = serialize_key_event(event)
  keylog:render()
end)

catnip.subscribe('keyboard::key::release', function(_, event)
  keylog.release = serialize_key_event(event)
  keylog:render()
end)

return keylog
