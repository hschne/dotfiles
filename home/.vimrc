set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" Graphics
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'flazz/vim-colorschemes'
Plugin 'nightsense/stellarized'

" Settings
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-unimpaired'

" Utilities, required by plugins
Plugin 'tomtom/tlib_vim'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'Shougo/vimproc.vim'

" Editor
Plugin 'scrooloose/syntastic'
Plugin 'godlygeek/tabular'
Plugin 'ervandew/supertab'
Plugin 'scrooloose/nerdcommenter'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'garbas/vim-snipmate'
Plugin 'Shougo/neocomplete.vim'
Plugin 'junegunn/vim-easy-align'
Plugin 'rhysd/vim-grammarous' 
" Haskell
Plugin 'eagletmt/ghcmod-vim.git'
Plugin 'eagletmt/neco-ghc'

" Markdown
Plugin 'plasticboy/vim-markdown'
Plugin 'JamshedVesuna/vim-markdown-preview'

" YAML & JSON
Plugin 'chase/vim-ansible-yaml'
Plugin 'tarekbecker/vim-yaml-formatter'
Plugin 'elzr/vim-json'

" Jenkinsfile
Plugin 'martinda/Jenkinsfile-vim-syntax'

" Projects & Files
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'

call vundle#end()            " required
filetype plugin indent on    " required
syntax on

"Modular config
source $HOME/.vim/config.vim

