local awful = require('awful')

return {
  name = 'mylayout',
  arrange = function(p)
    if #p.clients < 4 then
      awful.layout.suit.spiral.dwindle.arrange(p)
    else
      awful.layout.suit.fair.horizontal.arrange(p)
    end
  end,
}
