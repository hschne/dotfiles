function! myspacevim#after() abort
  set clipboard=unnamedplus
  set wrap


  " Deactivate Arrow Keys
  "
  " Disable arrow keys. Helps getting gud in vim. 
  noremap <Up> <Nop>
  noremap <Down> <Nop>
  noremap <Left> <Nop>
  noremap <Right> <Nop>

  " Simpler multi line navigation
  nnoremap k gk
  nnoremap j gj

  " vimwiki
  let g:vimwiki_list = [{'path': '~/Documents/wiki', 'syntax': 'markdown', 'index': 'home', 'ext': '.md', 'auto_diary_index': 1 }]
  let g:vimwiki_global_ext = 0
endfunction
