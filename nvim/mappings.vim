
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

" Tabs
nnoremap <Tab> :tabnext<cr>
nnoremap <S-Tab> :tabprevious<cr>
