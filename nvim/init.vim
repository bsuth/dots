luafile $DOTS/nvim/init.lua

" Local plugins
set rtp+=$HOME/projects/nvim-platinum

" ------------------------------------------------------------------------------
" SETTINGS
" ------------------------------------------------------------------------------

" ---------------
" Core
" ---------------

let mapleader = ' '

" ---------------
" Airline
" ---------------

" " Enable tabline
" let g:airline#extensions#tabline#enabled = 1

" " Remove tabline separators
" let g:airline#extensions#tabline#left_sep = ' '
" let g:airline#extensions#tabline#left_alt_sep = ' '

" " Enable syntax highlight group caching. To clear the cache,
" " use :AirlineRefresh
" let g:airline_highlighting_cache = 1

" ---------------
" Coc
" ---------------

" Add status line support, for integration with other plugin, checkout `:h coc-status`
" set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" ------------------------------------------------------------------------------
" GENERAL MAPPINGS
" ------------------------------------------------------------------------------

" Open/Source vimrc
nnoremap <leader>ev :Vifm /home/bsuth/dots/nvim<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" Clear highlighting and redraw
nnoremap <leader>/ :nohlsearch<cr><c-l>

" Nvim help
nnoremap <leader>he :help 
nnoremap <leader>vhe :vert :help 

" For some reason, vim registers <c-/> as <c-_>
nnoremap <c-_> :Commentary<cr>

" Terminal mode back to normal mode
tnoremap <c-[> <c-\><c-n>

" ------------------------------------------------------------------------------
" MODULES
" ------------------------------------------------------------------------------

let MYVIMDIR = fnamemodify(expand($MYVIMRC), ':p:h') .. '/'
execute 'source ' .. MYVIMDIR .. 'movement.vim'

" -------------------------------------------
" COC MAPPINGS
" -------------------------------------------

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Remap keys for gotos
nmap <silent> <c-]> <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" ------------------------------------------------------------------------------
" TERMINAL AUGROUP
" 1) Don't use numbers in terminal mode
" 2) Start the terminal in insert mode
" ------------------------------------------------------------------------------

augroup bsuth-terminal
    au TermOpen term://* setlocal nonumber
    au TermOpen term://* startinsert
augroup END

" ------------------------------------------------------------------------------
" VIMWIKI AUGROUP
" 1) Override Vimwiki's <Tab> binding to match local mapping
" 2) Override Vimwiki's <S-Tab> binding to match local mapping
" 3) Use <c-p> to jump to previous link
" 4) Use <c-n> to jump to next link
" ------------------------------------------------------------------------------

augroup bsuth-vimwiki
    autocmd FileType vimwiki nnoremap <buffer> <S-Tab> :bp<cr>
    autocmd FileType vimwiki nnoremap <buffer> <Tab> :bn<cr>
    autocmd FileType vimwiki nnoremap <buffer> <c-p> :VimwikiPrevLink<cr>
    autocmd FileType vimwiki nnoremap <buffer> <c-n> :VimwikiNextLink<cr>
augroup END

" Use nvim to open files with the 'vfile:' scheme.
function! VimwikiLinkHandler(link)
    let link = a:link

    if link =~# '^vfile:'
        let link = link[1:]
    else
        return 0
    endif

    let link_infos = vimwiki#base#resolve_link(link)

    if link_infos.filename == ''
        echomsg 'Vimwiki Error: Unable to resolve link!'
        return 0
    else
        exe 'tabnew ' . fnameescape(link_infos.filename)
        return 1
    endif
endfunction
