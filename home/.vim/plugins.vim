" Thi sfile lists all the plugins
set nocompatible
filetype off

" Vundle
"
" Vundle is a package manager for VIM. Allows you to install all the plugins
" you will never need. Very simply. 
"
" Website: git@github.com:VundleVim/Vundle.vim.git
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" Airline
"
" A plugin to show file info at the bottom. Themes to make it look nice
" are also available. 
"
" Website: https://github.com/vim-airline/vim-airline
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Nord
"
" An arctic color scheme. I think its beautiful. 
"
" Website: https://git.io/nord-vim
Plugin 'arcticicestudio/nord-vim'

" Vim-Sensible
"
" Some sensible default settings, so you don't have to set everything
" yourself. 
"
" See https://github.com/tpope/vim-sensible
Plugin 'tpope/vim-sensible'

" Vim-Surround
"
" Adds surround motions. Very useful. 
"
" See https://github.com/tpope/vim-surround
Plugin 'tpope/vim-surround'

" Vim-Unimpaired
"
" Adds a bunch of useful keybindings. 
"
" See https://github.com/tpope/vim-unimpaired
Plugin 'tpope/vim-unimpaired'

" Vim-Commentary
"
" Finally, easy commenting everywhere. 
"
" See https://github.com/tpope/vim-commentary
Plugin 'tpope/vim-commentary'

" Syntastic
"
" Fantastic syntax checking for vim. 
"
" Website: https://github.com/vim-syntastic/syntastic
Plugin 'scrooloose/syntastic'

" Tabular 
"
" Simple plugin for tab alignment. 
"
" See https://github.com/godlygeek/tabular
Plugin 'godlygeek/tabular' 

" Supertab
"
" Tab autocompletions for vim. 
"
" See https://github.com/ervandew/supertab
Plugin 'ervandew/supertab'

" Grammarous
"
" Because I still suck in english.
"
" See https://github.com/rhysd/vim-grammarous
Plugin 'rhysd/vim-grammarous'

" Markdown
"
" Some nice to have functionality for writing markdown.
"
" See https://github.com/plasticboy/vim-markdown
Plugin 'plasticboy/vim-markdown'

" Markdown Preview
"
" Enables local markdown preview! 
"
" See https://github.com/JamshedVesuna/vim-markdown-preview
Plugin 'JamshedVesuna/vim-markdown-preview'

" VimTex
"
" A lightweight plugin for nice latex support. 
"
" See https://github.com/lervag/vimtex
Plugin 'lervag/vimtex'

" UltiSnips
"
" A modern snippet engine. Doesn't come with any snippets though. 
"
" See https://github.com/SirVer/ultisnips
Plugin 'SirVer/ultisnips'

" Vim Snippets
"
" Community maintained snippets for lots of things. Works together with
" Ultisnips 
"
" See https://github.com/honza/vim-snippets
Plugin 'honza/vim-snippets'

call vundle#end()
filetype plugin indent on
syntax on
