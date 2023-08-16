" Vim syntax file
" Language: Vimwiki
" Maintainer: Hans Schnedlitz
"
" Based on https://gist.github.com/huytd/668fc018b019fbc49fa1c09101363397

syntax match VimwikiListTodo '\v(\s+)?(-|\*)\s\[\s\]'hs=e-4 conceal cchar=
syntax match VimwikiListTodo '\v(\s+)?(-|\*)\s\[X\]'hs=e-4 conceal cchar=󰄲
syntax match VimwikiListTodo '\v(\s+)?(-|\*)\s\[-\]'hs=e-4 conceal cchar=󰄲
syntax match VimwikiListTodo '\v(\s+)?(-|\*)\s\[\.\]'hs=e-4 conceal cchar=󱗜
syntax match VimwikiListTodo '\v(\s+)?(-|\*)\s\[o\]'hs=e-4 conceal cchar=󱋬

hi def link todoCheckbox VimwikiListTodo
hi Conceal guibg=NONE

setlocal cole=1

