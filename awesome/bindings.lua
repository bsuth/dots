local awful = require('awful')
local dashboard = require('dashboard')
local gears = require('gears')
local models = require('models')
local naughty = require('naughty')

--
-- Keybindings
--

local bindings = {}

local scratchpad = {
  client = nil,
  width = 900,
  height = 600,
}

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

local function global_swap_tags(dir)
  local screen1 = awful.screen.focused()
  local screen2 = screen1:get_next_in_direction(dir)
  screen1.selected_tag:swap(screen2.selected_tag)
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
    global_swap_tags('left')
  end),
  awful.key({ 'Mod4', 'Control', 'Shift' }, 'j', function()
    global_swap_tags('down')
  end),
  awful.key({ 'Mod4', 'Control', 'Shift' }, 'k', function()
    global_swap_tags('up')
  end),
  awful.key({ 'Mod4', 'Control', 'Shift' }, 'l', function()
    global_swap_tags('right')
  end),

  --
  -- TagTabs
  --

  awful.key({ 'Mod4' }, 'n', function()
    awful.screen.focused().tagTabs:toggle()
  end),
  awful.key({ 'Mod4' }, 't', function()
    awful.screen.focused().tagTabs:new()
  end),
  awful.key({ 'Mod4' }, 'w', function()
    awful.screen.focused().tagTabs:close()
  end),
  awful.key({ 'Mod4' }, 'Tab', function()
    awful.screen.focused().tagTabs:next()
  end),
  awful.key({ 'Mod4', 'Shift' }, 'Tab', function()
    awful.screen.focused().tagTabs:prev()
  end),
  awful.key({ 'Mod4' }, 'r', function()
    awful.screen.focused().tagTabs:rename()
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
  -- Scratchpad
  --

  awful.key({ 'Mod4' }, ';', function()
    local screen = awful.screen.focused()
    local x = screen.geometry.x + (screen.geometry.width - scratchpad.width) / 2
    local y = screen.geometry.y
      + (screen.geometry.height - scratchpad.height) / 2

    if scratchpad.client == nil or not scratchpad.client.valid then
      awful.spawn('st -e nvim -c ":term"', {
        name = 'scratchpad',
        floating = true,
        screen = screen,
        width = scratchpad.width,
        height = scratchpad.height,
        x = x,
        y = y,

        callback = function(c)
          naughty.notify({ text = 'hi' })
          scratchpad.client = c
          c.floating = true,
        c:emit_signal('request::activate', 'client.jumpto', { raise = true })
        end,
      })
    elseif scratchpad.client.hidden then
      gears.table.crush(scratchpad.client, {
        screen = screen,
        hidden = false,
        x = x,
        y = y,
      })

      scratchpad.client:emit_signal(
        'request::activate',
        'client.jumpto',
        { raise = true }
      )
    else
      scratchpad.client.hidden = true
    end
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
  -- awful.key({ 'Mod4' }, 'space', function()
  --   awful.spawn('rofi -show run')
  -- end),
  awful.key({ 'Mod4' }, 'space', function()
    -- TODO: awesome-rofi
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
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
    awful.mouse.client.resize(c)
  end),

  awful.button({ 'Control' }, 2, function(c)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
    awful.mouse.client.move(c)
  end),

  awful.button({ 'Control', 'Shift' }, 1, function(c)
    dashboard:toggle()
    grab_mouse_until_released()
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
