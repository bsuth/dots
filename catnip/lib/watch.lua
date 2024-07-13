local catnip = require('catnip')

local watchers = {}
local num_watchers = 0

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

local function pack(...)
  return { n = select('#', ...), ... }
end

local function compare_watched_values(old, new)
  if old.n ~= new.n then
    return true
  end

  for i = 1, old.n do
    if old[i] ~= new[i] then
      return true
    end
  end

  return false
end

local function flush_watchers()
  for watcher in pairs(watchers) do
    local old_watched_values = watcher.watched_values
    local new_watched_values = pack(watcher.get_watched_values())

    if compare_watched_values(old_watched_values, new_watched_values) then
      watcher.on_change(unpack(new_watched_values))
    end

    watcher.watched_values = new_watched_values
  end
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

---@param get_watched_values fun(): ...
---@param on_change fun(...)
---@return fun()
return function(get_watched_values, on_change)
  local watcher = {
    get_watched_values = get_watched_values,
    watched_values = {},
    on_change = on_change,
  }

  watchers[watcher] = true
  num_watchers = num_watchers + 1

  if num_watchers == 1 then
    catnip.subscribe('tick', flush_watchers)
  end

  return function()
    watchers[watcher] = nil
    num_watchers = num_watchers - 1

    if num_watchers == 0 then
      catnip.unsubscribe('tick', flush_watchers)
    end
  end
end
