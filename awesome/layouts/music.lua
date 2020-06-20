local naughty = require('naughty')

---------------------------------------
-- INIT
---------------------------------------

local music = {
    name = 'music'
}

local config = {
    double = {
        mplayer = {
            width = 0.6,
        },
    },
    cava = {
        width = 0.8,
        height = 0.3,
    },
}

---------------------------------------
-- ARRANGE
---------------------------------------

local function _arrange_cava(wa)
    local pwidth = 0.8
    local pheight = 0.3

    return {
        x = wa.x + ((1 - pwidth) / 2) * wa.width,
        y = wa.y + (1 - pheight) * wa.height,
        width = pwidth * wa.width,
        height = pheight * wa.height,
    }
end

local function _arrange_one(wa)
    local pwidth = 0.8
    local pheight = 0.8

    return {
        x = wa.x + ((1 - pwidth) / 2) * wa.width,
        y = wa.y + ((1 - pheight) / 2) * wa.height,
        width = pwidth * wa.width,
        height = pheight * wa.height,
    }
end

local function _arrange_two(wa, gcava)
    local pwidth = 0.8

    return {
        x = wa.x + ((1 - pwidth) / 2) * wa.width,
        y = wa.y,
        width = pwidth * wa.width,
        height = wa.height - gcava.height,
    }
end

local function _arrange_panel(wa, gcava, i, n)
    return {
        x = wa.x + (i * wa.width / n),
        y = wa.y,
        width = wa.width / n,
        height = wa.height - gcava.height,
    }
end

local function _arrange_tile(wa, gcava, i, n)
    if i % 2 == 0 then
        i = i / 2
        n = math.ceil(n / 2)

        return {
            x = wa.x + (i * wa.width / n),
            y = wa.y,
            width = wa.width / n,
            height = (wa.height - gcava.height) / 2,
        }
    else
        i = (i - 1) / 2
        n = math.floor(n / 2)

        return {
            x = wa.x + (i * wa.width / n),
            y = wa.y + ((wa.height - gcava.height) / 2),
            width = wa.width / n,
            height = (wa.height - gcava.height) / 2,
        }
    end
end

function music.arrange(p)
    local wa = p.workarea
    local cls = p.clients

    if #cls == 0 then
        return
    elseif #cls == 1 then
        p.geometries[cls[1]] = _arrange_one(wa)
    else
        local gcava = _arrange_cava(wa)
        p.geometries[cls[1]] = gcava

        if #cls == 2 then
            p.geometries[cls[2]] = _arrange_two(wa, gcava)
        elseif #cls < 5 then
            for i = 2, #cls do
                p.geometries[cls[i]] = _arrange_panel(wa, gcava, i - 2, #cls - 1)
            end
        else
            for i = 2, #cls do
                p.geometries[cls[i]] = _arrange_tile(wa, gcava, i - 2, #cls - 1)
            end
        end
    end
end

---------------------------------------
-- RETURN
---------------------------------------

return music
