set nocompatible
filetype off

" Silent auto installation for vim-plug
" See here https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Add fzf to runtimepath
set rtp+=~/.zplug/bin/fzf

call plug#begin('~/.vim/plugged')

" Airline
"
" A plugin to show file info at the bottom. Themes to make it look nice
" are also available. 
"
" Website: https://github.com/vim-airline/vim-airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Nerdtree
"
" Improves file navigation. The plugin adds git support. 
"
" Website: https://github.com/scrooloose/nerdtree
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'

" Startify
"
" sets a start screen for vim
"
" Website: https://github.com/mhinz/vim-startify
Plug 'mhinz/vim-startify'

" Dev Icons
"
" Nice icons everywhere
"
" See https://github.com/ryanoasis/vim-devicons
Plug 'ryanoasis/vim-devicons'

" Nord
"
" An arctic color scheme. I think its beautiful. 
"
" Website: https://git.io/nord-vim
Plug 'arcticicestudio/nord-vim'

" vim-which-key
"
" Display keybindings like in spacevim
" 
" See https://github.com/liuchengxu/vim-which-key
Plug 'liuchengxu/vim-which-key'

" Ranger
"
" Provides a nice ranger integration.
"
" See https://github.com/francoiscabrol/ranger.vim
Plug 'francoiscabrol/ranger.vim'

" Rainbow Parentheses
"
" Because color makes everything better. 
"
" See https://github.com/junegunn/rainbow_parentheses.vim
Plug 'junegunn/rainbow_parentheses.vim'

" Vim-Sensible
"
" Some sensible default settings, so you don't have to set everything
" yourself. 
"
" See https://github.com/tpope/vim-sensible
Plug 'tpope/vim-sensible'

" Vim-Surround
"
" Adds surround motions. Very useful. 
"
" See https://github.com/tpope/vim-surround
Plug 'tpope/vim-surround'

" Vim-Unimpaired
"
" Adds a bunch of useful keybindings. 
"
" See https://github.com/tpope/vim-unimpaired
Plug 'tpope/vim-unimpaired'

" Vim-Commentary
"
" Finally, easy commenting everywhere. 
"
" See https://github.com/tpope/vim-commentary
Plug 'tpope/vim-commentary'

" Vim-Repeat
"
" Allow repeating of easymotions motion.
Plug 'tpope/vim-repeat'

" Vim-EasyMotion
"
" Makes navigation a breeze
"
" See https://github.com/easymotion/vim-easymotion
 Plug 'easymotion/vim-easymotion'

" vim-peekaboo
"
" Displays previous of registers
"
" See https://github.com/junegunn/vim-peekaboo
Plug 'junegunn/vim-peekaboo'

" vim-gitgutter
"
" Displays git status indictars on on files
"
" See https://github.com/airblade/vim-gitgutter
Plug 'airblade/vim-gitgutter'

" vim-buffkill
" 
" Better behaviour when closing buffers
"
" See https://github.com/qpkorr/vim-bufkill
Plug 'qpkorr/vim-bufkill'

" Fzf
"
" Fuzzy file searching for vim. 
"
" See https://github.com/junegunn/fzf.vim
Plug 'junegunn/fzf.vim'

" is.vim
"
" Better handling of searches, mostly used to auto clear search
"
" See https://github.com/haya14busa/is.vim
Plug 'haya14busa/is.vim'

" vim-asterisk
"
" Better handling of * searches
"
" See https://github.com/haya14busa/vim-asterisk
Plug 'haya14busa/vim-asterisk'

" Ale
"
" Even more fantastic syntax checking for vim. 
"
" Website: https://github.com/w0rp/ale
Plug 'w0rp/ale'

" Tabular 
"
" Simple plugin for tab alignment. 
"
" See https://github.com/godlygeek/tabular
Plug 'godlygeek/tabular' 

" Grammarous
"
" Because I still suck in english.
"
" See https://github.com/rhysd/vim-grammarous
Plug 'rhysd/vim-grammarous'

" Coc.vim
"
" Language server capabilities for Vim
"
" See https://github.com/neoclide/coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Ultisnips
"
" Snippet Engine
"
" See https://github.com/SirVer/ultisnips
Plug  'SirVer/ultisnips'

" Vim Snippets
"
" Community maintained snippets for lots of things. Works together with
" Ultisnips 
"
" See https://github.com/honza/vim-snippets
Plug 'honza/vim-snippets'

" Prettier
"
" Better formatting for Vim
"
" See https://github.com/prettier/vim-prettier
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

" Vim Gutentags
"
" Automatically generate tags
"
" See https://github.com/ludovicchabant/vim-gutentags
Plug 'ludovicchabant/vim-gutentags'

" Tmux Pane Navigation
"
" Seamlessly navigate between vim splits and tmux panes.
"
" See https://github.com/christoomey/vim-tmux-navigator
Plug 'christoomey/vim-tmux-navigator'

" EditorConfig 
"
" Makes it so code is always formatted according to the conventions.
"
" See https://github.com/editorconfig/editorconfig-vim
Plug 'editorconfig/editorconfig-vim'

Plug 'vimwiki/vimwiki'
" Markdown Preview
"
" Enables local markdown preview! 
"
" See https://github.com/JamshedVesuna/vim-markdown-preview
Plug 'JamshedVesuna/vim-markdown-preview', { 'for': 'markdown' }

" Emmet for Vim
"
" Enables quickly writing a bunch of HTML
"
" See https://github.com/mattn/emmet-vim
Plug 'mattn/emmet-vim', { 'for': ['html','css','javascript', 'javascriptreact'] }

" Styled Components Highlighting

" See https://github.com/styled-components/vim-styled-components
Plug 'styled-components/vim-styled-components', { 'for': ['javascriptreact'], 'branch': 'main' }

" CSS Colors
"
" Shows hex colors in the editor
Plug 'ap/vim-css-color', { 'for': ['html', 'css'] }

" Polyglot
"
" All the language packs you'll ever need. Disable config must come before
" loading the plugin.
"
" See https://github.com/sheerun/vim-polyglot
let g:polyglot_disabled = ['latex']
Plug 'sheerun/vim-polyglot'

" bats.vim
"
" Bats syntax highlighting. 
"
" See https://github.com/aliou/bats.vim
Plug 'aliou/bats.vim', { 'for': 'bats' }

" VimTex
"
" A lightweight plugin for nice latex support. 
"
" See https://github.com/lervag/vimtex
Plug 'lervag/vimtex', { 'for': 'tex' }

call plug#end()

filetype plugin indent on
syntax on

" Load additional configuration 
source $HOME/.vim/config.vim

