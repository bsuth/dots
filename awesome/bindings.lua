local awful = require('awful')
local dashboard = require('dashboard')
local gears = require('gears')
local models = require('models')
local naughty = require('naughty')
local scratchpad = require('scratchpad')

--
-- Keybindings
--

local bindings = {}

--
-- Helpers
--

local function grab_mouse_until_released()
  mousegrabber.run(function(mouse)
    for _, v in pairs(mouse.buttons) do
      if v then
        return true
      end
    end
    return false
  end, 'mouse')
end

local function global_move_client(dir)
  local oldId = awful.client.idx(client.focus)
  awful.client.swap.bydirection(dir)
  local newId = awful.client.idx(client.focus)

  if oldId.col == newId.col and oldId.idx == newId.idx then
    local newScreen = awful.screen.focused():get_next_in_direction(dir)
    client.focus:move_to_screen(newScreen)
  end
end

--
-- Global Keys
--

bindings.globalkeys = gears.table.join(

  --
  -- System
  --

  awful.key({ 'Mod4', 'Shift' }, 'Escape', function()
      awesome.quit()
    end),

  awful.key({ 'Mod4', 'Shift' }, 'r', function()
    awesome.restart()
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
    models.locale:cycle()
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
    global_move_client('left')
  end),
  awful.key({ 'Mod4', 'Shift' }, 'j', function()
    global_move_client('down')
  end),
  awful.key({ 'Mod4', 'Shift' }, 'k', function()
    global_move_client('up')
  end),
  awful.key({ 'Mod4', 'Shift' }, 'l', function()
    global_move_client('right')
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

  awful.key({ 'Mod4', 'Control', 'Shift' }, 'h', function()
    awful.client.swap.global_bydirection('left')
  end),
  awful.key({ 'Mod4', 'Control', 'Shift' }, 'j', function()
    awful.client.swap.global_bydirection('down')
  end),
  awful.key({ 'Mod4', 'Control', 'Shift' }, 'k', function()
    awful.client.swap.global_bydirection('up')
  end),
  awful.key({ 'Mod4', 'Control', 'Shift' }, 'l', function()
    awful.client.swap.global_bydirection('right')
  end),

  --
  -- Navbar
  --

  awful.key({ 'Mod4' }, 'space', function()
    awful.screen.focused().navbar:refresh({ mode = 'dmenu' })
  end),
  awful.key({ 'Mod4' }, 't', function()
    awful.screen.focused().navbar:newTag()
  end),
  awful.key({ 'Mod4' }, 'w', function()
    awful.screen.focused().navbar:closeTag()
  end),
  awful.key({ 'Mod4', 'Shift' }, ',', function()
    awful.screen.focused().navbar:shiftTag(-1)
  end),
  awful.key({ 'Mod4', 'Shift' }, '.', function()
    awful.screen.focused().navbar:shiftTag(1)
  end),
  awful.key({ 'Mod4' }, 'Tab', function()
    awful.screen.focused().navbar:nextTag()
  end),
  awful.key({ 'Mod4', 'Shift' }, 'Tab', function()
    awful.screen.focused().navbar:prevTag()
  end),
  awful.key({ 'Mod4' }, 'r', function()
    awful.screen.focused().navbar:renameTag()
  end),

  --
  -- Client Buffer
  --

  awful.key({ 'Mod4' }, 'm', function()
    client.focus:move_to_tag(awful.clientbuffer)
    client.focus.minimized = true
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

  --
  -- Spawners
  --

  awful.key({ 'Mod4' }, 'Return', function()
    awful.spawn('st -e nvim -c ":Dirvish"')
  end),
  awful.key({ 'Mod4' }, "'", function()
    awful.spawn('firefox-developer-edition')
  end),
  awful.key({ 'Mod4' }, ";", function()
    scratchpad.toggle()
  end),
  awful.key({ 'Mod4' }, 'p', function()
    dashboard:toggle()
  end)
)

--
-- Client Keys
--

bindings.clientkeys = gears.table.join(
  awful.key({ 'Mod4', 'Shift' }, 'q', function(c)
      c:kill()
    end),

  awful.key({ 'Mod4' }, 'f', function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
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

  awful.key({ 'Mod4', 'Control', 'Shift' }, 'i', function(c)
    c.floating = false
    c.maximized = false
    c.fullscreen = false
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
    dashboard:toggle()
    grab_mouse_until_released()
  end)
)

dashboard.wibox:connect_signal(
  'button::press',
  function(self, lx, ly, button, mods)
    if
      #mods == 1
      and gears.table.hasitem(mods, 'Control')
      and button == 3
    then
      dashboard:toggle()
    end
  end
)

--
-- Return
--

root.keys(bindings.globalkeys)
return bindings
