local catnip = require('catnip')
local catmint = require('utils.catmint')
local onedark = require('utils.onedark')
local table = require('extern.stdlib').table

local MAX_HISTORY_LENGTH = 100

local console = {
  history = {},
  canvas = catnip.canvas({
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    visible = false,
  }),
}

function console:log(text)
  table.insert(self.history, tostring(text))
  self.history = table.slice(self.history, math.max(1, #self.history - MAX_HISTORY_LENGTH))
end

function console:render()
  self.canvas:rectangle({
    width = self.canvas.width,
    height = self.canvas.height,
    fill_color = onedark.dark_gray,
    fill_opacity = 0.8,
  })

  self.canvas:text(table.concat(self.history, "\n"), {
    x = 0,
    y = 0,
    width = self.canvas.width,
    height = self.canvas.height,
    color = onedark.white,
  })
end

function console:toggle()
  if console.canvas.visible then
    console.canvas.visible = false
    return
  end

  local cursor_output = catmint.get_cursor_outputs()[1]
  if cursor_output == nil then return end

  console.canvas.x = cursor_output.x
  console.canvas.y = cursor_output.y
  console.canvas.z = 99
  console.canvas.width = cursor_output.width
  console.canvas.height = cursor_output.height
  console.canvas.visible = true

  console:render()
end

return console
