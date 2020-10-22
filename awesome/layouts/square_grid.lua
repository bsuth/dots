local gears = require 'gears' 

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

local _state = {}

--------------------------------------------------------------------------------
-- LOCAL FUNCTIONS
--------------------------------------------------------------------------------

local function _refresh_cache(n)
    local b = math.floor(math.sqrt(n)) 
    local shortrow_ncols = math.floor(n / b)
    local longrow_ncols = shortrow_ncols + 1
    local nlongrows = n % b

    _state.cache = {
        n = n,
        b = b,
        shortrow_ncols = shortrow_ncols,
        longrow_ncols = longrow_ncols,
        nlongrows = nlongrows,
        last_in_longrow = nlongrows * longrow_ncols - 1,
    }
end

--------------------------------------------------------------------------------
-- FUNCTIONS
--------------------------------------------------------------------------------

function arrange_client(wa, i, n)
    if n ~= _state.cache.n then _refresh_cache(n) end

    local cache = _state.cache
    local geometry = { height = wa.height / cache.b }
    local z = i - cache.last_in_longrow - 1

    if z < 0 then
        local col = i % cache.longrow_ncols
        local row = math.floor(i / cache.longrow_ncols)

        geometry.width = wa.width / cache.longrow_ncols
        geometry.x = wa.x + geometry.width * col
        geometry.y = wa.y + geometry.height * row
    else
        local col = z % cache.shortrow_ncols
        local row = cache.nlongrows + math.floor(z / cache.shortrow_ncols)

        geometry.width = wa.width / cache.shortrow_ncols
        geometry.x = wa.x + geometry.width * col
        geometry.y = wa.y + geometry.height * row
    end

    return geometry
end

function arrange(p)
    local wa = p.workarea
    local cls = p.clients

    for i = 1, #cls do
        p.geometries[cls[i]] = arrange_client(wa, i - 1, #cls)
    end
end

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

gears.table.crush(_state, {
    cache = { n = -1 },
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return {
    name = 'square_grid', -- required
    arrange = arrange,
    arrange_client = arrange_client,
}
