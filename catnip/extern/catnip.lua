---@meta catnip

---@alias CatnipResourceList<T> { [number]: T } | fun(): T

---@class CatnipResource
---@field data table
---@field subscribe fun(self: self, event: string, callback: fun(...)): fun(...)
---@field unsubscribe fun(self: self, event: string, callback: fun(...))
---@field publish fun(self: self, event: string, ...)

---@class (exact) Catnip
---@field cursor CatnipCursor
---@field outputs CatnipResourceList<CatnipOutput>
---@field windows CatnipResourceList<CatnipWindow>
---@field keyboards CatnipResourceList<CatnipKeyboard>
---@field canvas fun(params: table): CatnipCanvas
---@field png fun(path: string): CatnipPng
---@field svg fun(document: string): CatnipSvg
---@field subscribe fun(event: string, callback: fun(...)): fun(...)
---@field unsubscribe fun(event: string, callback: fun(...))
---@field publish fun(event: string, ...)
---@field reload fun()
---@field quit fun()

---@class (exact) CatnipPng
---@field path string

---@class (exact) CatnipSvg
---@field document string
---@field apply fun(self: CatnipSvg, stylesheet: string)

---@class (exact) CatnipCanvas: CatnipResource
---@field x number
---@field y number
---@field z number
---@field width number
---@field height number
---@field visible boolean
---@field path fun(self: CatnipCanvas, path: CatnipCanvasPath)
---@field rectangle fun(self: CatnipCanvas, path: CatnipCanvasRectangle)
---@field circle fun(self: CatnipCanvas, path: CatnipCanvasCircle)
---@field text fun(self: CatnipCanvas, text: string, options: CatnipCanvasTextOptions?)
---@field png fun(self: CatnipCanvas, png: CatnipPng, options: CatnipCanvasPngOptions?)
---@field svg fun(self: CatnipCanvas, svg: CatnipSvg, options: CatnipCanvasSvgOptions?)
---@field clear fun(self: CatnipCanvas)
---@field destroy fun(self: CatnipCanvas)

---@alias CatnipCanvasPathCloseCommand { [1]: 'close' | 'CLOSE' }
---@alias CatnipCanvasPathMoveCommand { [1]: 'move' | 'MOVE', [2]: number, [3]: number }
---@alias CatnipCanvasPathLineCommand { [1]: 'line' | 'LINE', [2]: number, [3]: number }
---@alias CatnipCanvasPathArcCommand { [1]: 'arc' | 'ARC', [2]: number, [3]: number, [4]: number }
---@alias CatnipCanvasPathBezierCommand { [1]: 'bezier' | 'Bezier', [2]: number, [3]: number, [4]: number, [5]: number, [6]: number, [7]: number }
---@alias CatnipCanvasPathCommand CatnipCanvasPathCloseCommand | CatnipCanvasPathMoveCommand | CatnipCanvasPathLineCommand | CatnipCanvasPathArcCommand | CatnipCanvasPathBezierCommand

---@class (exact) CatnipCanvasPathFields
---@field fill_color number?
---@field fill_opacity number?
---@field stroke_color number?
---@field stroke_opacity number?
---@field stroke_size number?

---@alias CatnipCanvasPath CatnipCanvasPathFields | CatnipCanvasPathCommand[]

---@class CatnipCanvasRectangle
---@field x number?
---@field y number?
---@field width number?
---@field height number?
---@field radius number?
---@field radius_top_left number?
---@field radius_top_right number?
---@field radius_bottom_right number?
---@field radius_bottom_left number?
---@field fill_color number?
---@field fill_opacity number?
---@field stroke_color number?
---@field stroke_opacity number?
---@field stroke_size number?

---@class CatnipCanvasCircle
---@field x number?
---@field y number?
---@field radius number?
---@field fill_color number?
---@field fill_opacity number?
---@field stroke_color number?
---@field stroke_opacity number?
---@field stroke_size number?

---@class CatnipCanvasTextOptions
---@field x number?
---@field y number?
---@field width number?
---@field height number?
---@field align ('left' | 'center' | 'right')?
---@field valign ('left' | 'center' | 'right')?
---@field color number?
---@field ellipsis (boolean | 'start' | 'middle' | 'end')?
---@field font string?
---@field italic boolean?
---@field opacity number?
---@field size number?
---@field weight number?
---@field wrap (boolean | 'char' | 'word' | 'auto')?

---@class CatnipCanvasPngOptions
---@field x number?
---@field y number?
---@field width number?
---@field height number?

---@class CatnipCanvasSvgOptions
---@field x number?
---@field y number?
---@field width number?
---@field height number?

---@class (exact) CatnipCursor: CatnipResource
---@field x number
---@field y number
---@field name string
---@field size number
---@field theme string

---@class (exact) CatnipKeyboard: CatnipResource
---@field id number
---@field name string
---@field xkb_rules string?
---@field xkb_model string?
---@field xkb_layout string?
---@field xkb_variant string?
---@field xkb_options string?

---@class (exact) CatnipOutput: CatnipResource
---@field id number
---@field x number
---@field y number
---@field width number
---@field height number
---@field refresh number
---@field mode CatnipOutputMode
---@field modes CatnipResourceList<CatnipOutputMode>
---@field scale number

---@class (exact) CatnipOutputMode: CatnipResource
---@field width number
---@field height number
---@field refresh number

---@class (exact) CatnipWindow: CatnipResource
---@field id number
---@field x number
---@field y number
---@field z number
---@field width number
---@field height number
---@field visible boolean
---@field title string
---@field focused boolean
---@field destroy fun(self: CatnipWindow)

local catnip ---@type Catnip
return catnip
