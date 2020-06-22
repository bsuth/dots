
---------------------------------------
-- DUAL LAYOUT
---------------------------------------

local dual = {
    name = 'dual', -- required!
}

---------------------------------------
-- ARRANGE
---------------------------------------

local function _arrange_one(wa)
    local pwidth = 0.9
    local pheight = 0.9

    return {
        x = wa.x + ((1 - pwidth) / 2) * wa.width,
        y = wa.y + ((1 - pheight) / 2) * wa.height,
        width = pwidth * wa.width,
        height = pheight * wa.height,
    }
end

local function _arrange_two(wa, pbot)
    local left = {
        x = wa.x,
        y = wa.y,
        width = wa.width / 2,
        height = wa.height - pbot,
    }

    local right = {
        x = wa.x + (wa.width / 2),
        y = wa.y,
        width = wa.width / 2,
        height = wa.height - pbot,
    }

    return left, right
end

local function _arrange_bot(wa, i, xoff, size)
    return {
        x = wa.x + xoff + (i * size),
        y = wa.y + wa.height - size,
        width = size,
        height = size,
    }
end

function dual.arrange(p)
    local wa = p.workarea
    local cls = p.clients

    if #cls == 0 then
        return
    elseif #cls == 1 then
        p.geometries[cls[1]] = _arrange_one(wa)
    elseif #cls == 2 then
        p.geometries[cls[1]], p.geometries[cls[2]] = _arrange_two(wa, 0)
    else
        local size = math.min(0.15 * wa.height, wa.width / (#cls - 2))
        local xoff = (wa.width - (size * (#cls - 2))) / 2

        p.geometries[cls[1]], p.geometries[cls[2]] = _arrange_two(wa, size)

        for i = 3, #cls do
            p.geometries[cls[i]] = _arrange_bot(wa, i - 3, xoff, size)
        end
    end
end

---------------------------------------
-- RETURN
---------------------------------------

return dual
