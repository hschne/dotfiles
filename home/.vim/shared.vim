set incsearch hlsearch
set ignorecase smartcase
set clipboard=unnamed
set scrolloff=5
set showmode

" More natural split behaviour 
set splitbelow
set splitright

" Use hybrid line numbers
" Well explained here: https://jeffkreeftmeijer.com/vim-number/
set number relativenumber

" Map space to leader
map <Space> <Leader>

" Clear search highlighting
nnoremap <Leader>c :noh<cr>

" Disable terminalsounds, see https://superuser.com/a/677312
set visualbell
set noerrorbells
