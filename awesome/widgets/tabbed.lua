---------------------------------------------------------------------------
--                      Tabbed Layout
--
--        (1)                (2)                (3)
--   +-----+-----+      +-----+-----+      +-----+-----+
--   |           |      |     |     |      |     |  2  |
--   |     1     |  ->  |  1  |  2  |  ->  |  1  |-----|
--   |           |      |     |     |      |     |  3  |
--   +-----+-----+      +-----+-----+      +-----+-----+
---------------------------------------------------------------------------

local awful = require('awful')
local naughty = require('naughty')

---------------------------------------
-- GLOBALS
---------------------------------------

--
-- Templates to describe the layout based on the tag property `master_count`.
-- `master_count` may be used to index directly into this table to get the
-- current template schema, with each index in that table referring to the
-- geometry that master should assume. The template fields are values in [0, 1]
-- and represent the percentage of each field in the tag's workarea geometry.
--
-- For example, x = 0.5 for a template w/ index [3][2] means that when there
-- are three masters, the second master should be placed halfway across the
-- workarea (often close if not equal to the screen size).
--
local TEMPLATES = {
    {
        { x = 0, y = 0, width = 1, height = 1 },
    },
    {
        { x = 0, y = 0, width = 0.5, height = 1 },
        { x = 0.5, y = 0, width = 0.5, height = 1 },
    },
    {
        { x = 0, y = 0, width = 0.5, height = 1 },
        { x = 0.5, y = 0, width = 0.5, height = 0.5 },
        { x = 0.5, y = 0.5, width = 0.5, height = 0.5 },
    },
}
local MAX_MASTER_COUNT = #TEMPLATES


---------------------------------------
-- HELPERS
---------------------------------------

--
-- Derive a master's geometry from the workarea using one of the templates
-- from TEMPLATES. See TEMPLATES above for an explanation of the template
-- schema.
--
-- @param table workarea : { x: float, y: float, width: float, height: float }
-- @param table template : { x: float, y: float, width: float, height: float }
-- @return table         : { x: float, y: float, width: float, height: float }
--
function apply_template(workarea, template)
    return {
        x      = template.x      * workarea.width  + workarea.x,
        y      = template.y      * workarea.height + workarea.y,
        width  = template.width  * workarea.width,
        height = template.height * workarea.height,
    }
end

--
-- TODO
--
-- @param string dir        : left|right|up|down
-- @param table prev_master : TEMPLATES[_][_]
-- @param int master_count  : [1, #TEMPLATES]
-- @return table            : TEMPLATES[_][_]
--
function get_rel_dir_master_id(prev_master_id, dir, master_count)
    local dist_func = get_dist_func(dir, TEMPLATES[master_count][prev_master_id])
    local min_dist = 2 -- anything larger than 1 is fine (template values in [0, 1])
    local next_master_id = nil

    for i, master in ipairs(TEMPLATES[master_count]) do
        local dist = dist_func(master)
        if dist > 0 and dist < min_dist then
            next_master_id = i
            min_dist = dist
        end
    end

    return next_master_id
end

--
-- TODO
--
-- @param table prev_template : TEMPLATES[_][_]
-- @param string dir          : left|right|up|down
-- @throw error               : if `dir` is invalid
-- @return function           : dist function between geometries that will be
--                              generated from template and prev_template
--
function get_dist_func(dir, prev_template)
    if (dir == 'left') then
        return function(template)
            return prev_template.x - template.x
        end
    elseif (dir == 'right') then
        return function(template)
            return template.x - prev_template.x
        end
    elseif (dir == 'up') then
        return function(template)
            return prev_template.y - template.y
        end
    elseif (dir == 'down') then
        return function(template)
            return template.y - prev_template.y
        end
    else
        error()
        naughty.notify({ text = 'Tabtile: Invalid direction' })
    end
end


---------------------------------------
-- MASTER
---------------------------------------

local Master = {}

function Master:new(id)
    local master = {
        id = id,
        geometry = nil,
        client_stack = {},
        stack_pointer = 1,
    }

    setmetatable(master, { __index = self })
    return master
end


function Master:has(client)
    for _, _client in ipairs(self.client_stack) do
        if _client == client then
            return true
        end
    end

    return false
end

function Master:set_geometry(geometry)
    self.geometry = geometry
    for _, client in ipairs(self.client_stack) do
        client:geometry(geometry)
    end
end

function Master:push(client)
    -- clients must be floating in order for awesomewm to allow clients to
    -- truly overlap
    client.floating = true
    client.tabtile_master_id = self.id
    client:geometry(self.geometry)
    client:raise()
    table.insert(self.client_stack, 1, client)
end


function Master:pop(client)
    for i, _client in ipairs(self.client_stack) do
        if _client == client then
            table.remove(self.client_stack, i)
            return
        end
    end
end


function Master:prev()
    self.stack_pointer = (self.stack_pointer) % #self.client_stack + 1
    self.client_stack[self.stack_pointer]:raise()
end


function Master:commit()
    local new_client_stack_top = table.remove(self.client_stack, self.stack_pointer)
    table.insert(self.client_stack, 1, new_client_stack_top)
    self.stack_pointer = 1
end


---------------------------------------
-- LAYOUT STATE
---------------------------------------

local TabtileState = {}


function TabtileState:new(tag)
    local state = {
        masters = {},
        tag = tag,
        workarea = nil,
    }

    for i = 1, MAX_MASTER_COUNT do
        state.masters[i] = Master:new(i)
    end

    for _, client in ipairs(tag:clients()) do
        state.masters[1]:push(client)
    end

    setmetatable(state, { __index = self })
    return state
end


function TabtileState:update_workarea(workarea)
    self.workarea = workarea
    for i, template in ipairs(TEMPLATES[self.tag.master_count]) do
        local new_master_geometry = apply_template(workarea, template)
        self.masters[i]:set_geometry(new_master_geometry)
    end
end


---------------------------------------
-- API
---------------------------------------

local TabtileApi = {}

function TabtileApi:new(state)
    local api = {
        state = state,
    }

    setmetatable(api, { __index = self })
    return api
end

function TabtileApi:client_mv_rel_dir(client, dir)
    local new_master_id = get_rel_dir_master_id(
        client.tabtile_master_id,
        dir,
        self.state.tag.master_count
    )

    if new_master_id then
        self.state.masters[client.tabtile_master_id]:pop(client)
        self.state.masters[new_master_id]:push(client)
    end
end

function TabtileApi:prev()
    local master_id = client.focus.tabtile_master_id
    self.state.masters[master_id]:prev()
end

function TabtileApi:commit()
    local master_id = client.focus.tabtile_master_id
    self.state.masters[master_id]:commit()
end


---------------------------------------
-- TABTILE LAYOUT
---------------------------------------

--
-- TODO
--
local tabtile = function (tag)
    local state = TabtileState:new(tag)
    local api = TabtileApi:new(state)

    --
    -- TODO
    -- @param layout_params: Mandatory table containing required informations for
    -- layouts (clients to arrange, workarea geometry, etc.)
    -- See: awful.layout.parameters
    --
    function arrange(p)
        if (p.workarea ~= state.workarea) then
            state:update_workarea(p.workarea)
        end
    end

    return {
        name = 'tabtile',
        is_dynamic = true,
        arrange = arrange,
        api = api,
    }
end

return tabtile 
