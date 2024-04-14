local catnip = require('catnip')
local keymap = require('keymap')
local onedark = require('onedark')

local BAR_HEIGHT = 24

local workspaces = {
  {
    label = 'hello',
    active = true,
    window_ids = { 1, 2, 3 },
  },
  {
    label = 'world',
    active = false,
    window_ids = { 4, 5 },
  },
}

local canvas = catnip.canvas({
  x = 0,
  y = 0,
  width = 800,
  height = BAR_HEIGHT,
  visible = true,
})

keymap({ 'ctrl' }, 'b', function()
  canvas:clear()

  local num_workspaces = #workspaces
  local width = canvas.width / num_workspaces

  for i, workspace in ipairs(workspaces) do
    local x = (i - 1) * width

    canvas:rectangle({
      x = x,
      y = 0,
      width = width,
      height = BAR_HEIGHT,
      fill_color = workspace.active and onedark.light_gray or onedark.dark_gray,
    })

    canvas:text(workspace.label, {
      x = x,
      width = width,
      height = BAR_HEIGHT,
      color = onedark.white,
      align = 'center',
      valign = 'center',
    })
  end
end)
