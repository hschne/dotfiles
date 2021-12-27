function! myspacevim#after() abort
  set clipboard=unnamedplus
  set wrap

  " vimwiki
  let g:vimwiki_list = [{'path': '~/Documents/wiki', 'syntax': 'markdown', 'index': 'home', 'ext': '.md', 'auto_diary_index': 1 }]
  let g:vimwiki_global_ext = 0
endfunction
