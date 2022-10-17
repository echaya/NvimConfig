let g:temp_cb_name = "temp_cb"


function! PowerClose(strong)
    
    let cnt = 0

    for i in range(0, bufnr("$"))
        if buflisted(i) 
            let cnt += 1 
        endif
    endfor

    if cnt <= 1
        let l:cmd = "q"
    else
        let l:cmd = "bd"
    endif

    if a:strong != 0
        let l:cmd .= "!"
    endif

    if expand('%') == g:temp_cb_name
        let l:cmd = "call delete('".g:temp_cb_name."') | bd!"
    endif
    " echo cmd
    execute cmd

endfunction

nnoremap <silent> ZZ :call PowerClose(0)<cr>
nnoremap <silent> ZQ :call PowerClose(1)<cr>


function! ChooseBuffer(buffername)
    let bnr = bufwinnr(a:buffername)
    if bnr > 0
       execute bnr . "wincmd w"
    else
       " echom a:buffername . ' is not existent'
       silent execute 'vsplit ' . a:buffername 
    endif
endfunction

noremap <silent><leader>+ :call ChooseBuffer(g:temp_cb_name)<cr>Go<esc>p

function! EditMdLink() abort
    " let cmd ='normal 0:s/\V\\/:/g$F:;ld0mf: ojp$r/kI. :s/\V./|/g/|mdD0:s/ /_/g:s/|/_/gd2lY sa$[A|(")j0Mdd$?]|(lxp0yi[k:echo""' 
    let cmd ='normal 0:s/\V\\/:/g$F:;ld0mf: ojp$r/kI. :s/\V./|/g/|mdD0:s/ /_/g:s/|/_/gd2lY ys$[A|(")j0Mdd$?]|(lxp0yi[k:echo""' 
    execute cmd
endfunction




