local catnip = require('catnip')

local block = catnip.widget.block({
  x = 20,
  y = 20,
  width = 200,
  height = 200,
  bg_color = 0xff0000,
  border_width = 1,
  border_color = 0x00ff00,
})

block:insert(catnip.widget.block({
  width = 50,
  height = 50,
  bg_color = 0x00ff00,
}))
block:insert(1, catnip.widget.block({
  width = 100,
  height = 100,
  bg_color = 0x0000ff
}))

catnip.bind({ 'mod1' }, 't', function()
end)

return catnip.widget.root({
  x = 0,
  y = 0,
  width = 1920,
  height = 1080,
  block,
})
