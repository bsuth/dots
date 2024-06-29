local catnip = require('catnip')
local key = require('key')

local canvas = catnip.canvas({ width = 500, height = 700 })
local alternate = false

key.release({ 'ctrl' }, 't', function()
  canvas:clear()
  canvas.z = 99
  alternate = not alternate

  local primary = alternate and 0x00ff00 or 0xff0000
  local secondary = alternate and 0xff0000 or 0x00ff00

  canvas:path({
    x = 10,
    y = 400,
    close = true,
    stroke_color = primary,
    { 'line', 200, 0 },
    { 'line', 0,   20 },
  })

  canvas:path({
    x = 10,
    y = 450,
    close = true,
    stroke_color = primary,
    { 'line', 200, 0 },
    { 'line', 0,   20 },
  })

  canvas:rectangle({
    x = 10,
    y = 30,
    width = 80,
    height = 50,
    radius_top_right = 8,
    radius_bottom_right = 8,
    fill_color = primary,
    stroke_color = secondary,
    stroke_size = 4,
  })

  canvas:rectangle({
    x = 100,
    y = 30,
    width = 90,
    height = 100,
    radius = 8,
    fill_color = primary,
  })

  canvas:rectangle({
    x = 200,
    y = 30,
    width = 50,
    height = 50,
    fill_color = primary,
  })

  canvas:rectangle({
    x = 300,
    y = 30,
    width = 50,
    height = 50,
    fill_color = 0xffffff,
  })

  canvas:text('hello world', {
    x = 300,
    y = 30,
    width = 50,
    height = 50,
    color = 0x000000,
    weight = 800,
    valign = 'center',
    size = 50,
  })

  canvas:svg('test/test.svg', {
    x = 20,
    y = 500,
    width = 50,
    styles = alternate and 'path { stroke: red }' or 'path { stroke: blue }',
  })

  canvas:png('test/test.png', {
    x = 200,
    y = 200,
    height = 200,
  })
end)
