local awful = require('awful')
local naughty = require('naughty')
local cjson = require('cjson')
local layout = require('layout')

-- Private tag used to move clients around tags
awful.clientbuffer = awful.tag.add('_clientbuffer', {
  screen = awful.screen.focused(),
  layout = layout,
})

local function getScreenBackupFileName(s)
  return '/tmp/awesome_tag_backup_screen' .. tostring(s.index)
end

local function backupScreenTags(s)
  local newBackup = {}
  for i, tag in pairs(s.tags) do
    if #tag.name > 0 and not tag.name:match('^_') then
      newBackup[tag.name] = {}

      for j, c in pairs(tag:clients()) do
        -- check if PID is actually available
        if type(c.pid) == 'number' then
          table.insert(newBackup[tag.name], c.pid)
        end
      end
    end
  end

  local backupFile = io.open(getScreenBackupFileName(s), 'w')

  if not backupFile then
    -- TODO: notify of error
  else
    backupFile:write(cjson.encode(newBackup))
    backupFile:close()
  end
end

-- -----------------------------------------------------------------------------
-- Restore Tags
-- -----------------------------------------------------------------------------

awful.screen.connect_for_each_screen(function(s)
  local backupFile = io.open(getScreenBackupFileName(s), 'rb')

  if not backupFile then
    -- TODO: notify of error
  else
    local backup = cjson.decode(backupFile:read('*a'))
    backupFile:close()

    local tagNames = {}

    for tagName, clientPids in pairs(backup) do
      if not tagName:match('^_') then
        tagNames[#tagNames + 1] = tagName
      end
    end

    -- Need to use awful.tag here, since awful.tag.add fails to set the screen's
    -- selected_tag appropriately
    awful.tag(tagNames, s, layout)

    -- Wait until startup to assign clients. For some reason s.tags is not
    -- actually set until startup.
    awesome.connect_signal('startup', function()
      for i, tag in pairs(s.tags) do
        if backup[tag.name] then
          for j, pid in pairs(backup[tag.name]) do
            for c in awful.client.iterate() do
              if c.pid == pid then
                c:move_to_tag(tag)
              end
            end
          end
        end
      end
    end)
  end
end)

-- -----------------------------------------------------------------------------
-- Backup Tags
-- TODO: add more signals to backup, this is not enough
-- -----------------------------------------------------------------------------

awful.screen.connect_for_each_screen(function(s)
  s:connect_signal('tag::history::update', function()
    backupScreenTags(s)
  end)
end)
