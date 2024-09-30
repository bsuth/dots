---@module 'extern.catnip'

---@class CatmintTileSpace
---@field x number
---@field y number
---@field width number
---@field height number
---@field gap number

---@type table<string, fun(windows: CatnipWindow[], space: CatmintTileSpace)>
local M = {}

-- Stretches all windows to fill the entire tile space. If there is more than 1
-- window, they will be stacked on top of each other in the order provided by
-- `windows`.
--
-- -------------------------
-- |                       |
-- |                       |
-- |                       |
-- |        1, 2, 3        |
-- |                       |
-- |                       |
-- |                       |
-- -------------------------
function M.max(windows, space)
  for _, window in ipairs(windows) do
    window.x = space.x
    window.y = space.y
    window.width = space.width
    window.height = space.height
  end
end

-- Splits the horizontal tile space evenly among all windows and tiles windows
-- from left to right.
--
-- -------------------------
-- |       |       |       |
-- |       |       |       |
-- |       |       |       |
-- |   1   |   2   |   3   |
-- |       |       |       |
-- |       |       |       |
-- |       |       |       |
-- -------------------------
function M.split_horizontal(windows, space)
  local num_windows = #windows
  local total_gap = space.gap * (num_windows - 1)
  local window_width = (space.width - total_gap) / num_windows

  for i, window in ipairs(windows) do
    window.x = space.x + (i - 1) * (window_width + space.gap)
    window.y = space.y
    window.width = window_width
    window.height = space.height
  end
end

-- Splits the vertical tile space evenly among all windows and tiles windows
-- from top to bottom.
--
-- -------------------------
-- |           1           |
-- |                       |
-- -------------------------
-- |           2           |
-- |                       |
-- -------------------------
-- |           3           |
-- |                       |
-- -------------------------
function M.split_vertical(windows, space)
  local num_windows = #windows
  local total_gap = space.gap * (num_windows - 1)
  local window_height = (space.height - total_gap) / num_windows

  for i, window in ipairs(windows) do
    window.x = space.x
    window.y = space.y + (i - 1) * (window_height + space.gap)
    window.width = space.width
    window.height = window_height
  end
end

-- Splits the horizontal tile space in half. The first window fills the left
-- half of the tile space, while the remaining windows are tiled in the right
-- half via `split_horizontal`.
--
-- -------------------------
-- |           |           |
-- |           |     2     |
-- |           |           |
-- |     1     |-----------|
-- |           |           |
-- |           |     3     |
-- |           |           |
-- -------------------------
function M.master_left(windows, space)
  local num_windows = #windows

  if num_windows < 2 then
    M.max(windows, space)
    return
  end

  local column_width = (space.width - space.gap) / 2

  M.max({ windows[1] }, {
    gap = space.gap,
    x = space.x,
    y = space.y,
    width = column_width,
    height = space.height,
  })

  local slaves = {}
  for i = 2, num_windows do
    table.insert(slaves, windows[i])
  end

  M.split_vertical(slaves, {
    gap = space.gap,
    x = space.x + space.width - column_width,
    y = space.y,
    width = column_width,
    height = space.height,
  })
end

-- Splits the horizontal tile space in half. The first window fills the right
-- half of the tile space, while the remaining windows are tiled in the left
-- half via `split_horizontal`.
--
-- -------------------------
-- |           |           |
-- |     2     |           |
-- |           |           |
-- |-----------|     1     |
-- |           |           |
-- |     3     |           |
-- |           |           |
-- -------------------------
function M.master_right(windows, space)
  local num_windows = #windows

  if num_windows < 2 then
    M.max(windows, space)
    return
  end

  local column_width = (space.width - space.gap) / 2

  M.max({ windows[1] }, {
    gap = space.gap,
    x = space.x + space.width - column_width,
    y = space.y,
    width = column_width,
    height = space.height,
  })

  local slaves = {}
  for i = 2, num_windows do
    table.insert(slaves, windows[i])
  end

  M.split_vertical(slaves, {
    gap = space.gap,
    x = space.x,
    y = space.y,
    width = column_width,
    height = space.height,
  })
end

-- Tiles the windows into a grid based on the closest square number less than
-- the number of windows provided. If the number of windows is not a perfect
-- square, rows will be "padded" with additional columns until the next perfect
-- square, at which point a new row is added.
--
-- -------------------------
-- |           |           |
-- |     1     |     2     |
-- |           |           |
-- |-----------------------|
-- |           |           |
-- |     3     |     4     |
-- |           |           |
-- -------------------------
--
-- -------------------------
-- |     |     |     |     |
-- |  1  |  2  |  3  |  4  |
-- |     |     |     |     |
-- |-----------------------|
-- |       |       |       |
-- |   5   |   6   |   7   |
-- |       |       |       |
-- -------------------------
--
-- -------------------------
-- |   1   |   2   |   3   |
-- |-----------------------|
-- |   4   |   5   |   6   |
-- |-----------------------|
-- |   7   |   8   |   9   |
-- -------------------------
function M.grid_horizontal(windows, space)
  local num_windows = #windows
  local num_rows = math.floor(math.sqrt(num_windows))
  local min_cols = math.floor(num_windows / num_rows)
  local num_padded_rows = num_windows % num_rows

  local total_row_gap = space.gap * (num_rows - 1)
  local window_height = (space.height - total_row_gap) / num_rows

  local window_index = 1

  for row = 1, num_rows do
    local num_cols = row <= num_padded_rows and min_cols + 1 or min_cols
    local row_windows = {}

    for _ = 1, num_cols do
      table.insert(row_windows, windows[window_index])
      window_index = window_index + 1
    end

    M.split_horizontal(row_windows, {
      gap = space.gap,
      x = space.x,
      y = space.y + (row - 1) * (window_height + space.gap),
      width = space.width,
      height = window_height,
    })
  end
end

-- Tiles the windows into a grid based on the closest square number less than
-- the number of windows provided. If the number of windows is not a perfect
-- square, columns will be "padded" with additional rows until the next perfect
-- square, at which point a new column is added.
--
-- -------------------------
-- |           |           |
-- |     1     |     3     |
-- |           |           |
-- |-----------------------|
-- |           |           |
-- |     2     |     4     |
-- |           |           |
-- -------------------------
--
-- -------------------------
-- |     1     |           |
-- |           |     5     |
-- |-----------|           |
-- |     2     |-----------|
-- |           |           |
-- |-----------|     6     |
-- |     3     |           |
-- |           |-----------|
-- |-----------|           |
-- |     4     |     7     |
-- |           |           |
-- -------------------------
--
-- -------------------------
-- |   1   |   4   |   7   |
-- |-----------------------|
-- |   2   |   5   |   8   |
-- |-----------------------|
-- |   3   |   6   |   9   |
-- -------------------------
function M.grid_vertical(windows, space)
  local num_windows = #windows
  local num_cols = math.floor(math.sqrt(num_windows))
  local min_rows = math.floor(num_windows / num_cols)
  local num_padded_cols = num_windows % num_cols

  local total_column_gap = space.gap * (num_cols - 1)
  local window_width = (space.width - total_column_gap) / num_cols

  local window_index = 1

  for col = 1, num_cols do
    local num_rows = col <= num_padded_cols and min_rows + 1 or min_rows
    local col_windows = {}

    for _ = 1, num_rows do
      table.insert(col_windows, windows[window_index])
      window_index = window_index + 1
    end

    M.split_vertical(col_windows, {
      gap = space.gap,
      x = space.x + (col - 1) * (window_width + space.gap),
      y = space.y,
      width = window_width,
      height = space.height,
    })
  end
end

return M
