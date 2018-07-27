" editor 
set number
set wrap
set showmode
set smartcase
set smarttab
set smartindent
set autoindent
set softtabstop=2
set shiftwidth=2
set expandtab
set incsearch
set mouse=a
set history=1000
set clipboard=unnamedplus,autoselect
set history=200
set textwidth=0 
set wrapmargin=0
set completeopt=menuone,menu,longest

set termguicolors

set wildignore+=*\\tmp\\*,*.swp,*.swo,*.zip,.git,.cabal-sandbox
set wildmode=longest,list,full
set wildmenu
set completeopt+=longest

set t_Co=256
set cmdheight=1

filetype indent on


" toggle hlsearch
set hlsearch!
nnoremap <F3> :noh<CR><CR>

" deactivate arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" syntastic
map <Leader>s :SyntasticToggleMode<CR>

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1

" supertab
autocmd FileType *
  \ if &omnifunc != '' |
  \   call SuperTabChain(&omnifunc, "<c-p>") |
  \   call SuperTabSetDefaultCompletionType("<c-x><c-u>") |
  \ endif

if has("gui_running")
    imap <c-space> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
else " no gui
  if has("unix")
    inoremap <Nul> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
  endif
endif

" colors
silent! colorscheme nord

" vim-airline
let g:airline_theme='minimalist'
let g:airline_powerline_fonts = 1
let g:airline_right_sep = ''

" vim-markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_new_list_item_indent = 0

" vim-markdown-preview
let vim_markdown_preview_github=1
let vim_markdown_preview_use_xdg_open=1

" nerdtree
map <Leader>n :NERDTreeToggle<CR>

" yaml indent
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" easy align
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" ctrl+p
map <silent> <Leader>t :CtrlP()<CR>
noremap <leader>b<space> :CtrlPBuffer<cr>
let g:ctrlp_custom_ignore = '\v[\/]dist$'

" yaml format
let g:yaml_formatter_indent_collection=1
