" -------------------------------------------
" SETTINGS
" -------------------------------------------

set path=".,/usr/include,/home/bsuth/dots/core/nvim,,"

set number

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set ignorecase
set smartcase

set nowrap

set termguicolors

set colorcolumn=80
highlight ColorColumn guibg=#585858

set clipboard=unnamedplus


" -------------------------------------------
" INIT
" -------------------------------------------

source $DOTS/nvim/plugins.vim
source $DOTS/nvim/mappings.vim
source $DOTS/nvim/augroups.vim
