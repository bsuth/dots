local naughty = require('naughty')

return function(text, urgent)
  naughty.notify({ text = text, urgent = urgent })
end
