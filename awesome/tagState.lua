local awful = require('awful')
local gears = require('gears')
local naughty = require('naughty')
local cjson = require('cjson')
local layout = require('layout')

local tagState = {}
local TAGSTATE_BACKUP_FILENAME = '/tmp/awesomewm_tag_state_backup'
local tagStateBackup = {}

do
  local tagStateBackupFile = io.open(TAGSTATE_BACKUP_FILENAME, 'rb')
  if tagStateBackupFile then
    tagStateBackup = cjson.decode(tagStateBackupFile:read('*a'))
    tagStateBackupFile:close()
  end
end

-- -----------------------------------------------------------------------------
-- Restore Tags
-- -----------------------------------------------------------------------------

function tagState.clear()
  local tagStateBackupFile = io.open(TAGSTATE_BACKUP_FILENAME, 'w')
  if tagStateBackupFile then
    tagStateBackupFile:write('{}')
    tagStateBackupFile:close()
  end
end

function tagState.backup()
  tagStateBackup = {}

  for s in screen do
    local screenBackup = {}

    for _, tag in ipairs(s.tags) do
      if not tag.name:match('^_') then
        local tagBackup = { name = tag.name }

        for _, c in ipairs(tag:clients()) do
          -- check if PID is actually available
          if type(c.pid) == 'number' then
            table.insert(tagBackup, c.pid)
          end
        end

        table.insert(screenBackup, tagBackup)
      end
    end
    
    tagStateBackup[s.index] = screenBackup
  end

  local tagStateBackupFile = io.open(TAGSTATE_BACKUP_FILENAME, 'w')

  if tagStateBackupFile then
    tagStateBackupFile:write(cjson.encode(tagStateBackup))
    tagStateBackupFile:close()
  end
end

function tagState.restoreScreen(s)
  local screenBackup = tagStateBackup[s.index]

  if not screenBackup then
    return false
  end

  do
    local tagNames = {}

    for _, tagBackup in ipairs(screenBackup) do
      table.insert(tagNames, tagBackup.name)
    end

    -- Need to use awful.tag here, since awful.tag.add fails to set the screen's
    -- selected_tag appropriately
    awful.tag(tagNames, s, layout)
  end

  -- Wait until startup to assign clients. For some reason s.tags is not
  -- actually set until startup.
  awesome.connect_signal('startup', function()
    local clientPidLookup = {}
    for c in awful.client.iterate() do
      -- check if PID is actually available
      if type(c.pid) == 'number' then
        clientPidLookup[c.pid] = c
      end
    end

    for i, tagBackup in ipairs(screenBackup) do
      for _, clientPid in ipairs(tagBackup) do
        local c = clientPidLookup[clientPid]
        if c ~= nil then c:move_to_tag(s.tags[i]) end
      end
    end
  end)

  return true
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return tagState
