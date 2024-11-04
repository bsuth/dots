local catnip = require('catnip')

local state = {
  text_color = 0xff0000,
}

local block = catnip.widget.block({
  bg_color = 0xff0000,
  border_width = 1,
  border_color = 0x00ff00,
  layout = function()
    return {
      { 0, 0, 100, 100 },
      { 0, 0, 50,  50 },
      { 0, 0, 500, 50 },
    }
  end,
})

block:insert(catnip.widget.block({
  bg_color = 0x00ff00,
}))

block:insert(1, catnip.widget.block({
  bg_color = 0x0000ff
}))

local text = catnip.widget.text({
  text = "hello world",
})

block:insert(text)

catnip.bind({ 'mod1' }, 't', function()
  if state.text_color == 0xff0000 then
    text.color = 0x00ff00
    state.text_color = 0x00ff00
  else
    text.color = 0xff0000
    state.text_color = 0xff0000
  end
end)

return catnip.widget.root({
  x = 0,
  y = 0,
  width = 1920,
  height = 1080,
  layout = function()
    return {
      { 20, 20, 200, 200 },
      { 0,  0,  200, 20 },
    }
  end,
  block,
  catnip.widget.block({
    bg_color = 0xffffff,
    layout = function(width, height)
      return { { 0, 0, width, height } }
    end,
    catnip.widget.text({ text = "aaaaaaaa bbbbbbb" }),
  }),
})
