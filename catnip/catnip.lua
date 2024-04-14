-- README
--
-- Note that since the C core populates `path.loaded.catnip` when initializing
-- the lua_State, `require('catnip')` will always return the core C module and
-- _not_ this module.

local catnip = require('catnip') --- @type Catnip
return catnip

--- @alias CatnipDirection 'left' | 'right' | 'up' | 'down'

--- @alias CatnipResourceList<T> { [number]: T } | fun(): T

--- @class CatnipResourcePosition
--- @field x number
--- @field y number
--- @field move fun(self: self, x: number, y: number)

--- @class CatnipResourceSize
--- @field width number
--- @field height number
--- @field resize fun(self: self, width: number, height: number)

--- @class CatnipResource
--- @field id number
--- @field subscribe fun(self: self, event: string, callback: fun(...)): fun(...)
--- @field unsubscribe fun(self: self, event: string, callback: fun(...))
--- @field publish fun(self: self, event: string, ...)

--- @class (exact) Catnip
--- @field cursor CatnipCursor
--- @field keyboards CatnipResourceList<CatnipKeyboard>
--- @field outputs CatnipResourceList<CatnipOutput>
--- @field windows CatnipResourceList<CatnipWindow>
--- @field canvas fun(): CatnipCanvas
--- @field subscribe fun(event: string, callback: fun(...)): fun(...)
--- @field unsubscribe fun(event: string, callback: fun(...))
--- @field publish fun(event: string, ...)
--- @field reload fun()
--- @field quit fun()

--- @class (exact) CatnipCanvas: CatnipResource, CatnipResourcePosition, CatnipResourceSize
--- @field z number
--- @field visible boolean
--- @field path fun(canvas: CatnipCanvas, path: CatnipCanvasPath)
--- @field png fun(canvas: CatnipCanvas, png: string, options: CatnipCanvasPngOptions?)
--- @field svg fun(canvas: CatnipCanvas, svg: string, options: CatnipCanvasSvgOptions?)
--- @field text fun(canvas: CatnipCanvas, text: string, options: CatnipCanvasTextOptions?)
--- @field clear fun(canvas: CatnipCanvas)
--- @field destroy fun(canvas: CatnipCanvas)

--- @class (exact) CatnipCanvasPath
--- @field fill_color number?
--- @field fill_opacity number?
--- @field stroke_color number?
--- @field stroke_opacity number?
--- @field stroke_size number?
-- TODO: Support typing path commands?

--- @class (exact) CatnipCanvasPngOptions
--- @field x number?
--- @field y number?
--- @field width number?
--- @field height number?

--- @class (exact) CatnipCanvasSvgOptions
--- @field x number?
--- @field y number?
--- @field width number?
--- @field height number?
--- @field stylesheet string?

--- @class (exact) CatnipCanvasTextOptions
--- @field x number?
--- @field y number?
--- @field width number?
--- @field height number?
--- @field align ('left' | 'center' | 'right')?
--- @field color number?
--- @field ellipsis (boolean | 'start' | 'middle' | 'end')?
--- @field font string?
--- @field italic boolean?
--- @field opacity number?
--- @field size number?
--- @field weight number?
--- @field wrap (boolean | 'char' | 'word' | 'auto')?

--- @class (exact) CatnipCursor: CatnipResource, CatnipResourcePosition
--- @field name string
--- @field size number
--- @field theme string

--- @class (exact) CatnipKeyboard: CatnipResource
--- @field name string
--- @field xkb_rules string?
--- @field xkb_model string?
--- @field xkb_layout string?
--- @field xkb_variant string?
--- @field xkb_options string?

--- @class (exact) CatnipOutput: CatnipResource, CatnipResourcePosition, CatnipResourceSize
--- @field refresh number
--- @field mode CatnipOutputMode
--- @field modes CatnipResourceList<CatnipOutputMode>
--- @field scale number

--- @class (exact) CatnipOutputMode: CatnipResource
--- @field width number
--- @field height number
--- @field refresh number

--- @class (exact) CatnipWindow: CatnipResource, CatnipResourcePosition, CatnipResourceSize
--- @field z number
--- @field visible boolean
--- @field focused boolean
--- @field destroy fun(window: CatnipWindow)
