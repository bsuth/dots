--- @class CommandPalette
--- @field buffer number
--- @field window number
--- @field parent_window number
--- @field path CommandPaletteGenerator[]
--- @field commands CommandPaletteCommand[]
--- @field filtered_commands CommandPaletteCommand[]
--- @field num_filtered_commands number
--- @field focused_index number
--- @field ignore_next_buffer_changes number
--- @field ignore_next_mode_changes number

--- @class CommandPaletteCommand
--- @field label string
--- @field callback fun(): CommandPaletteGenerator | nil

--- @class CommandPaletteGenerator
--- @field callback fun(filter?: string): CommandPaletteCommand[]
--- @field lazy? boolean
