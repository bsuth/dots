
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
    Plug 'vim-syntastic/syntastic'

    " Languages
    Plug 'rust-lang/rust.vim'

    " IDE
    Plug 'vifm/vifm.vim'
    Plug 'airblade/vim-gitgutter'
    Plug 'majutsushi/tagbar'

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
