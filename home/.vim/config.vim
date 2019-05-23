" Load settings that are shared with other Vim-Like instances, e.g. Ideavim
source $HOME/.vim/shared.vim

" Options
"
" See ':help options' for more information.
" Also note that a number of options might be set by plugins (e.g.
" vim-sensible). 
set cmdheight=1
set completeopt+=longest
set completeopt=menuone,menu,longest
set expandtab
set mouse=a
set shiftwidth=2
set smartindent
set softtabstop=2
set termguicolors
set textwidth=0 
set wildignore+=*\\tmp\\*,*.swp,*.swo,*.zip,.git,.cabal-sandbox
set wildmode=longest,list,full
set wrapmargin=0

filetype indent on

" Autocmd triggers relative numbers only for active buffer. 
" Autocmd is not supported in Ideavim, which is why this isn't in the shared
" configuration
:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
:  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
:augroup END

" Create some directories if it does not exist. This is necessary in order to
" simplify automatic installation
"
" See https://stackoverflow.com/a/12488082/2553104
if !isdirectory($HOME/".vim/swp")
    silent call mkdir($HOME."/.vim/swp", "p")
endif

if !isdirectory($HOME/".vim/undo")
    silent call mkdir($HOME."/.vim/undo", "p")
endif

" Save swapfiles/undofiles a specific directory
"
" See here: https://medium.com/@Aenon/vim-swap-backup-undo-git-2bf353caa02f
set directory=$HOME/.vim/swp//
set undofile
set undodir=$HOME/.vim/undo//

" Line wrapping options
"
" All tips inspired by
" https://agilesysadmin.net/how-to-manage-long-lines-in-vim/
set showbreak=…
set linebreak

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
let g:syntastic_sh_shellcheck_args="-x"

let g:syntastic_tex_checkers=['chktex']

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

" NERDTree
" 
" Settings for NERDtree. Keybindings and other tricks from their README. 
map <Leader>n :NERDTreeToggle<CR>

" Close nerdtree if last window
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" FZF
"
" Fore more information see https://github.com/junegunn/fzf.vim#customization
nmap ; :Buffers<CR>
nmap <Leader>: :History:<CR>
nmap <Leader>/ :History/<CR>
nmap <Leader>? :History/<CR>
nmap <Leader>f :Rg<CR>
nmap <Leader>t :Files<CR>
nmap <Leader>r :Tags<CR>

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
