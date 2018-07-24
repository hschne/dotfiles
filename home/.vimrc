set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" Graphics
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'arcticicestudio/nord-vim'

" Settings
Plugin 'tpope/vim-sensible'

" Editor
Plugin 'scrooloose/syntastic'
Plugin 'godlygeek/tabular' 
Plugin 'ervandew/supertab'
Plugin 'rhysd/vim-grammarous'

" Markdown
Plugin 'plasticboy/vim-markdown'
Plugin 'JamshedVesuna/vim-markdown-preview'

call vundle#end()
filetype plugin indent on
syntax on

"Modular config
source $HOME/.vim/config.vim

