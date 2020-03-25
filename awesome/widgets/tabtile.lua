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
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

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

--
-- This is used internally and given its own variable for readability reasons.
-- DO NOT CHANGE THIS.
--
local MAX_MASTER_COUNT = #TEMPLATES

--
-- Controls the height of the tabbar.
--
local TABBAR_HEIGHT = 30

--
-- create_callback needed if we wish to use clienticon
--
local TABBAR_TASKLIST_TEMPLATE = {
    {
        {
            {
                {
                    id     = 'clienticon',
                    widget = awful.widget.clienticon,
                },
                top = 5, right = 5, bottom = 5, left = 0,
                widget  = wibox.container.margin,
            },
            {
                id     = 'text_role',
                widget = wibox.widget.textbox,
            },
            layout = wibox.layout.fixed.horizontal,
        },
        top = 0, right = 10, bottom = 0, left  = 10,
        widget = wibox.container.margin
    },
    id     = 'background_role',
    widget = wibox.container.background,

    create_callback = function(self, client, index, objects)
        self:get_children_by_id('clienticon')[1].client = client
    end,
}


---------------------------------------
-- HELPERS
---------------------------------------

--
-- TODO
--
-- @param string msg
--
function throw(msg)
    if (type(msg) ~= 'string') then
        naughty.notify({ text = 'Invalid type to `throw(msg: string)`, how ironic.' })
        error('Invalid type to `throw(msg: string)`, how ironic.')
    else
        naughty.notify({ text = msg })
        error(msg)
    end
end

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
    local geometry = {
        x      = template.x      * workarea.width  + workarea.x + beautiful.border_width,
        y      = template.y      * workarea.height + workarea.y + beautiful.border_width,
        width  = template.width  * workarea.width - 2 * beautiful.border_width,
        height = template.height * workarea.height - 2 * beautiful.border_width,
    }

    -- The workare already takes care of the useless gap, but we still need to
    -- account for the useless gap in between masters

    if template.x ~= 0 then
        geometry.x = geometry.x + beautiful.useless_gap
        geometry.width = geometry.width - beautiful.useless_gap
    end

    if template.x + template.width ~= 1 then
        geometry.width = geometry.width - beautiful.useless_gap
    end

    if template.y ~= 0 then
        geometry.y = geometry.y + beautiful.useless_gap
        geometry.height = geometry.height - beautiful.useless_gap
    end

    if template.y + template.height ~= 1 then
        geometry.height = geometry.height - beautiful.useless_gap
    end

    return geometry
end

--
-- TODO
--
-- @param table template1 : TEMPLATES[_][_]
-- @param table template2 : TEMPLATES[_][_]
-- @param string dim      : x|y
-- @return bool
--
function check_template_overlap(template1, template2, dim)
    local side = (dim == 'x' and 'width') or 
        (dim == 'y' and 'height') or
        throw('Tabtile::check_template_overlap: Invalid dim')

    if template1[dim] < template2[dim] then
        return template2[dim] < template1[dim] + template1[side]
    end

    return template1[dim] < template2[dim] + template2[side]
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
            return check_template_overlap(template, prev_template, 'y') and
                prev_template.x - template.x or 0
        end
    elseif (dir == 'right') then
        return function(template)
            return check_template_overlap(template, prev_template, 'y') and
                template.x - prev_template.x or 0
        end
    elseif (dir == 'up') then
        return function(template)
            return check_template_overlap(template, prev_template, 'x') and
                prev_template.y - template.y or 0
        end
    elseif (dir == 'down') then
        return function(template)
            return check_template_overlap(template, prev_template, 'x') and
                template.y - prev_template.y or 0
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


function Master:new(id, tag)
    local master = {
        id = id,
        tag = tag,
        geometry = nil,
        client_geometry = nil,
        client_stack = {},
        stack_pointer = 1,
        tabbar = wibox({ screen = tag.screen }),
    }

    local tasklist = awful.widget.tasklist({
        screen  = tag.screen,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        source = function() return master.client_stack end,
        widget_template = TABBAR_TASKLIST_TEMPLATE,
    })

    master.tabbar:setup({
        tasklist,
        layout = wibox.layout.flex.horizontal,
    })

    -- DEBUG: need to extend this to popups as well
    -- DEBUG: need tabbar to update instantly
    -- DEBUG: need to hide tabbar with master_count
    client.connect_signal('unmanage', function()
        local new_client_stack = {}
        for _, client in ipairs(master.client_stack) do
            if client.valid then
                new_client_stack[#new_client_stack + 1] = client
            end
        end
        master.client_stack = new_client_stack
    end)

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

    self.client_geometry = {
        x = geometry.x,
        y = geometry.y + TABBAR_HEIGHT,
        width = geometry.width,
        height = geometry.height - TABBAR_HEIGHT,
    }

    self.tabbar:geometry({
        x = geometry.x,
        y = geometry.y,
        width = geometry.width + 2 * beautiful.border_width,
        height = TABBAR_HEIGHT,
    })

    for _, client in ipairs(self.client_stack) do
        client:geometry(self.client_geometry)
    end
end


function Master:push(client)
    -- clients must be floating in order for awesomewm to allow clients to
    -- truly overlap
    client.floating = true
    client.tabtile_master_id = self.id
    client:geometry(self.client_geometry)
    client:raise()

    -- Wrap client's `kill()` to clean up tabtile references
    client.tabtile_kill = function()
        self:pop(client)
        client:kill()
    end

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
    local sp = self.stack_pointer
    self.stack_pointer = (sp == #self.client_stack and 1 or sp + 1)
    self.client_stack[self.stack_pointer]:raise()
end


function Master:next()
    local sp = self.stack_pointer
    self.stack_pointer = (sp == 1 and #self.client_stack or sp - 1)
    self.client_stack[self.stack_pointer]:raise()
end


function Master:commit()
    local new_client_stack_top = table.remove(self.client_stack, self.stack_pointer)
    table.insert(self.client_stack, 1, new_client_stack_top)
    self.stack_pointer = 1

    -- emit a fake focus event to force the tabbar to update
    new_client_stack_top:emit_signal('focus')
end


function Master:autoclean()
    local new_client_stack = {}
    for _, client in ipairs(self.client_stack) do
        if client.valid then
            new_client_stack[#new_client_stack + 1] = client
        end
    end
    self.client_stack = new_client_stack
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
        state.masters[i] = Master:new(i, tag)
    end

    state.masters[1].tabbar.visible = true

    for _, client in ipairs(tag:clients()) do
        state.masters[1]:push(client)
    end

    client.connect_signal('manage', function (client)
        state.masters[1]:push(client)
    end)

    setmetatable(state, { __index = self })
    return state
end


function TabtileState:arrange()
    for i, template in ipairs(TEMPLATES[self.tag.master_count]) do
        local new_master_geometry = apply_template(self.workarea, template)
        self.masters[i]:set_geometry(new_master_geometry)
    end
end


function TabtileState:transfer_client(client, new_master_id)
    self.masters[client.tabtile_master_id]:pop(client)
    self.masters[new_master_id]:push(client)

    -- emit a fake focus event to force the tabbar to update
    client:emit_signal('focus')
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
        self.state:transfer_client(client, new_master_id)
    end
end


function TabtileApi:prev()
    local master_id = client.focus.tabtile_master_id
    self.state.masters[master_id]:prev()
end

function TabtileApi:next()
    local master_id = client.focus.tabtile_master_id
    self.state.masters[master_id]:next()
end

function TabtileApi:commit()
    local master_id = client.focus.tabtile_master_id
    self.state.masters[master_id]:commit()
end


function TabtileApi:incnmaster(delta)
    local new_master_count = self.state.tag.master_count + delta

    if 1 <= new_master_count and new_master_count <= MAX_MASTER_COUNT then
        if delta < 0 then
            for i = self.state.tag.master_count, new_master_count + 1 do
                local master = self.state.masters[i]
                master.tabbar.visible = false

                for _, client in ipairs(master.client_stack) do
                    self.state:transfer_client(client, new_master_count)
                end
            end
        elseif delta > 0 then
            for i = self.state.tag.master_count + 1, new_master_count do
                self.state.masters[i].tabbar.visible = true
            end
        end

        awful.tag.incnmaster(delta)
    end
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
            state.workarea = p.workarea
            state:arrange()
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
