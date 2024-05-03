local C = require('constants')
local catnip = require('catnip')
local catmint = require('utils.catmint')
local onedark = require('utils.onedark')

-- TODO: rename
-- TODO: "backround" windows
-- TODO: hide bar if only one window

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

local function render(output)
  local canvas = output.data.bar

  canvas.width = output.width
  canvas.height = C.BAR_HEIGHT
  canvas:clear()

  local windows, num_windows = catmint.get_output_windows(output)
  table.sort(windows, function(a, b) return a.z < b.z end)

  local width = canvas.width / num_windows

  for i, window in ipairs(windows) do
    local x = (i - 1) * width
    local text = window.data.title or ("%s [%s]"):format(window.title, window.id)

    canvas:rectangle({
      x = x,
      y = 0,
      width = width,
      height = C.BAR_HEIGHT,
      fill_color = i == num_windows and onedark.light_gray or onedark.dark_gray,
    })

    canvas:text(text, {
      x = x,
      y = 0,
      width = width,
      height = C.BAR_HEIGHT,
      color = onedark.white,
      align = 'center',
      valign = 'center',
    })
  end
end

local function rerender()
  for output in catnip.outputs do
    render(output)
  end

  catnip.unsubscribe('tick', rerender)
end

local function queue_rerender()
  catnip.subscribe('tick', rerender)
end

-- -----------------------------------------------------------------------------
-- Subscriptions
-- -----------------------------------------------------------------------------

catnip.subscribe('output::create', function(output)
  output.data.bar = catnip.canvas({
    x = output.x,
    y = output.y,
    width = output.width,
    height = C.BAR_HEIGHT,
    visible = true,
  })

  queue_rerender()
end)

catnip.subscribe('window::create', queue_rerender)
catnip.subscribe('window::update::z', queue_rerender)
catnip.subscribe('window::destroy', queue_rerender)
