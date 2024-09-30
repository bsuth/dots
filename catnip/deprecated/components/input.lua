local catnip = require('catnip')
local keys = require('lib.keys')

---@class Input
---@field value string
---@field position number
---@field _on_keypress fun(keyboard: CatnipKeyboard, event: CatnipKeyEvent)
local Input = {}
local InputMT = { __index = Input }

-- -----------------------------------------------------------------------------
-- WORDCHARS
-- -----------------------------------------------------------------------------

local WORDCHARS = { _ = true }

for byte = string.byte('0'), string.byte('9') do
  WORDCHARS[string.char(byte)] = true
end

for byte = string.byte('a'), string.byte('z') do
  WORDCHARS[string.char(byte)] = true
end

for byte = string.byte('A'), string.byte('Z') do
  WORDCHARS[string.char(byte)] = true
end

local ENV_WORDCHARS = os.getenv('WORDCHARS')

if ENV_WORDCHARS ~= nil then
  for i = 1, #ENV_WORDCHARS do
    WORDCHARS[ENV_WORDCHARS:sub(i, i)] = true
  end
end

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

---@param chars string
function Input:insert(chars)
  self.value = self.value:sub(0, self.position) .. chars .. self.value:sub(self.position + 1)
  self.position = self.position + #chars
end

function Input:move_char_back()
  self.position = math.max(0, self.position - 1)
end

function Input:move_char_forward()
  self.position = math.min(#self.value, self.position + 1)
end

function Input:move_word_back()
  if self.position == 0 then
    return
  end

  local new_position = self.position
  local char = self.value:sub(new_position, new_position)

  while new_position > 0 and not WORDCHARS[char] do
    new_position = new_position - 1
    char = self.value:sub(new_position, new_position)
  end

  while new_position > 0 and WORDCHARS[char] do
    new_position = new_position - 1
    char = self.value:sub(new_position, new_position)
  end

  self.position = new_position
end

function Input:move_word_forward()
  local len = #self.value

  if self.position == len then
    return
  end

  local new_position = self.position
  local next_char = self.value:sub(new_position + 1, new_position + 1)

  while new_position < len and WORDCHARS[next_char] do
    new_position = new_position + 1
    next_char = self.value:sub(new_position + 1, new_position + 1)
  end

  while new_position < len and not WORDCHARS[next_char] do
    new_position = new_position + 1
    next_char = self.value:sub(new_position + 1, new_position + 1)
  end

  self.position = new_position
end

function Input:move_line_start()
  self.position = 0
end

function Input:move_line_end()
  self.position = #self.value
end

function Input:delete_char_back()
  if self.position > 0 then
    self.value = self.value:sub(1, self.position - 1) .. self.value:sub(self.position + 1)
    self.position = self.position - 1
  end
end

function Input:delete_char_forward()
  if self.position < #self.value then
    self.value = self.value:sub(1, self.position) .. self.value:sub(self.position + 2)
  end
end

function Input:delete_word_back()
  if self.position == 0 then
    return
  end

  local new_position = self.position
  local char = self.value:sub(new_position, new_position)

  while new_position > 0 and not WORDCHARS[char] do
    new_position = new_position - 1
    char = self.value:sub(new_position, new_position)
  end

  while new_position > 0 and WORDCHARS[char] do
    new_position = new_position - 1
    char = self.value:sub(new_position, new_position)
  end

  self.value = self.value:sub(1, new_position) .. self.value:sub(self.position + 1)
  self.position = new_position
end

function Input:delete_word_forward()
  local len = #self.value

  if self.position == len then
    return
  end

  local new_position = self.position + 1
  local char = self.value:sub(new_position, new_position)

  while new_position < len and not WORDCHARS[char] do
    new_position = new_position + 1
    char = self.value:sub(new_position, new_position)
  end

  while new_position <= len and WORDCHARS[char] do
    new_position = new_position + 1
    char = self.value:sub(new_position, new_position)
  end

  self.value = self.value:sub(1, self.position) .. self.value:sub(new_position)
end

function Input:delete_line_start()
  if self.position > 0 then
    self.value = self.value:sub(self.position + 1)
    self.position = 0
  end
end

function Input:delete_line_end()
  if self.position < #self.value then
    self.value = self.value:sub(1, self.position)
  end
end

---@param event CatnipKeyEvent
function Input:keypress(event)
  event.propagate = false

  local key_event_serials = keys.serialize_key_event(event)
  local has_modifiers = keys.key_event_has_modifiers(event)

  -- TODO: support clipboard? custom keybindings?
  if keys.match(key_event_serials, {}, 'Left') then
    self:move_char_back()
  elseif keys.match(key_event_serials, {}, 'Right') then
    self:move_char_forward()
  elseif keys.match(key_event_serials, { 'ctrl' }, 'b') then
    self:move_char_back()
  elseif keys.match(key_event_serials, { 'ctrl' }, 'f') then
    self:move_char_forward()
  elseif keys.match(key_event_serials, { 'mod1' }, 'b') then
    self:move_word_back()
  elseif keys.match(key_event_serials, { 'mod1' }, 'f') then
    self:move_word_forward()
  elseif keys.match(key_event_serials, { 'ctrl' }, 'a') then
    self:move_line_start()
  elseif keys.match(key_event_serials, { 'ctrl' }, 'e') then
    self:move_line_end()
  elseif keys.match(key_event_serials, {}, 'BackSpace') then
    self:delete_char_back()
  elseif keys.match(key_event_serials, { 'ctrl' }, 'd') then
    self:delete_char_forward()
  elseif keys.match(key_event_serials, { 'mod1' }, 'BackSpace') then
    self:delete_word_back()
  elseif keys.match(key_event_serials, { 'mod1' }, 'd') then
    self:delete_word_forward()
  elseif keys.match(key_event_serials, { 'ctrl' }, 'u') then
    self:delete_line_start()
  elseif keys.match(key_event_serials, { 'ctrl' }, 'k') then
    self:delete_line_end()
  elseif not has_modifiers and event.char ~= nil then
    self:insert(event.char)
  end
end

-- -----------------------------------------------------------------------------
-- Public
-- -----------------------------------------------------------------------------

function Input:start()
  catnip.subscribe('keyboard::keypress', self._on_keypress)
end

---@param canvas CatnipCanvas
---@param options CatnipCanvasTextOptions
function Input:render(canvas, options)
  local width, height = canvas:text(self.value:sub(1, self.position), options)

  canvas:rectangle({
    x = options.x + width,
    y = options.y - 1,
    width = 1,
    height = height + 2,
    fill_color = options.color or 0x000000,
  })

  options.x = options.x + width
  canvas:text(self.value:sub(self.position + 1), options)
end

function Input:stop()
  catnip.unsubscribe('keyboard::keypress', self._on_keypress)
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return function()
  local input = setmetatable({
    value = '',
    position = 0,
  }, InputMT)

  input._on_keypress = function(_, event)
    input:keypress(event)
  end

  return input
end
