if !exists('g:Lf_GtagsHistoryCount')
    let g:Lf_GtagsHistoryCount = 20
endif
if !exists('g:Lf_Extensions')
    let g:Lf_Extensions = {}
endif
let g:Lf_GtagsHistoryList = []
" 'arguments': [
"     {'name': ['-d', '--delete'], 'nargs': 0},
"     {'name': ['--untracked-files', '-u'], 'nargs': '?'}
"  ],
let g:Lf_Extensions.gtags_history = {
            \ 'source': 'leaderf#gtags_history#source',
            \ 'arguments': [
            \     {'name': ['-d', '--delete'], 'nargs': 0},
            \ ],
            \ 'accept': 'leaderf#gtags_history#accept',
            \ 'highlights_def': {
            \   'Lf_hl_funcScope': '^\S\+',
            \ },
        \ }

function! LeaderfGtagsHistory(pat)
  if empty(a:pat)
    return
  endif
  let pat_found   = index(g:Lf_GtagsHistoryList, a:pat)
  if pat_found != -1
    call remove(g:Lf_GtagsHistoryList, pat_found)
  endif
  if len(g:Lf_GtagsHistoryList) >= g:Lf_GtagsHistoryCount
    call remove(g:Lf_GtagsHistoryList, g:Lf_GtagsHistoryCount-1)
  endif
  call insert(g:Lf_GtagsHistoryList, a:pat)
endfunction

function! LeaderfGtagsCmdlineRecord(qt,pat)
  let invlaid = matchstr(a:pat,'\W\+')
  if empty(a:pat) || !empty(invlaid)
    return "echo '>> Pattern is empty or invalid!'"
  endif
  let pattern = a:qt . " " . a:pat
  call LeaderfGtagsHistory(pattern)
  return printf("Leaderf! gtags -%s%s", pattern, a:qt == 'd' ? ' --auto-jump' : '')
endfunction

function! LeaderfGtagsInternel(pat)
  try
    echohl Question
    call inputsave()
    let qinput = input("Choose a querytype for '".a:pat."'" .
                     \ "\n  d: GtagsFindDefinition" .
                     \ "\n  r: GtagsFindReference" .
                     \ "\n  s: GtagsFindSymbol" .
                     \ "\n  g: GtagsFindGrep" .
                     \ "\n or <querytype> <pattern> to query `pattern`" .
                     \ "\n> ")
    call inputrestore()
    "call feedkeys("\<c-u>", 'n')
    redraw!
    let qtype = split(qinput)
    if len(qtype) == 0
      exec "echo '>> Input is empty!'"
      return
    endif
    if len(qtype) == 1
      call add(qtype, a:pat)
    endif
    if qtype[0] == 'd' || qtype[0] == 'r' || qtype[0] == 's' || qtype[0] == 'g'
      exec LeaderfGtagsCmdlineRecord(qtype[0], qtype[-1])
    else
      exec "echo '>> Querytype is invalid!'"
    endif
      catch /^Vim:Interrupt$/
      echo "Command interrupted"
  finally
    echohl None
  endtry
endfunction

noremap <Plug>LeaderfGtagsInternel   :<C-U>call LeaderfGtagsInternel(expand('<cword>'))<CR>
noremap <Plug>LeaderfGtagsDefinition :<C-U><C-R>=LeaderfGtagsCmdlineRecord('d', expand('<cword>'))<CR><CR>
noremap <Plug>LeaderfGtagsReference  :<C-U><C-R>=LeaderfGtagsCmdlineRecord('r', expand('<cword>'))<CR><CR>
noremap <Plug>LeaderfGtagsSymbol     :<C-U><C-R>=LeaderfGtagsCmdlineRecord('s', expand('<cword>'))<CR><CR>
noremap <Plug>LeaderfGtagsGrep       :<C-U><C-R>=LeaderfGtagsCmdlineRecord('g', expand('<cword>'))<CR><CR>

if get(g:, 'leader_gtags_nomap', 0) == 0
nmap <silent><leader>ga <Plug>LeaderfGtagsInternel
nmap <silent><leader>gd <Plug>LeaderfGtagsDefinition
nmap <silent><leader>gr <Plug>LeaderfGtagsReference
nmap <silent><leader>gs <Plug>LeaderfGtagsSymbol
nmap <silent><leader>gg <Plug>LeaderfGtagsGrep
endif
