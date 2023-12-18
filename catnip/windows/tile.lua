local catnip = require('catnip')
local window_utils = require('windows.utils')

local function tile_max(windows, layout)
  for _, window in ipairs(windows) do
    window.x = layout.x
    window.y = layout.y
    window.width = layout.width
    window.height = layout.height
  end
end

local function tile_split_horizontal(windows, layout)
  local num_windows = #windows
  local total_gap = layout.gap * (num_windows - 1)
  local window_width = (layout.width - total_gap) / num_windows

  for i, window in ipairs(windows) do
    window.x = layout.x + (i - 1) * (window_width + layout.gap)
    window.y = layout.y
    window.width = window_width
    window.height = layout.height
  end
end

local function tile_split_vertical(windows, layout)
  local num_windows = #windows
  local total_gap = layout.gap * (num_windows - 1)
  local window_height = (layout.height - total_gap) / num_windows

  for i, window in ipairs(windows) do
    window.x = layout.x
    window.y = layout.y + (i - 1) * (window_height + layout.gap)
    window.width = layout.width
    window.height = window_height
  end
end

local function tile_master_left(windows, layout)
  local num_windows = #windows

  if num_windows < 2 then
    tile_max(windows, layout)
    return
  end

  local column_width = (layout.width - layout.gap) / 2

  tile_max({ windows[1] }, {
    gap = layout.gap,
    x = layout.x,
    y = layout.y,
    width = column_width,
    height = layout.height,
  })

  local slaves = {}
  for i = 2, num_windows do
    table.insert(slaves, windows[i])
  end

  tile_split_vertical(slaves, {
    gap = layout.gap,
    x = layout.x + layout.width - column_width,
    y = layout.y,
    width = column_width,
    height = layout.height,
  })
end

local function tile_grid_horizontal(windows, layout)
  local num_windows = #windows

  local num_rows = math.floor(math.sqrt(num_windows))
  local min_cols = math.floor(num_windows / num_rows)
  local num_padded_rows = num_windows % num_rows

  local total_row_gap = layout.gap * (num_rows - 1)
  local window_height = (layout.height - total_row_gap) / num_rows

  local window_index = 1

  for row = 1, num_rows do
    local num_cols = row <= num_padded_rows and min_cols + 1 or min_cols
    local row_windows = {}

    for col = 1, num_cols do
      table.insert(row_windows, windows[window_index])
      window_index = window_index + 1
    end

    tile_split_horizontal(row_windows, {
      gap = layout.gap,
      x = layout.x,
      y = layout.y + (row - 1) * (window_height + layout.gap),
      width = layout.width,
      height = window_height,
    })
  end
end

local function tile_grid_vertical(windows, layout)
  local num_windows = #windows

  local num_cols = math.floor(math.sqrt(num_windows))
  local min_rows = math.floor(num_windows / num_cols)
  local num_padded_cols = num_windows % num_cols

  local total_column_gap = layout.gap * (num_cols - 1)
  local window_width = (layout.width - total_column_gap) / num_cols

  local window_index = 1

  for col = 1, num_cols do
    local num_rows = col <= num_padded_cols and min_rows + 1 or min_rows
    local col_windows = {}

    for row = 1, num_rows do
      table.insert(col_windows, windows[window_index])
      window_index = window_index + 1
    end

    tile_split_vertical(col_windows, {
      gap = layout.gap,
      x = layout.x + (col - 1) * (window_width + layout.gap),
      y = layout.y,
      width = window_width,
      height = layout.height,
    })
  end
end

catnip.subscribe('bsuth::tile', function()
  for _, output in ipairs(catnip.outputs) do
    local num_output_windows = 0

    local output_windows = table.filter(window_utils.get_output_windows(output), function(window)
      if window.visible then
        num_output_windows = num_output_windows + 1
        return true
      end
    end)

    local gap = 4
    local padding = { top = 4, right = 4, bottom = 4, left = 4 }

    local layout = {
      gap = gap,
      x = output.x + padding.left,
      y = output.y + padding.top,
      width = output.width - (padding.right + padding.left),
      height = output.height - (padding.top + padding.bottom ),
    }

    if layout.width < layout.height then
      if num_output_windows < 3 then
        tile_split_vertical(output_windows, layout)
      else
        tile_grid_vertical(output_windows, layout)
      end
    elseif num_output_windows < 4 then
      tile_master_left(output_windows, layout)
    else
      tile_grid_horizontal(output_windows, layout)
    end
  end
end)

catnip.subscribe('window::create', function()
  catnip.publish('bsuth::tile')
end)

catnip.subscribe('window::destroy', function()
  catnip.publish('bsuth::tile')
end)
