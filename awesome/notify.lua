local beautiful = require('beautiful')
local naughty = require('naughty')
local models = require('models')

naughty.config.notify_callback = function(notification)
  if not notification.urgent and not models.notifications.active then
    return nil
  end

  beautiful.styleNotification(notification)
  return notification
end

return function(text, urgent)
  naughty.notify({ text = text, urgent = urgent })
end
