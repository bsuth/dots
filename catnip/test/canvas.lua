local catnip = require('catnip')
local keymap = require('keymap')

local canvas = catnip.canvas({ width = 500, height = 700 })
local alternate = false

local test_png = catnip.png('test/test.png')
local test_svg = catnip.svg('test/test.svg')
test_svg:apply('path { stroke: red }')

keymap({ 'ctrl' }, 't', function()
  canvas:clear()
  canvas.z = 99
  alternate = not alternate

  local primary = alternate and 0x00ff00 or 0xff0000
  local secondary = alternate and 0xff0000 or 0x00ff00

  canvas:path({
    stroke_color = primary,
    { 'move', 10,  400 },
    { 'line', 200, 0 },
    { 'line', 0,   20 },
    { 'close' },
    { 'move', 0,   50 },
    { 'line', 200, 0 },
    { 'line', 0,   20 },
    { 'close' },
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
  })

  canvas:svg(test_svg, {
    x = 20,
    y = 500,
    width = 50,
  })

  canvas:png(test_png, {
    x = 200,
    y = 200,
    height = 200,
  })
end)
