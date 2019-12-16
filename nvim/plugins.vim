
" -------------------------------------------
" AUTO-INSTALL
" -------------------------------------------

let plug_install_path = '~/.config/nvim/autoload/plug.vim'
let plug_curl_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

if empty(glob(plug_install_path))
    exec 'silent !curl -fLo ' . plug_install_path . ' --create-dirs ' . plug_curl_url
endif


" -------------------------------------------
" PLUGINS
" -------------------------------------------

call plug#begin('~/.config/nvim/bundle')
    " Colorscheme
    Plug 'joshdick/onedark.vim'

    " Completion
    Plug 'ycm-core/YouCompleteMe', { 'do': 'python3 install.py --clang-completer --rust-completer' }
    Plug 'vim-syntastic/syntastic'

    " Languages
    Plug 'rust-lang/rust.vim'

    " IDE
    Plug 'majutsushi/tagbar'
    Plug 'vifm/vifm.vim'
    Plug 'airblade/vim-gitgutter'

   " Util
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --no-key-bindings --no-zsh --no-fish' }
call plug#end()


" -------------------------------------------
" ONEDARK
" -------------------------------------------

colorscheme onedark


" -------------------------------------------
" VIFM
" -------------------------------------------

nnoremap <c-n> :Vifm<cr>


" -------------------------------------------
" MySQL
" -------------------------------------------

"  Login
let g:vsql_db = 'employees'
let g:vsql_username = 'test'
let g:vsql_password = 'test'
let g:vsql_host = 'localhost'
let g:vsql_port = '80'

" Settings
let g:vsql_limit = 500

" Internal
let g:vsql_offset = 0

" Autocmds
augroup vsql_au
    autocmd BufEnter *.vsql :set filetype=vsql
augroup END


" -------------------------------------------
" SYNTASTIC
" -------------------------------------------

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0


" -------------------------------------------
" RUST
" -------------------------------------------

let g:rustfmt_autosave = 1
