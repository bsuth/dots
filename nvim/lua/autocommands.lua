nvim_command('augroup bsuth')
	nvim_command('au BufEnter * lua on_bufenter()')
	nvim_command('au TermOpen term://*zsh* setlocal nonumber wrap')
	nvim_command('au TermOpen term://*zsh* startinsert')
	nvim_command('au TermClose term://*zsh* Dirvish')
	nvim_command('au FileType dirvish nnoremap <buffer><silent> <cr> :lua dirvish_open()<cr>')
nvim_command('augroup END')
