local C = {}

C.DOTS = os.getenv('DOTS')

C.TERM_PATTERNS = { 'term://*zsh*', 'term://*bash*' }
C.JS_PATTERNS = { '*.js', '*.jsx', '*.ts', '*.tsx' }
C.CSS_PATTERNS = { '*.css', '*.scss', '*.less' }
C.JSON_PATTERNS = { '*.json', '*.cjson' }

C.FD_FAVORITES_PATH = C.DOTS .. '/nvim/telescope_favorites_home'

return C
