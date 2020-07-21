
palette = {
    'black': '#181818',
    'red': '#e06c75',
    'green': '#98c379',
    'yellow': '#d19a66',
    'blue': '#61afef',
    'magenta': '#c678dd',
    'cyan': '#56b6c2',
    'white': '#d0d0d0',
    'dark_grey': '#282c34',
    'light_grey': '#abb2bf',
}

def apply(c):
    completion(c)
    contextmenu(c)
    downloads(c)
    fonts(c)
    hints(c)
    keyhints(c)
    messages(c)
    prompt(c)
    statusbar(c)
    tabs(c)
    web(c)

# ------------------------------------------------------------------------------
# COMPLETION
# ------------------------------------------------------------------------------

def completion(c):
    # Padding (in pixels) of the scrollbar handle in the completion window.
    c.completion.scrollbar.padding = 2

    # Width (in pixels) of the scrollbar in the completion window.
    c.completion.scrollbar.width = 12

    # Category Colors 
    c.colors.completion.category.bg = palette['black']
    c.colors.completion.category.fg = palette['white']
    c.colors.completion.category.border.bottom = palette['white']
    c.colors.completion.category.border.top = palette['black']

    # Normal Colors 
    c.colors.completion.even.bg = palette['black']
    c.colors.completion.odd.bg = palette['black']
    c.colors.completion.fg = palette['white']
    c.colors.completion.match.fg = palette['green']

    # Selected Colors 
    c.colors.completion.item.selected.bg = palette['green']
    c.colors.completion.item.selected.fg = palette['black']
    c.colors.completion.item.selected.border.bottom = palette['black']
    c.colors.completion.item.selected.border.top = palette['black']
    c.colors.completion.item.selected.match.fg = palette['white']

    # Scrollbar Colors 
    c.colors.completion.scrollbar.bg = palette['black']
    c.colors.completion.scrollbar.fg = palette['white']

# ------------------------------------------------------------------------------
# CONTEXTMENU
# ------------------------------------------------------------------------------

def contextmenu(c):
    ## Font used for the context menu. If set to null, the Qt default is
    ## used.
    ## Type: Font
    c.fonts.contextmenu = None

    ## Background color of disabled items in the context menu. If set to
    ## null, the Qt default is used.
    ## Type: QssColor
    c.colors.contextmenu.disabled.bg = None

    ## Foreground color of disabled items in the context menu. If set to
    ## null, the Qt default is used.
    ## Type: QssColor
    c.colors.contextmenu.disabled.fg = None

    ## Background color of the context menu. If set to null, the Qt default
    ## is used.
    ## Type: QssColor
    c.colors.contextmenu.menu.bg = None

    ## Foreground color of the context menu. If set to null, the Qt default
    ## is used.
    ## Type: QssColor
    c.colors.contextmenu.menu.fg = None

    ## Background color of the context menu's selected item. If set to null,
    ## the Qt default is used.
    ## Type: QssColor
    c.colors.contextmenu.selected.bg = None

    ## Foreground color of the context menu's selected item. If set to null,
    ## the Qt default is used.
    ## Type: QssColor
    c.colors.contextmenu.selected.fg = None

# ------------------------------------------------------------------------------
# DOWNLOADS
# ------------------------------------------------------------------------------

def downloads(c):
    # Colors
    c.colors.downloads.bar.bg = palette['black']
    c.colors.downloads.start.bg = palette['yellow']
    c.colors.downloads.start.fg = palette['black']
    c.colors.downloads.stop.bg = palette['green']
    c.colors.downloads.stop.fg = palette['black']
    c.colors.downloads.error.bg = palette['red']
    c.colors.downloads.error.fg = palette['black']

# ------------------------------------------------------------------------------
# FONTS
# ------------------------------------------------------------------------------

def fonts(c):
    ## Default font families to use. Whenever "default_family" is used in a
    ## font setting, it's replaced with the fonts listed here. If set to an
    ## empty value, a system-specific monospace default is used.
    ## Type: List of Font, or Font
    c.fonts.default_family = ['Semibold Quicksand']

# ------------------------------------------------------------------------------
# HINTS
# ------------------------------------------------------------------------------

def hints(c):
    # CSS border value for hints.
    c.hints.border = '2px solid ' + palette['black']

    # Rounding radius (in pixels) for the edges of hints.
    c.hints.radius = 0

    # Colors
    c.colors.hints.bg = palette['white']
    c.colors.hints.fg = palette['black']
    c.colors.hints.match.fg = palette['green']

# ------------------------------------------------------------------------------
# KEYHINTS
# ------------------------------------------------------------------------------

def keyhints(c):
    # Colors
    c.colors.keyhint.bg = 'rgba(0, 0, 0, 80%)'
    c.colors.keyhint.fg = '#FFFFFF'
    c.colors.keyhint.suffix.fg = '#FFFF00'

# ------------------------------------------------------------------------------
# MESSAGES
# ------------------------------------------------------------------------------

def messages(c):
    # Error Colors
    c.colors.messages.error.bg = palette['red']
    c.colors.messages.error.border = palette['red']
    c.colors.messages.error.fg = palette['black']

    # Info Colors
    c.colors.messages.info.bg = palette['green']
    c.colors.messages.info.border = palette['green']
    c.colors.messages.info.fg = palette['black']

    # Warning Colors
    c.colors.messages.warning.bg = palette['yellow']
    c.colors.messages.warning.border = palette['yellow']
    c.colors.messages.warning.fg = palette['black']

# ------------------------------------------------------------------------------
# PROMPT
# ------------------------------------------------------------------------------

def prompt(c):
    # Rounding radius (in pixels) for the edges of prompts.
    c.prompt.radius = 0

    # Colors
    c.colors.prompts.bg = palette['black']
    c.colors.prompts.border = 'none'
    c.colors.prompts.fg = palette['white']
    c.colors.prompts.selected.bg = palette['green']

# ------------------------------------------------------------------------------
# STATUSBAR
# ------------------------------------------------------------------------------

def statusbar(c):
    # Padding (in pixels) for the statusbar.
    c.statusbar.padding = {'top': 5, 'bottom': 5, 'left': 5, 'right': 5}

    # Background color of the progress bar.
    c.colors.statusbar.progress.bg = palette['white']

    # Caret Mode Colors
    c.colors.statusbar.caret.bg = palette['magenta']
    c.colors.statusbar.caret.fg = palette['black']
    c.colors.statusbar.caret.selection.bg = palette['magenta']
    c.colors.statusbar.caret.selection.fg = palette['black']

    # Command Mode Colors
    c.colors.statusbar.command.bg = palette['black']
    c.colors.statusbar.command.fg = palette['white']

    # Insert Mode Colors
    c.colors.statusbar.insert.bg = palette['green']
    c.colors.statusbar.insert.fg = palette['black']

    # Normal Mode Colors
    c.colors.statusbar.normal.bg = palette['black']
    c.colors.statusbar.normal.fg = palette['white']

    # Passthrough Mode Colors
    c.colors.statusbar.passthrough.bg = palette['blue']
    c.colors.statusbar.passthrough.fg = palette['black']
    
    # Private Window Colors
    c.colors.statusbar.private.bg = palette['white']
    c.colors.statusbar.private.fg = palette['black']
    c.colors.statusbar.command.private.bg = palette['white']
    c.colors.statusbar.command.private.fg = palette['black']

    # Url Colors
    c.colors.statusbar.url.fg = palette['yellow']
    c.colors.statusbar.url.hover.fg = palette['blue']
    c.colors.statusbar.url.warn.fg = palette['red']
    c.colors.statusbar.url.error.fg = palette['red']
    c.colors.statusbar.url.success.http.fg = palette['green']
    c.colors.statusbar.url.success.https.fg = palette['green']

# ------------------------------------------------------------------------------
# TABS
# ------------------------------------------------------------------------------

def tabs(c):
    # Width (in pixels) of the progress indicator (0 to disable).
    c.tabs.indicator.width = 0

    # Padding (in pixels) around text for tabs.
    c.tabs.padding = {'top': 5, 'bottom': 5, 'left': 5, 'right': 5}

    # Format to use for the tab title. The following placeholders are
    # defined:  * `{perc}`: Percentage as a string like `[10%]`. *
    # `{perc_raw}`: Raw percentage, e.g. `10`. * `{current_title}`: Title of
    # the current web page. * `{title_sep}`: The string ` - ` if a title is
    # set, empty otherwise. * `{index}`: Index of this tab. * `{id}`:
    # Internal tab ID of this tab. * `{scroll_pos}`: Page scroll position. *
    # `{host}`: Host of the current web page. * `{backend}`: Either
    # ''webkit'' or ''webengine'' * `{private}`: Indicates when private mode
    # is enabled. * `{current_url}`: URL of the current web page. *
    # `{protocol}`: Protocol (http/https/...) of the current web page. *
    # `{audio}`: Indicator for audio/mute status.
    # Type: FormatString
    c.tabs.title.format = '{audio} {current_title}'

    # Colors
    c.colors.tabs.bar.bg = palette['black']
    c.colors.tabs.even.bg = palette['dark_grey']
    c.colors.tabs.odd.bg = palette['dark_grey']
    c.colors.tabs.selected.even.bg = palette['black']
    c.colors.tabs.selected.odd.bg = palette['black']

# ------------------------------------------------------------------------------
# WEB
# ------------------------------------------------------------------------------

def web(c):
    ## Background color for webpages if unset.
    c.colors.webpage.bg = palette['white']

    ## Force `prefers-color-scheme: dark` colors for websites.
    c.colors.webpage.prefers_color_scheme_dark = True
