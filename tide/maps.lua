local mappings = require("tide.mappings")
local utils = require("tide.utils")

mappings.addMapping("j", function()
	utils.scroll(0, 100)
end)
mappings.addMapping("k", function()
	utils.scroll(0, -100)
end)
mappings.addMapping("d", function()
	utils.scroll(0, 500)
end)
mappings.addMapping("u", function()
	utils.scroll(0, -500)
end)
