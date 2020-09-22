luafile $DOTS/nvim/init.lua

" Local plugins
set rtp+=$HOME/projects/nvim-platinum

" ------------------------------------------------------------------------------
" TERMINAL AUGROUP
" 1) Don't use numbers in terminal mode
" 2/3) Start the terminal in insert mode
" ------------------------------------------------------------------------------

augroup bsuth-terminal
    au TermOpen term://* setlocal nonumber
    au TermOpen term://* startinsert
    au BufEnter term://* startinsert
augroup END
