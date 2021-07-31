local modes = require('modes')
local webview = require('webview')

-- -----------------------------------------------------------------------------
-- Settings
-- -----------------------------------------------------------------------------

webview.hardware_acceleration_policy = 'never'

-- -----------------------------------------------------------------------------
-- Normal Mode
-- -----------------------------------------------------------------------------

modes.add_binds('normal', {

  --
  -- Movement
  --

  { '<Tab>', function(w)
    w:next_tab()
  end },
  { '<Shift-Tab>', function(w)
    w:prev_tab()
  end },
  {
    'd',
    function(w)
      w:scroll({ ypagerel = 0.5 })
    end,
  },
  {
    'u',
    function(w)
      w:scroll({ ypagerel = -0.5 })
    end,
  },

  --
  -- Clipboard
  --

  {
    '<Control-c>',
    function()
      luakit.selection.clipboard = luakit.selection.primary
    end,
  },
  {
    'y',
    function(w)
      local uri = string.gsub(w.view.uri or '', ' ', '%%20')
      luakit.selection.clipboard = uri
      w:notify('Yanked uri: ' .. uri)
    end,
  },

  --
  -- Misc
  --

  {
    'f',
    function(w)
      w:set_mode('follow', {
        prompt = 'open',
        selector = 'uri',
        evaluator = 'uri',
        func = function(uri)
          assert(type(uri) == 'string')
          w:navigate(uri)
        end,
      })
    end,
  },
})

-- -----------------------------------------------------------------------------
-- Command Mode
-- -----------------------------------------------------------------------------

modes.add_binds('command', {
  { '<Control-c>', function(w)
    w:set_mode()
  end },
})

-- -----------------------------------------------------------------------------
-- Search Mode
-- -----------------------------------------------------------------------------

modes.add_binds('search', {
  {
    '<Control-c>',
    function(w)
      w:set_mode()
    end,
  },
})
