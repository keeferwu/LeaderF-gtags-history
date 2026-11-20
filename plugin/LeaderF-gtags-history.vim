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
let g:Lf_Extensions.gtagsHistory = {
            \ 'source': 'leaderf#gtags_history#source',
            \ 'arguments': [
            \     {'name': ['-c', '--cache'], 'nargs': 0},
            \ ],
            \ 'accept': 'leaderf#gtags_history#accept',
            \ "preview": "leaderf#gtags_history#preview",
            \ 'highlights_def': {
            \   'Lf_hl_gtagsLineNumber': '^\s*\d\+',
            \   'Lf_hl_funcScope':       '^\s*\d\+\s\+\zs\S\+',
            \   'Lf_hl_gtagsFileName':   '^\s*\d\+\s\+\S\+\s\+\zs.*',
            \ },
        \ }

" history line is '<count> <qt> <pat>' -> '<qt> <pat>'
function! LeaderfGtagsPattern(line)
  return substitute(a:line, '^\s*\d\+\s\+', '', '')
endfunction

function! LeaderfGtagsHistory(pat)
  if empty(a:pat)
    return
  endif
  let pat_found   = index(map(copy(g:Lf_GtagsHistoryList), 'LeaderfGtagsPattern(v:val)'), LeaderfGtagsPattern(a:pat))
  if pat_found != -1
    call remove(g:Lf_GtagsHistoryList, pat_found)
  endif
  if len(g:Lf_GtagsHistoryList) >= g:Lf_GtagsHistoryCount
    call remove(g:Lf_GtagsHistoryList, g:Lf_GtagsHistoryCount-1)
  endif
  call insert(g:Lf_GtagsHistoryList, a:pat)
endfunction

function! LeaderfGtagsCount()
  " Matches of the search that just ran. LeaderF's read thread fills _content and sets
  " _read_finished; --auto-jump never does (it jumps on 0 or 1 match), so its content
  " would be a leftover one. Consume the flag so a stale value is not reported later.
  try
    " gtagsExplManager is only global to py3eval after the gtags window was opened
    let l:mgr = '__import__("leaderf.gtagsExpl", fromlist=["x"]).gtagsExplManager'
    if g:Lf_PyEval('"--auto-jump" in ' . l:mgr . '.getArguments()')
      return 0
    endif
    if g:Lf_PyEval('getattr(' . l:mgr . ', "_read_finished", 0)') <= 0
      return 0
    endif
    let l:count = g:Lf_PyEval('len(' . l:mgr . '._content)')
    call g:Lf_PyEval('setattr(' . l:mgr . ', "_read_finished", 0)')
    return l:count
  catch
    return 0
  endtry
endfunction

function! LeaderfGtagsCmdlineRecord(qt,pat)
  let invlaid = matchstr(a:pat,'\W\+')
  if empty(a:pat) || !empty(invlaid)
    echo '>> Pattern is empty or invalid!'
    return
  endif
  execute printf('Leaderf gtags -%s %s%s', a:qt, a:pat, a:qt == 'd' ? ' --auto-jump' : '')
  let l:count = LeaderfGtagsCount()
  if l:count > 0
    call LeaderfGtagsHistory(printf('%-10d %-5s %s', l:count, a:qt, a:pat))
  endif
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
      call LeaderfGtagsCmdlineRecord(qtype[0], qtype[-1])
    else
      exec "echo '>> Querytype is invalid!'"
    endif
  catch /^Vim:Interrupt$/
    echo "Command interrupted"
  finally
    echohl None
  endtry
endfunction

noremap <Plug>LeaderfGtagsHistory    :<C-U>Leaderf gtagsHistory<CR>
noremap <Plug>LeaderfGtagsInternel   :<C-U>call LeaderfGtagsInternel(expand('<cword>'))<CR>
noremap <Plug>LeaderfGtagsDefinition :<C-U>call LeaderfGtagsCmdlineRecord('d', expand('<cword>'))<CR>
noremap <Plug>LeaderfGtagsReference  :<C-U>call LeaderfGtagsCmdlineRecord('r', expand('<cword>'))<CR>
noremap <Plug>LeaderfGtagsSymbol     :<C-U>call LeaderfGtagsCmdlineRecord('s', expand('<cword>'))<CR>
noremap <Plug>LeaderfGtagsGrep       :<C-U>call LeaderfGtagsCmdlineRecord('g', expand('<cword>'))<CR>

if !get(g:, 'leader_gtags_nomap', 0)
nmap <silent> <leader>gh <Plug>LeaderfGtagsHistory
nmap <silent> <leader>ga <Plug>LeaderfGtagsInternel
nmap <silent> <leader>gd <Plug>LeaderfGtagsDefinition
nmap <silent> <leader>gr <Plug>LeaderfGtagsReference
nmap <silent> <leader>gs <Plug>LeaderfGtagsSymbol
nmap <silent> <leader>gg <Plug>LeaderfGtagsGrep
endif
