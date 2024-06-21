function! leaderf#gtags_history#source(args) abort "{{{
  let l:histories = []
  for l:history in get(g:, 'Lf_GtagsHistoryList', [])
    let l:histories += [l:history]
  endfor
  return l:histories
endfunction "}}}

function! leaderf#gtags_history#accept(line, args) abort "{{{
  execute "Leaderf! gtags -".a:line
endfunction "}}}
