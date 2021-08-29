local awful = require('awful')
local gears = require('gears')

--
-- Scratchpad
--

local scratchpad = {
  width = 900,
  height = 550,
}
local scratchrule = { class = 'scratch' }

--
-- Functions
--

function scratchpad.toggle()
  local s = awful.screen.focused()
  if client.focus and awful.rules.match(client.focus, scratchrule) then
    client.focus:tags({})
  else
    for i, c in ipairs(client.get()) do
      if awful.rules.match(c, scratchrule) then
        gears.table.crush(c, {
          x = (s.geometry.width - scratchpad.width) / 2,
          y = (s.geometry.height - scratchpad.height) / 2,
          width = scratchpad.width,
          height = scratchpad.height,
          screen = s,
        })

        c:tags({ s.selected_tag })
        c:raise()
        client.focus = c
        return
      end
    end
    awful.spawn('st -c scratchpad -e nvim -c ":Dirvish"')
  end
end

--
-- Return
--

return scratchpad
