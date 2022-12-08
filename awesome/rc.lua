-- Autofocus another client when the current one is closed
require('awful/autofocus')

-- load erde
require('erde').load()

-- load modules
require('core.bindings')
require('core.layout')
require('core.rules')
require('core.theme')
require('core.misc')
require('clientBuffer')
