

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

augroup bsuth-vimwiki
    autocmd FileType vimwiki nnoremap <buffer> <Tab> :bn<cr>
    autocmd FileType vimwiki nnoremap <buffer> <S-Tab> :bp<cr>
    autocmd FileType vimwiki nnoremap <buffer> <c-n> :VimwikiNextLink<cr>
    autocmd FileType vimwiki nnoremap <buffer> <S-Tab> :VimwikiPrevLink<cr>
augroup END
