local erde = require('erde')
erde.load()
local ok, result = xpcall(function() require('init') end, erde.rewrite)
if not ok then error(result) end
