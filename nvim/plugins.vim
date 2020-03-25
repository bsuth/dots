
" -------------------------------------------
" AUTOINSTALL VIM-PLUG
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

    " IDE
    Plug 'neoclide/coc.nvim', { 'branch': 'release' }
    Plug 'vifm/vifm.vim'
    Plug 'vim-airline/vim-airline'

    " Languages
    Plug 'pangloss/vim-javascript'
    Plug 'peitalin/vim-jsx-typescript'

   " Util
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --no-key-bindings --no-zsh --no-fish' }
call plug#end()


" -------------------------------------------
" ONEDARK
" -------------------------------------------

colorscheme onedark

" For some reason, vim register what should be <c-/> as <c-_>
nnoremap <c-_> :Commentary<cr>


" -------------------------------------------
" AIRLINE
" -------------------------------------------

" Enable tabline
let g:airline#extensions#tabline#enabled = 1

" Remove tabline separators
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = ' '

" Enable syntax highlight group caching. To clear the cache,
" use :AirlineRefresh
let g:airline_highlighting_cache = 1


" -------------------------------------------
" TAGBR
" -------------------------------------------

let g:tagbar_left = 1


" -------------------------------------------
" COC.NVIM
" -------------------------------------------

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Remap keys for gotos
nmap <silent> <c-]> <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  " autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
