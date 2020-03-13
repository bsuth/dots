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
-- @return table : { x: float, y: float, width: float, height: float }
--
function apply_template(workarea, template)
    return {
        x      = geometry.x      * template.width  + template.x,
        y      = geometry.y      * template.height + template.y,
        width  = geometry.width  * template.width,
        height = geometry.height * template.height,
    }
end


---------------------------------------
-- CLIENT STACK
---------------------------------------

local ClientStack = {}

function ClientStack:new()
    local client_stack = {
        stack = {},
        stack_pointer = 1,
    }

    setmetatable(client_stack, { __index = self })
    return client_stack
end


function ClientStack:has(client)
    for _, _client in ipairs(self.stack) do
        if _client == client then
            return true
        end
    end

    return false
end


function ClientStack:push(client)
    table.insert(self.stack, 1, client)
end


function ClientStack:pop()
    table.remove(self.stack, 1)
end


function ClientStack:prev()
    self.stack_pointer = (self.stack_pointer) % #self.stack + 1
end


function ClientStack:commit()
    table.insert(self.stack, 1, table.remove(self.stack, self.stack_pointer))
    self.stack_pointer = 1
end


---------------------------------------
-- LAYOUT STATE
---------------------------------------

local TabtileState = {}

function TabtileState:new()
    local state = {
        client_stacks = {},
        master_geometries = {},
        workarea = {},
    }

    for i = 1, #TEMPLATES do
        master_geometries.client_stacks[i] = ClientStack:new()
        master_geometries.geometries[i] = {}
    end

    setmetatable(state, { __index = self })
    return state
end

function TabtileState:push(client)
    self.client_stacks[1]:push(client)
end

function TabtileState:set_workarea(workarea, master_count)
    self.workarea = workarea
    for i, template in ipairs(TEMPLATES[master_count]) do
        self.master_geometries[i] = apply_template(self.workarea, template)
    end
end

function TabtileState:get_client_geometry(client)
    for i, stack in ipairs(self.stacks) do
        if stack:has(client) then
            return self.master_geometries[i]
        end
    end

    self:push(client)
    return self.geometries[1]
end


---------------------------------------
-- TABTILE LAYOUT
---------------------------------------

-- Actually arrange clients of p.clients for tabbed layout
-- @param layout_params: Mandatory table containing required informations for
-- layouts (clients to arrange, workarea geometry, etc.)
-- See: awful.layout.parameters

function get_dist_func(dir, client_geometry)
    if (dir == 'left') then
        return function(geometry)
            return client_geometry.x - geometry.x
        end
    elseif (dir == 'right') then
        return function(geometry)
            return geometry.x - client_geometry.x
        end
    elseif (dir == 'up') then
        return function(geometry)
            return client_geometry.y - geometry.y
        end
    else
        return function(geometry)
            return geometry.y - client_geometry.y
        end
    end
end


-- Actually arrange clients of p.clients for tabbed layout
-- @param layout_params: Mandatory table containing required informations for
-- layouts (clients to arrange, workarea geometry, etc.)
-- See: awful.layout.parameters

local tabtile = function (tag)
    local state = TabtileState:new()

    function arrange(p)
        state:set_workarea(p.workarea, tag.master_count)
        for _, client in ipairs(p.clients) do
            p.geometries[client] = layout_state:get_client_geometry(client)
        end
    end

    function shift_by_dir(dir, client)
        local client_geometry_template = nil
        local new_client_geometry_template = nil

        for i, stack in ipairs(layout_state.stacks) do
            if stack:has(client) then
                client_geometry_template = TEMPLATES[tag.master_count][i]
                break
            end
        end

        local min_dist = 2
        local dist_func = get_dist_func(dir, client_geometry_template)

        for _, geometry_template in ipairs(TEMPLATES[tag.master_count]) do
            local dist = dist_func(geometry)
            if dist > 0 and dist < min_dist then
                new_client_geometry_template = geometry_template
                min_dist = dist
            end
        end

        local new_client_geometry = apply_template(state.workarea)
        client:geometry(new_client_geometry or client_geometry)
    end

    return {
        name = 'tabtile',
        arrange = function(p) arrange(p) end,
        is_dynamic = true,
        shift_by_dir = shift_by_dir,
    }
end

return tabtile 
