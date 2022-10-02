local awful = require('awful')

return {
  {
    name = 'hlayout',
    arrange = function(p)
      if #p.clients < 4 then
        awful.layout.suit.spiral.dwindle.arrange(p)
      else
        awful.layout.suit.fair.horizontal.arrange(p)
      end
    end,
  },
  {
    name = 'vlayout',
    arrange = function(p)
      local clientHeight = p.workarea.height / math.max(1, #p.clients)

      for i, client in ipairs(p.clients) do
        p.geometries[client] = {
          x = p.workarea.x,
          y = p.workarea.y + (i - 1) * clientHeight,
          width = p.workarea.width,
          height = clientHeight,
        }
      end
    end,
  },
}
