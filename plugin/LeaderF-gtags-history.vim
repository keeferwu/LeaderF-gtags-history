if !exists('g:Lf_Extensions')
    let g:Lf_Extensions = {}
endif
let g:Lf_GtagsHistoryList = []

let g:Lf_Extensions.gtags_history = {
            \ 'source': 'leaderf#gtags_history#source',
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
    if len(g:Lf_GtagsHistoryList) >= 20
        call remove(g:Lf_GtagsHistoryList, 19)
    endif
    call insert(g:Lf_GtagsHistoryList, a:pat)
endfunction

function! LeaderfGtagsInternel(qt,pat)
    if a:qt == 'a'
        call inputsave()
        let qinput = input("\nChoose a querytype for '".a:pat."'\n  d: GtagsFindDefinition\n  r: GtagsFindReference\n  s: GtagsFindSymbol\n  g: GtagsFindGrep\n  or\n  <querytype><pattern> to query `pattern`.\n> ")
        call inputrestore()
        let qtype = split(qinput)
        if len(qtype) == 0
            return "echo '\n>> Input is empty!'"
        elseif len(qtype) == 1
            let pattern = qtype[0]." ".a:pat
        else
            let pattern = qtype[0]." ".qtype[1]
        endif
    else
        let pattern = a:qt." ".a:pat
    endif
    let invlaid = matchstr(pattern[2:],'\W\+')
    if !empty(invlaid) || len(pattern) <= 2
        return "echo '\n>> Pattern is empty or invalid!'"
    endif
    let cmd = "Leaderf! gtags "
    if pattern[0] == 'd' || pattern[0] == 'r' || pattern[0] == 's' || pattern[0] == 'g'
        call LeaderfGtagsHistory(pattern)
    else
        return "echo '\n>> Querytype is invalid!'"
    endif
    let cmd .= "-".pattern
    if pattern[0] == 'd'
        let cmd .= " --auto-jump"
    endif
    return cmd
endfunction

noremap <Plug>LeaderfGtagsInternel   :<C-U><C-R>=LeaderfGtagsInternel('a', expand('<cword>'))<CR><CR>
noremap <Plug>LeaderfGtagsDefinition :<C-U><C-R>=LeaderfGtagsInternel('d', expand('<cword>'))<CR><CR>
noremap <Plug>LeaderfGtagsReference  :<C-U><C-R>=LeaderfGtagsInternel('r', expand('<cword>'))<CR><CR>
noremap <Plug>LeaderfGtagsSymbol     :<C-U><C-R>=LeaderfGtagsInternel('s', expand('<cword>'))<CR><CR>
noremap <Plug>LeaderfGtagsGrep       :<C-U><C-R>=LeaderfGtagsInternel('g', expand('<cword>'))<CR><CR>

if get(g:, 'leader_gtags_nomap', 0) == 0
map <silent> <leader>ga <Plug>LeaderfGtagsInternel
map <silent> <leader>gd <Plug>LeaderfGtagsDefinition
map <silent> <leader>gr <Plug>LeaderfGtagsReference
map <silent> <leader>gs <Plug>LeaderfGtagsSymbol
map <silent> <leader>gg <Plug>LeaderfGtagsGrep
endif

