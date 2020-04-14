

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
    autocmd FileType vimwiki nnoremap <buffer> <c-p> :VimwikiPrevLink<cr>


    function! VimwikiLinkHandler(link)
        " Use nvim to open files with the 'vfile:' scheme.
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
augroup END
