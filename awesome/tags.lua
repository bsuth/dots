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

  for i, tag in ipairs(s.tags) do
    if #tag.name > 0 and not tag.name:match('^_') then
      local clients = {}
      for j, c in ipairs(tag:clients()) do
        -- check if PID is actually available
        if type(c.pid) == 'number' then
          clients[#clients + 1] = c.pid
        end
      end

      newBackup[#newBackup + 1] = {
        name = tag.name,
        clients = clients,
      }
    end
  end

  local backupFile = io.open(getScreenBackupFileName(s), 'w')

  if backupFile then
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
    -- Default tags
    awful.tag({ '1' }, s, layout)
  else
    local backup = cjson.decode(backupFile:read('*a'))
    backupFile:close()

    local tagNames = {}

    for i, tagBackup in ipairs(backup) do
      if not tagBackup.name:match('^_') then
        tagNames[#tagNames + 1] = tagBackup.name
      end
    end

    if #tagNames == 0 then
      -- Default tags
      awful.tag({ '1' }, s, layout)
    else
      -- Need to use awful.tag here, since awful.tag.add fails to set the screen's
      -- selected_tag appropriately
      awful.tag(tagNames, s, layout)
    end

    -- Wait until startup to assign clients. For some reason s.tags is not
    -- actually set until startup.
    awesome.connect_signal('startup', function()
      local tagNameLookup = {}
      for i, tag in ipairs(s.tags) do
        tagNameLookup[tag.name] = tag
      end

      local clientPidLookup = {}
      for c in awful.client.iterate() do
        -- check if PID is actually available
        if type(c.pid) == 'number' then
          clientPidLookup[c.pid] = c
        end
      end

      for i, tagBackup in ipairs(backup) do
        local tag = tagNameLookup[tagBackup.name]
        if tag ~= nil then
          for j, pid in ipairs(tagBackup.clients) do
            local c = clientPidLookup[pid]
            if c ~= nil then
              c:move_to_tag(tag)
            end
          end
        end
      end
    end)
  end
end)

-- -----------------------------------------------------------------------------
-- Backup Tags
-- -----------------------------------------------------------------------------

awful.screen.connect_for_each_screen(function(s)
  -- Required when adding or deleting tags
  s:connect_signal('tag::history::update', function()
    backupScreenTags(s)
  end)
end)

awful.tag.attached_connect_signal(nil, 'tagged', function(tag)
  backupScreenTags(tag.screen)
end)

awful.tag.attached_connect_signal(nil, 'untagged', function(tag)
  backupScreenTags(tag.screen)
end)

client.connect_signal('swapped', function(c)
  backupScreenTags(c.screen)
end)
