

" -------------------------------------------
" AUGROUPS
" -------------------------------------------

" augroup c_au
"     autocmd BufEnter *.c :let &makeprg = 'gcc *.c'
" augroup END
"
augroup typescript
    autocmd FileType typescript :set makeprg=tsc
    autocmd QuickFixCmdPost [^l]* nested cwindow
    autocmd QuickFixCmdPost    l* nested lwindow
augroup END
