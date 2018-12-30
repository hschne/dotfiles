" Common settings shared between various vim like editors

" Options
"
" For more info type :help <keyword>
set clipboard=unnamedplus,autoselect
set history=1000
set ignorecase smartcase
set incsearch hlsearch
set scrolloff=5
set showmode
set smartcase

" More natural split behaviour
"
" See here: https://robots.thoughtbot.com/vim-splits-move-faster-and-more-naturally
set splitbelow
set splitright

" Enable hybrid numbers.
"
" All the tricks stolen from here: 
" https://jeffkreeftmeijer.com/vim-number/
set number relativenumber

" Map space to leader
map <Space> <leader>

" Toggle Search Highlighting
"
" See https://stackoverflow.com/a/657457/2553104 for more info. 
set hlsearch!
nnoremap <leader>c :noh<CR><CR>

