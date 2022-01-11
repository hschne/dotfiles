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
  let g:vimwiki_table_mappings = 0
  " See https://github.com/vimwiki/vimwiki/issues/845#issuecomment-683423984
  au filetype vimwiki silent! iunmap <buffer> <Tab>
endfunction
