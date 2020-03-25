
" -------------------------------------------
" GENERAL
" -------------------------------------------

let mapleader = ' '

" Open/Source vimrc
nnoremap <leader>ev :find $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" Clear highlighting and redraw
nnoremap <leader>/ :nohlsearch<cr><c-l>

" Window switching
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

" Nvim help
cnoreabbrev ? tab help

" Buffer/Tab Navigatino
nnoremap <Tab> :bn<cr>
nnoremap <S-Tab> :bp<cr>
nnoremap <leader>[ :tabprevious<cr>
nnoremap <leader>] :tabnext<cr>

nnoremap <c-n> :call CustomVifm()<cr>
nnoremap <c-m> :call LocateFunctions()<cr>


" -------------------------------------------
" DEVELOPMENT
" -------------------------------------------

function! CustomVifm()
    set nonumber
    :Vifm
    set number
endfunction

function! LocateFunctions()
    let cmd = "rg '^function! ([a-zA-Z]+)' " . expand('%:p') . " -r '$1'"
    lex system(cmd)
endfunction
