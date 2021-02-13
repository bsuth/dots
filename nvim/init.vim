" ------------------------------------------------------------------------------
" VIM-PLUG
" ------------------------------------------------------------------------------

if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/bundle')
Plug 'joshdick/onedark.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'sheerun/vim-polyglot'
Plug 'lambdalisue/suda.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'justinmk/vim-dirvish'
call plug#end()

" ------------------------------------------------------------------------------
" OPTIONS / VARIABLES
" ------------------------------------------------------------------------------

set ignorecase
set smartcase
set termguicolors
set splitright
set splitbelow
set clipboard=unnamedplus
set tabstop=4
set softtabstop=4
set shiftwidth=4
set number
set nowrap
set colorcolumn=80
set signcolumn=yes
set scrollback=100000
set updatetime=300

let g:mapleader = ' '
let g:fzf_layout =  { 'down': '50%' }
let g:fzf_preview_window = 'right:60%'
let g:suda_smart_edit = 1
let g:coc_disable_startup_warning = 1

colorscheme onedark
highlight ColorColumn guibg=#585858

" ------------------------------------------------------------------------------
" FUNCTIONS
" ------------------------------------------------------------------------------

function! CdDirvish(dir)
	:exec 'lcd ' . a:dir | :Dirvish
endfunction

function! Docs()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
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

function! OnTermClose()
	if (!empty(matchstr(bufname(''), 'bundle/fzf/bin/fzf')))
		return
	endif

	Dirvish
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
	au FileType html,scss,css,less,javascript,typescript,typescriptreact,json setlocal shiftwidth=2 tabstop=2 softtabstop=2
	au FileType dirvish nnoremap <buffer><silent> <cr> :call DirvishXdgOpen()<cr>
	au CursorHold * silent call CocActionAsync('highlight')
augroup END

" ------------------------------------------------------------------------------
" COMMANDS
" ------------------------------------------------------------------------------

command! -nargs=* CdDirvish call CdDirvish(<f-args>)
command! -nargs=* FzfCDSelect call fzf#run(fzf#wrap({
	\ 'source': "find -L -type d ! \\( \\(
		\ -name .cache -o 
		\ -name node_modules
	\ \\) -prune \\) -name '*'",
	\ 'sink': 'FzfCDCommit',
\}))
command! -nargs=* FzfCDCommit exec 'cd ' . <f-args> . '|:Dirvish'

" ------------------------------------------------------------------------------
" MARKS (kind of)
" ------------------------------------------------------------------------------

nnoremap 'r :cd /\|:Dirvish<cr>
nnoremap 'h :cd ~\|:Dirvish<cr>

" ------------------------------------------------------------------------------
" MAPPINGS
" ------------------------------------------------------------------------------

nnoremap <leader>ev :e $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
tnoremap <c-[> <c-\><c-n>,
nnoremap <c-space> :term<cr>
nnoremap <leader>/ :nohlsearch<cr><c-l>
nnoremap <leader>? :help 
nnoremap <leader>v? :vert :help 
nnoremap <c-_> :Commentary<cr>
vnoremap <c-_> :Commentary<cr>
vnoremap <c-n> :call SearchVisualSelection()<cr>

nnoremap <leader>w <c-w>
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <leader><c-l> :rightbelow :vsp\|:Dirvish<cr>
nnoremap <leader><c-k> :aboveleft :sp\|:Dirvish<cr>
nnoremap <leader><c-j> :rightbelow :sp\|:Dirvish<cr>
nnoremap <leader><c-h> :aboveleft :vsp\|:Dirvish<cr>

nnoremap <leader>fd :Files<cr>
nnoremap <leader>cd :FzfCDSelect<cr>
nnoremap <leader>rg :Rg<cr>
nnoremap <leader>ls :Buffers<cr>

nnoremap <leader><leader>fd :cd ~\|:Files<cr>
nnoremap <leader><leader>cd :cd ~\|:FzfCDSelect<cr>
nnoremap <leader><leader>rg :cd ~\|:Rg<cr>

inoremap <silent><expr> <c-space> coc#refresh()
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call Docs()<CR>
