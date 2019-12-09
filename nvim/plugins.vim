
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
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'Shougo/neosnippet.vim'
    Plug 'Shougo/neosnippet-snippets'
    " Sources
    Plug 'Shougo/deoplete-clangx'

   " Util
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'airblade/vim-gitgutter'
    Plug 'vifm/vifm.vim'
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --no-key-bindings --no-zsh --no-fish' }

    " Local dev
    Plug '$HOME/projects/vim-mysql'
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
" DEOPLETE
" -------------------------------------------

" Global
let g:deoplete#enable_at_startup = 1
set completeopt=noinsert,menuone,noselect

" Snippets
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)


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
