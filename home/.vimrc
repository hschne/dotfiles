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

" Nord
"
" An arctic color scheme. I think its beautiful. 
"
" Website: https://git.io/nord-vim
Plug 'arcticicestudio/nord-vim'

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

" vim-smoothie
"
" Smooth scrolling for Vim. Much wow. 
"
" https://github.com/psliwka/vim-smoothie
Plug 'psliwka/vim-smoothie'

" Fzf
"
" Fuzzy file searching for vim. 
"
" See https://github.com/junegunn/fzf.vim
Plug 'junegunn/fzf.vim'


" Auto-Pairs
"
" Automatically create pairs for braces, quotes...
"
" See https://github.com/jiangmiao/auto-pairs
Plug 'jiangmiao/auto-pairs'
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

" Supertab
"
" Tab autocompletions for vim. 
"
" See https://github.com/ervandew/supertab
Plug 'ervandew/supertab'

" Grammarous
"
" Because I still suck in english.
"
" See https://github.com/rhysd/vim-grammarous
Plug 'rhysd/vim-grammarous'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

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

" bats.vim
"
" Bats syntax highlighting. 
"
" See https://github.com/aliou/bats.vim
Plug 'aliou/bats.vim', { 'for': 'bats' }

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

" Markdown
"
" Some nice to have functionality for writing markdown.
"
" See https://github.com/plasticboy/vim-markdown
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

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
Plug 'mattn/emmet-vim', { 'for': ['html','css','javascript'] }

" CSS Colors
"
" Shows hex colors in the editor
Plug 'ap/vim-css-color', { 'for': ['html', 'css'] }


" Bootstrap Snippets
"
" See https://github.com/jvanja/vim-bootstrap4-snippets
Plug 'jvanja/vim-bootstrap4-snippets', { 'for': 'html' }

" VimTex
"
" A lightweight plugin for nice latex support. 
"
" See https://github.com/lervag/vimtex
Plug 'lervag/vimtex', { 'for': 'latex' }


call plug#end()

filetype plugin indent on
syntax on

" Load additional configuration 
source $HOME/.vim/config.vim

