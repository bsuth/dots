lua require('init')

" ------------------------------------------------------------------------------
" FUNCTIONS
" ------------------------------------------------------------------------------

function! Docs()
	if (index(['vim','help'], &filetype) >= 0)
		execute 'h '.expand('<cword>')
	else
		execute '!' . &keywordprg . ' ' . expand('<cword>')
	endif
endfunction

function! DirvishXdgOpen()
	let file = expand('<cWORD>')
	let dir = fnamemodify(file, ':p:h')
	let ext = fnamemodify(file, ':e')

	if (ext == 'png')
		exec '!xdg-open ' . file
	else
		call dirvish#open('edit', 0)
		exec 'cd ' . dir
	endif
endfunction

function! BufEnterAutoCd()
	let bufname = bufname('')
	let bufdir = fnamemodify(bufname, ':p:h')
	let bufft = getbufvar(0, '&filetype')

	if (!empty(matchstr(bufname, '^term://')))
		return
	endif

	exec 'cd ' . fnamemodify(bufname, ':p:h')

	if (getbufvar('', '&filetype') == 'dirvish')
		Dirvish
	endif
endfunction

function! GetVisualSelection()
	let [line_start, column_start] = getpos("'<")[1:2]
	let [line_end, column_end] = getpos("'>")[1:2]

	let lines = getline(line_start, line_end)
	call setpos('.', [0, line_start, column_start, 0])

	if len(lines) == 0
		return ''
	endif

	let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
	let lines[0] = lines[0][column_start - 1:]

	return join(lines, "\n")
endfunction

function! SearchVisualSelection()
	let @/ = GetVisualSelection()
	norm n
endfunction

" ------------------------------------------------------------------------------
" AUGROUPS
" ------------------------------------------------------------------------------

augroup bsuth-general
	au BufEnter * call BufEnterAutoCd()
	au TermOpen term://*zsh* setlocal nonumber wrap
	au TermOpen term://*zsh* startinsert
	au TermClose term://*zsh* Dirvish
	" au FileType c setlocal shiftwidth=4 tabstop=4 softtabstop=4
	au FileType dirvish nnoremap <buffer><silent> <cr> :call DirvishXdgOpen()<cr>
augroup END

" ------------------------------------------------------------------------------
" COMMANDS
" ------------------------------------------------------------------------------

command! -nargs=* FzfCDSelect call fzf#run(fzf#wrap({
			\ 'source': "find -L -type d ! \\( \\(
			\ -name .cache -o 
			\ -name node_modules
			\ \\) -prune \\) -name '*'",
			\ 'sink': 'FzfCDCommit',
			\}))
command! -nargs=* FzfCDCommit exec 'cd ' . <f-args> . '|:Dirvish'

command! -nargs=* FavoriteCDSelect call fzf#run(fzf#wrap({
			\ 'source': "ls ~/edtechy",
			\ 'sink': 'FavoriteCDCommit',
			\}))
command! -nargs=* FavoriteCDCommit exec 'cd ~/edtechy/' . <f-args> . '|:Dirvish'

" ------------------------------------------------------------------------------
" MARKS (kind of)
" ------------------------------------------------------------------------------

nnoremap 'r :cd /\|:Dirvish<cr>
nnoremap 'h :cd ~\|:Dirvish<cr>
