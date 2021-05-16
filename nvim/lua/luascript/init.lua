local luascriptroot = debug.getinfo(1).source:match("@(.*)init.lua$")
package.path = package.path..';'..luascriptroot..'?.lua';

local luascript = {
  typecheck = require 'typecheck',
  String = require 'String',
  Array = require 'Array',
  path = require 'path',
}

function luascript.expose()
  for k, v in pairs(luascript) do
    _G[k] = v
  end
end

return luascript
