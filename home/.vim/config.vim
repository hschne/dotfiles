" Options
"
" A number of options I like to use. See ':help options' for more information.
" Allso note that a number of options might be set by plugins (e.g.
" vim-sensible). 
set number
set wrap
set showmode
set smartcase
set smartindent
set softtabstop=2
set shiftwidth=2
set expandtab
set mouse=a
set history=1000
set clipboard=unnamedplus,autoselect
set textwidth=0 
set wrapmargin=0
set completeopt=menuone,menu,longest
set termguicolors
set wildignore+=*\\tmp\\*,*.swp,*.swo,*.zip,.git,.cabal-sandbox
set wildmode=longest,list,full
set completeopt+=longest
set cmdheight=1

filetype indent on

" Toggle Search Highlighting
"
" See https://stackoverflow.com/a/657457/2553104 for more info. 
set hlsearch!
nnoremap <Leader>c :noh<CR><CR>


" Nifty trick to write to write protected files
"
" See https://dev.to/jovica/the-vim-trick-which-will-save-your-time-and-nerves-45pg
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!



" Deactivate Arrow Keys
"
" Disable arrow keys. Helps getting gud in vim. 
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" Line wrapping options
"
" All tips inspired by
" https://agilesysadmin.net/how-to-manage-long-lines-in-vim/
set showbreak=…
set linebreak

" Syntastic
"
" Syntastic default settings. See ':help Syntastic' for more info. 
map <Leader>s :SyntasticToggleMode<CR>

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Colorscheme
"
" Nord. Its beautiful. Note that 'silent! is required in order to allow an
" automated installation process of vim and its plugins. 
silent! colorscheme nord

" vim-airline
"
" Settings for vim-airline. Use minimalist theme. 
let g:airline_theme='minimalist'
let g:airline_powerline_fonts = 1
let g:airline_right_sep = ''

" vim-markdown
"
" Settings for vim-markdown. Disable folding and fix list item behaviour. 
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_new_list_item_indent = 0

" vim-markdown-preview
"
" Use github style preview. XDG open required to open non-chrome browsers on
" Arch linux. 
let vim_markdown_preview_github=1
let vim_markdown_preview_use_xdg_open=1
