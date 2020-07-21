" ------------------------------------------------------------------------------
" HELPERS
" ------------------------------------------------------------------------------

function! MyNERDTreeToggle()
    NERDTreeToggle

    " Prevent NERDTree from squashing first window
    execute "normal! \<c-w>="
endfunction

" ------------------------------------------------------------------------------
" MOVEMENT
" ------------------------------------------------------------------------------

" Pane switching
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <leader>w <c-w>

" Buffer actions
nnoremap <c-w> :bd<cr>
nnoremap <c-t> :Vifm<cr>
nnoremap <C-n> :call MyNERDTreeToggle()<CR>

" Pane splitting
nnoremap <leader>term :sp\|:term<cr>
nnoremap <leader>vterm :vsp\|:term<cr>
nnoremap <leader>sp :sp\|:Vifm<cr>
nnoremap <leader>vsp :vsp\|:Vifm<cr>

" ------------------------------------------------------------------------------
" BUFFERS
" ------------------------------------------------------------------------------

nnoremap <Tab> :bn<cr>
nnoremap <S-Tab> :bp<cr>
nnoremap <leader>b :b <Tab>

