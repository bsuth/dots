local catnip = require('catnip')
local ouputs = require('utils.outputs')
local tile = require('tile')

local function get_focused_workspace()
  for output in catnip.outputs do
    for _, window in ipairs(output.data.workspaces.active.windows) do
      if window.focused then
        return output.data.workspaces.active
      end
    end
  end

  return outputs.get_focused_output().data.workspaces.active
end

local function tile_workspace(workspace)
  local num_windows = #workspace.windows

  local layout = {
    gap = 4,
    x = workspace.output.x + 4,
    y = workspace.output.y + 4,
    width = workspace.output.width - 8,
    height = workspace.output.height - 8,
  }

  if layout.width < layout.height then
    if num_windows < 3 then
      tile.split_vertical(workspace.windows, layout)
    else
      tile.grid_vertical(workspace.windows, layout)
    end
  elseif num_windows < 4 then
    tile.master_left(workspace.windows, layout)
  else
    tile.grid_horizontal(workspace.windows, layout)
  end
end

local function activate_workspace(workspaces, workspace)
  for _, window in ipairs(workspaces.active.windows) do
    window.visible = false
  end

  workspaces.active = workspace

  for _, window in ipairs(workspace.windows) do
    window.visible = true
  end
end

catnip.subscribe('output::create', function(output)
  local workspace = { output = output, windows = {} }
  output.data.workspaces = { active = workspace, workspace }
end)

catnip.subscribe('window::create', function(window)
  local focused_workspace = get_focused_workspace()
  table.insert(focused_workspace.windows, window)
  tile_workspace(focused_workspace)
end)
