lua package.loaded.init = nil
lua require('init')

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
			\ 'source': "ls ~/edtechy ~/projects",
			\ 'sink': 'FavoriteCDCommit',
			\}))
command! -nargs=* FavoriteCDCommit exec 'cd ~/edtechy/' . <f-args> . '|:Dirvish'

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
	\ "rg --no-column --no-line-number --no-heading --color=always --smart-case "
	\ .shellescape(<q-args>), 1, {'options': '--delimiter : --nth 2..'}, <bang>0)

" ------------------------------------------------------------------------------
" MARKS (kind of)
" ------------------------------------------------------------------------------

nnoremap 'r :cd /\|:Dirvish<cr>
nnoremap 'h :cd ~\|:Dirvish<cr>
