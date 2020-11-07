local awful = require 'awful' 

local _model = require 'models/abstract'

--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------

local model = _model.new({
	_modelname = 'tag_manager',
    taglists = {},
    counters = {},
})

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function model:add(focus, s)
    s = s or awful.screen.focused()
	self.counters[s.index] = self.counters[s.index] + 1

	local tag = awful.tag.add(tostring(self.counters[s.index]), {
		screen = s,
		layout = awful.layout.suit.tile,
	})

    if focus then tag:view_only() end
    table.insert(self.taglists[s.index], tag)
	self:emit_signal('update')
	return tag
end

function model:focus(reversed)
    local s = awful.screen.focused()
    local taglist = self.taglists[s.index]

    local increment = reversed and -1 or 1
    local wrap_tag = reversed and taglist[#taglist] or taglist[1]

    for i, tag in ipairs(taglist) do
        if tag == s.selected_tag then
            (taglist[i + increment] or wrap_tag):view_only()
            break
        end
    end

	self:emit_signal('update')
end

function model:move(reversed)
    local s = awful.screen.focused()
    local taglist = self.taglists[s.index]

    for i, tag in ipairs(taglist) do
        if tag == s.selected_tag then
            if i == 1 and reversed then
                table.remove(taglist, i)
                table.insert(taglist, tag)
            elseif i == #taglist and not reversed then
                table.remove(taglist, i)
                table.insert(taglist, 1, tag)
            else
                local swap_index = i + (reversed and -1 or 1)
                taglist[i] = taglist[swap_index]
                taglist[swap_index] = tag
            end

            break
        end
    end

	self:emit_signal('update')
end

--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------

-- Auto remove any unfocused empty tags at the end of the taglist
awful.screen.connect_for_each_screen(function(s)
    s:connect_signal('tag::history::update', function()
		local taglist = model.taglists[s.index]
        local last_tag = taglist[#taglist]

        if (
			s.selected_tag == last_tag or
			#taglist == 1 or 
			#last_tag:clients() ~= 0
		) then
			return
		end

		while #last_tag:clients() == 0 do
			model.counters[s.index] = model.counters[s.index] - 1
			last_tag:delete()
			taglist[#taglist] = nil
			last_tag = taglist[#taglist]
		end

		model:emit_signal('update')
    end)
end)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

awful.screen.connect_for_each_screen(function(s)
    model.taglists[s.index] = {}
    model.counters[s.index] = 0
    model:add(false, s):view_only()
end)

return model
