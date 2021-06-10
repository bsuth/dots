local awful = require('awful')
local dashboard = require('dashboard')
local gears = require('gears')
local models = require('models')
local naughty = require('naughty')
-- local taglist = require('taglist')
local tagtabs = require('tagtabs')

--
-- Keybindings
--

local bindings = {
  restore_tag = nil,

  scratchpad = {
    client = nil,
    width = 900,
    height = 600,
  },

  grab_mouse_until_released = function()
    mousegrabber.run(function(mouse)
      for _, v in pairs(mouse.buttons) do
        if v then
          return true
        end
      end
      return false
    end, 'mouse')
  end,
}

--
-- Global Keys
--

bindings.globalkeys = gears.table.join(

  --
  -- System
  --

  awful.key({ 'Mod4', 'Shift' }, 'r', function()
      awesome.restart()
    end),
  awful.key({ 'Mod4', 'Shift' }, 'Escape', function()
    awesome.quit()
  end),

  awful.key({}, 'XF86AudioLowerVolume', function()
    models.volume:set(models.volume.percent - 5)
  end),
  awful.key({}, 'XF86AudioRaiseVolume', function()
    models.volume:set(models.volume.percent + 5)
  end),
  awful.key({}, 'XF86AudioMute', function()
    models.volume:toggle()
  end),

  awful.key({}, 'XF86MonBrightnessDown', function()
    models.brightness:set(models.brightness.percent - 8)
  end),
  awful.key({}, 'XF86MonBrightnessUp', function()
    models.brightness:set(models.brightness.percent + 8)
  end),

  awful.key({ 'Mod4', 'Control' }, 'space', function()
    models.kb_layout:cycle()
  end),

  --
  -- Movement
  --

  awful.key({ 'Mod4' }, 'h', function()
    awful.client.focus.global_bydirection('left')
  end),
  awful.key({ 'Mod4' }, 'j', function()
    awful.client.focus.global_bydirection('down')
  end),
  awful.key({ 'Mod4' }, 'k', function()
    awful.client.focus.global_bydirection('up')
  end),
  awful.key({ 'Mod4' }, 'l', function()
    awful.client.focus.global_bydirection('right')
  end),

  awful.key({ 'Mod4', 'Shift' }, 'h', function()
    awful.client.swap.global_bydirection('left')
  end),
  awful.key({ 'Mod4', 'Shift' }, 'j', function()
    awful.client.swap.global_bydirection('down')
  end),
  awful.key({ 'Mod4', 'Shift' }, 'k', function()
    awful.client.swap.global_bydirection('up')
  end),
  awful.key({ 'Mod4', 'Shift' }, 'l', function()
    awful.client.swap.global_bydirection('right')
  end),

  awful.key({ 'Mod4', 'Control' }, 'h', function()
    awful.screen.focus_bydirection('left')
  end),
  awful.key({ 'Mod4', 'Control' }, 'j', function()
    awful.screen.focus_bydirection('down')
  end),
  awful.key({ 'Mod4', 'Control' }, 'k', function()
    awful.screen.focus_bydirection('up')
  end),
  awful.key({ 'Mod4', 'Control' }, 'l', function()
    awful.screen.focus_bydirection('right')
  end),

  awful.key({ 'Mod4', 'Shift' }, 'm', function()
    local clients = awful.clientbuffer:clients()
    if #clients > 0 then
      local c = clients[#clients]
      c:move_to_tag(awful.screen.focused().selected_tag)
      c.minimized = false
      client.focus = c
    end
  end),

  awful.key({ 'Mod4' }, ';', function()
    local s = awful.screen.focused()

    if
      bindings.scratchpad.client == nil
      or not bindings.scratchpad.client.valid
    then
      awful.spawn('st -e nvim -c ":term"', {
        name = 'scratchpad',
        floating = true,
        screen = s,
        width = bindings.scratchpad.width,
        height = bindings.scratchpad.height,
        x = s.geometry.x + (s.geometry.width - bindings.scratchpad.width) / 2,
        y = s.geometry.y + (s.geometry.height - bindings.scratchpad.height) / 2,

        callback = function(c)
          bindings.scratchpad.client = c
          c:emit_signal('request::activate', 'client.jumpto', { raise = true })
        end,
      })
    elseif bindings.scratchpad.client.hidden then
      gears.table.crush(bindings.scratchpad.client, {
        screen = s,
        hidden = false,
        x = s.geometry.x + (s.geometry.width - bindings.scratchpad.width) / 2,
        y = s.geometry.y + (s.geometry.height - bindings.scratchpad.height) / 2,
      })
      bindings.scratchpad.client:emit_signal(
        'request::activate',
        'client.jumpto',
        { raise = true }
      )
    else
      bindings.scratchpad.client.hidden = true
    end
  end),

  --
  -- Layout
  --

  awful.key({ 'Mod4', 'Shift', 'Control' }, 'h', function()
    awful.tag.incmwfact(-0.05)
  end),
  awful.key({ 'Mod4', 'Shift', 'Control' }, 'l', function()
    awful.tag.incmwfact(0.05)
  end),
  awful.key({ 'Mod4' }, ',', function()
    awful.layout.inc(1)
  end),

  --
  -- Spawners
  --

  awful.key({ 'Mod4' }, 'Return', function()
    awful.spawn('st -e nvim -c ":Dirvish"')
  end),
  awful.key({ 'Mod4' }, "'", function()
    awful.spawn('vivaldi-stable')
  end),
  awful.key({ 'Mod4' }, 'space', function()
    awful.spawn('rofi -show run')
  end),
  awful.key({ 'Mod4' }, 'p', function()
    dashboard:toggle()
  end),

  awful.key({ 'Mod4' }, 'n', function()
    local tagtabs = awful.screen.focused().tagtabs
    tagtabs.visible = not tagtabs.visible
  end)
)

for i = 1, 9 do
  bindings.globalkeys = gears.table.join(
    bindings.globalkeys,
    awful.key({ 'Mod4' }, '#' .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]

        if tag then
          tag:view_only()
        end
      end)
  )
end

--
-- Client Keys
--

bindings.clientkeys = gears.table.join(

  --
  -- System
  --

  awful.key({ 'Mod4', 'Shift' }, 'q', function(c)
      c:kill()
    end),

  awful.key({ 'Mod4', 'Shift' }, 'i', function(c)
    local msg = 'name: ' .. c.name

    local attrs = {
      'instance',
      'class',
      'role',
      'type',
      'floating',
      'maximized',
    }

    for i, attr in ipairs(attrs) do
      msg = ('%s\n%s: %s'):format(msg, attr, c[attr])
    end

    naughty.notify({ text = msg })
  end),

  awful.key({ 'Mod4', 'Control', 'Shift' }, 'r', function(c)
    c.floating = false
    c.maximized = false
    c.fullscreen = false
  end),

  --
  -- Layout
  --

  awful.key({ 'Mod4' }, 'f', function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
  end),

  awful.key({ 'Mod4' }, 'm', function(c)
    c:move_to_tag(awful.clientbuffer)
    c.minimized = true
  end)
)

--
-- Client Buttons
--

bindings.clientbuttons = gears.table.join(
  awful.button({}, 1, function(c)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
  end),

  awful.button({ 'Control' }, 3, function(c)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
    awful.mouse.client.resize(c)
  end),

  awful.button({ 'Control' }, 2, function(c)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
    awful.mouse.client.move(c)
  end),

  awful.button({ 'Control', 'Shift' }, 1, function(c)
    dashboard:toggle()
    bindings.grab_mouse_until_released()
  end),

  awful.button({ 'Control', 'Shift' }, 2, function(c)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
    c.floating = not c.floating
  end),

  awful.button({ 'Control', 'Shift' }, 4, function()
    local c = awful.client.next(1)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
    awful.placement.centered(mouse, { parent = c })
  end),

  awful.button({ 'Control', 'Shift' }, 5, function()
    local c = awful.client.next(-1)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
    awful.placement.centered(mouse, { parent = c })
  end)
)

dashboard:connect_signal('button::press', function(_, _, _, button, mods)
  if
    #mods == 2
    and gears.table.hasitem(mods, 'Control')
    and gears.table.hasitem(mods, 'Shift')
  then
    if button == 1 then
      dashboard:toggle()
    end
  end
end)

--
-- Return
--

root.keys(bindings.globalkeys)
return bindings
