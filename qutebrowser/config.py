import theme

# ------------------------------------------------------------------------------
# THEME
# ------------------------------------------------------------------------------

theme.apply(c)

# ------------------------------------------------------------------------------
# GENERAL
# ------------------------------------------------------------------------------

## Aliases for commands. The keys of the given dictionary are the
## aliases, while the values are the commands they map to.
## Type: Dict
c.aliases = {
    'w': 'session-save',
    'q': 'close',
    'qa': 'quit',
    'x': 'quit --save',
}

## This setting can be used to map keys to other keys. When the key used
## as dictionary-key is pressed, the binding for the key used as
## dictionary-value is invoked instead. This is useful for global
## remappings of keys, for example to map Ctrl-[ to Escape. Note that
## when a key is bound (via `bindings.default` or `bindings.commands`),
## the mapping is ignored.
## Type: Dict
# c.bindings.key_mappings = {'<Ctrl-[>': '<Escape>', '<Ctrl-6>': '<Ctrl-^>', '<Ctrl-M>': '<Return>', '<Ctrl-J>': '<Return>', '<Ctrl-I>': '<Tab>', '<Shift-Return>': '<Return>', '<Enter>': '<Return>', '<Shift-Enter>': '<Return>', '<Ctrl-Enter>': '<Ctrl-Return>'}

## Which categories to show (in which order) in the :open completion.
## Type: FlagList
## Valid values:
##   - searchengines
##   - quickmarks
##   - bookmarks
##   - history
# c.completion.open_categories = ['searchengines', 'quickmarks', 'bookmarks', 'history']

## A list of patterns which should not be shown in the history. This only
## affects the completion. Matching URLs are still saved in the history
## (and visible on the qute://history page), but hidden in the
## completion. Changing this setting will cause the completion history to
## be regenerated on the next start, which will take a short while.
## Type: List of UrlPattern
# c.completion.web_history.exclude = []

## Require a confirmation before quitting the application.
## Type: ConfirmQuit
## Valid values:
##   - always: Always show a confirmation.
##   - multiple-tabs: Show a confirmation if multiple tabs are opened.
##   - downloads: Show a confirmation if downloads are running
##   - never: Never show a confirmation.
c.confirm_quit = ['downloads']

## Default encoding to use for websites. The encoding must be a string
## describing an encoding such as _utf-8_, _iso-8859-1_, etc.
## Type: String
c.content.default_encoding = 'utf-8'

## List of URLs of lists which contain hosts to block.  The file can be
## in one of the following formats:  - An `/etc/hosts`-like file - One
## host per line - A zip-file of any of the above, with either only one
## file, or a file   named `hosts` (with any extension).  It's also
## possible to add a local file or directory via a `file://` URL. In case
## of a directory, all files in the directory are read as adblock lists.
## The file `~/.config/qutebrowser/blocked-hosts` is always read if it
## exists.
## Type: List of Url
c.content.host_blocking.lists = [
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts'
]

## A list of patterns that should always be loaded, despite being ad-
## blocked. Note this whitelists blocked hosts, not first-party URLs. As
## an example, if `example.org` loads an ad from `ads.example.org`, the
## whitelisted host should be `ads.example.org`. If you want to disable
## the adblocker on a given page, use the `content.host_blocking.enabled`
## setting with a URL pattern instead. Local domains are always exempt
## from hostblocking.
## Type: List of UrlPattern
# c.content.host_blocking.whitelist = []

## List of user stylesheet filenames to use.
## Type: List of File, or File
# c.content.user_stylesheets = []

## Directory to save downloads to. If unset, a sensible OS-specific
## default is used.
## Type: Directory
c.downloads.location.directory = '~/Downloads'

## Prompt the user for the download location. If set to false,
## `downloads.location.directory` will be used.
## Type: Bool
c.downloads.location.prompt = False

## Where to show the downloaded files.
## Type: VerticalPosition
## Valid values:
##   - top
##   - bottom
c.downloads.position = 'bottom'

## Editor (and arguments) to use for the `open-editor` command. The
## following placeholders are defined:  * `{file}`: Filename of the file
## to be edited. * `{line}`: Line in which the caret is found in the
## text. * `{column}`: Column in which the caret is found in the text. *
## `{line0}`: Same as `{line}`, but starting from index 0. * `{column0}`:
## Same as `{column}`, but starting from index 0.
## Type: ShellCommand
c.editor.command = ['alacritty', '-e', 'nvim', '{}']

## Characters used for hint strings.
## Type: UniqueCharString
c.hints.chars = 'sdfjkl'

## Timeout (in milliseconds) for partially typed key bindings. If the
## current input forms only partial matches, the keystring will be
## cleared after this time.
## Type: Int
c.input.partial_timeout = 0

## How to open links in an existing instance if a new one is launched.
## This happens when e.g. opening a link from a terminal. See
## `new_instance_open_target_window` to customize in which window the
## link is opened in.
## Type: String
## Valid values:
##   - tab: Open a new tab in the existing window and activate the window.
##   - tab-bg: Open a new background tab in the existing window and activate the window.
##   - tab-silent: Open a new tab in the existing window without activating the window.
##   - tab-bg-silent: Open a new background tab in the existing window without activating the window.
##   - window: Open in a new window.
c.new_instance_open_target = 'window'

## Name of the session to save by default. If this is set to null, the
## session which was last loaded is saved.
## Type: SessionName
# c.session.default_name = None

## List of widgets displayed in the statusbar.
## Type: List of String
## Valid values:
##   - url: Current page URL.
##   - scroll: Percentage of the current page position like `10%`.
##   - scroll_raw: Raw percentage of the current page position like `10`.
##   - history: Display an arrow when possible to go back/forward in history.
##   - tabs: Current active tab, e.g. `2`.
##   - keypress: Display pressed keys when composing a vi command.
##   - progress: Progress bar for the current page loading.
c.statusbar.widgets = ['keypress', 'progress', 'url', 'scroll', 'history']

# ------------------------------------------------------------------------------
# TABS
# ------------------------------------------------------------------------------

## Open new tabs (middleclick/ctrl+click) in the background.
## Type: Bool
c.tabs.background = True

## How to behave when the last tab is closed.
## Type: String
## Valid values:
##   - ignore: Don't do anything.
##   - blank: Load a blank page.
##   - startpage: Load the start page.
##   - default-page: Load the default page.
##   - close: Close the window.
c.tabs.last_close = 'startpage'

## Force pinned tabs to stay at fixed URL.
## Type: Bool
# c.tabs.pinned.frozen = True

## Shrink pinned tabs down to their contents.
## Type: Bool
# c.tabs.pinned.shrink = True

# ------------------------------------------------------------------------------
# URL
# ------------------------------------------------------------------------------

## Page to open if :open -t/-b/-w is used without URL. Use `about:blank`
## for a blank page.
## Type: FuzzyUrl
c.url.default_page = '~/dots/qutebrowser/home/index.html'

## Open base URL of the searchengine if a searchengine shortcut is
## invoked without parameters.
## Type: Bool
# c.url.open_base_url = False

## Search engines which can be used via the address bar.  Maps a search
## engine name (such as `DEFAULT`, or `ddg`) to a URL with a `{}`
## placeholder. The placeholder will be replaced by the search term, use
## `{{` and `}}` for literal `{`/`}` braces.  The following further
## placeholds are defined to configure how special characters in the
## search terms are replaced by safe characters (called 'quoting'):  *
## `{}` and `{semiquoted}` quote everything except slashes; this is the
## most   sensible choice for almost all search engines (for the search
## term   `slash/and&amp` this placeholder expands to `slash/and%26amp`).
## * `{quoted}` quotes all characters (for `slash/and&amp` this
## placeholder   expands to `slash%2Fand%26amp`). * `{unquoted}` quotes
## nothing (for `slash/and&amp` this placeholder   expands to
## `slash/and&amp`).  The search engine named `DEFAULT` is used when
## `url.auto_search` is turned on and something else than a URL was
## entered to be opened. Other search engines can be used by prepending
## the search engine name to the search term, e.g. `:open google
## qutebrowser`.
## Type: Dict
c.url.searchengines = {'DEFAULT': 'https://google.com/search?q={}'}

## Page(s) to open at the start.
## Type: List of FuzzyUrl, or FuzzyUrl
c.url.start_pages = [ '~/dots/qutebrowser/home/index.html']

## URL parameters to strip with `:yank url`.
## Type: List of String
# c.url.yank_ignored_parameters = ['ref', 'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content']

# ------------------------------------------------------------------------------
# NORMAL MODE
# ------------------------------------------------------------------------------

config.bind('sv', 'config-source')
config.bind('ev', 'config-edit')
config.bind('ps', 'view-source')

config.bind('u', 'scroll-page 0 -0.5')
config.bind('d', 'scroll-page 0 0.5')
config.bind('L', 'tab-next')
config.bind('H', 'tab-prev')
config.bind('<Ctrl-o>', 'back')
config.bind('<Ctrl-i>', 'forward')

config.bind('<Ctrl-R>', 'undo')
config.bind('<Ctrl-S>', 'tab-give')
config.bind('<', 'tab-move -')
config.bind('>', 'tab-move +')

config.bind('gh', 'home')

# ------------------------------------------------------------------------------
# COMMAND MODE
# ------------------------------------------------------------------------------

config.bind('<Ctrl-N>', 'completion-item-focus --history next', mode='command')
config.bind('<Ctrl-P>', 'completion-item-focus --history prev', mode='command')
config.bind('<Ctrl-Shift-N>', 'command-history-next', mode='command')
config.bind('<Ctrl-Shift-P>', 'command-history-prev', mode='command')

# ------------------------------------------------------------------------------
# PROMPT MODE
# ------------------------------------------------------------------------------

config.bind('<Ctrl-P>', 'prompt-item-focus next', mode='prompt')
config.bind('<Ctrl-N>', 'prompt-item-focus prev', mode='prompt')
config.bind('<Ctrl-Shift-P>', 'prompt-open-download --pdfjs', mode='prompt')
