function! leaderf#gtags_history#source(args) abort "{{{
  let l:histories = []
  let l:keys = filter(keys(a:args), 'v:val =~# "^-"')
  "let l:arguments = map(l:keys, 'empty(a:args[v:val]) ? v:val : v:val ."=". a:args[v:val][0]')
  if empty(l:keys)
    for l:history in get(g:, 'Lf_GtagsHistoryList', [])
      let l:histories += [l:history]
    endfor
  else
    let s:Lf_GtagsDatabase = expand(g:Lf_CacheDirectory.'/LeaderF/gtags/')
    for l:history in split(globpath(s:Lf_GtagsDatabase, '*'), '\n')
      let l:history = fnamemodify(l:history, ':t')
      let l:histories += [l:history]
    endfor
  endif
  return l:histories
endfunction "}}}

function! leaderf#gtags_history#accept(line, args) abort "{{{
  let l:keys = filter(keys(a:args), 'v:val =~# "^-"')
  if empty(l:keys)
    execute "Leaderf! gtags -".a:line
  else
    echo 'Do you want to delete ' . a:line . '?  [y/n]'
    if nr2char(getchar()) == 'y'
      let item = s:Lf_GtagsDatabase . a:line
      call system('rm -rf ' . shellescape(item))
    endif
    execute "Leaderf gtags_history -c"
    call feedkeys("\<cr>", 'n')
  endif
endfunction "}}}

function! leaderf#gtags_history#preview(orig_buf_nr, orig_cursor, line, args) abort "{{{
  let l:keys = filter(keys(a:args), 'v:val =~# "^-"')
  if empty(l:keys)
    let l:bufname = tempname()
    let l:cmds = 'global --gtagslabel='.$GTAGSLABEL.' -l -'.a:line.' --result=ctags-mod > '.l:bufname
    call system(l:cmds)
    let l:bufnr = bufadd(l:bufname)
    return [l:bufnr, 0, '']
  endif
  return
endfunction "}}}

