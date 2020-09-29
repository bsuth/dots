luafile $DOTS/nvim/init.lua

" Autogroups are a huge PITA in lua, so just do them here. Still need to have
" this file anyways

augroup dirvish-au
    autocmd!
    autocmd FileType dirvish silent! :cd %
    " Hide dot files
    autocmd FileType dirvish silent keeppatterns g@\v/\.[^\/]+/?$@d _
augroup END
