syntax on
set number
set relativenumber
set hlsearch
set softtabstop=2
set shiftwidth=2
set autoindent
set expandtab
autocmd FileType python setlocal indentexpr=
autocmd FileType python setlocal equalprg=ruff\ format\ -
autocmd FileType nix setlocal equalprg=nixfmt
