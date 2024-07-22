local catnip = require('catnip')
local onedark = require('lib.onedark')
local output_utils = require('lib.output_utils')

local system_prompt = {
  canvas = catnip.canvas({
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    visible = false,
  })
}

function system_prompt:render()
  self.canvas:rectangle({
    width = self.canvas.width,
    height = self.canvas.height,
    fill_color = onedark.dark_gray,
    fill_opacity = 0.8,
  })
end

function system_prompt:toggle()
  if system_prompt.canvas.visible then
    system_prompt.canvas.visible = false
    return
  end

  local focused_output = output_utils.get_focused_output()
  if focused_output == nil then return end

  system_prompt.canvas.x = focused_output.x
  system_prompt.canvas.y = focused_output.y
  system_prompt.canvas.z = 99
  system_prompt.canvas.width = focused_output.width
  system_prompt.canvas.height = focused_output.height
  system_prompt.canvas.visible = true

  system_prompt:render()
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return system_prompt
