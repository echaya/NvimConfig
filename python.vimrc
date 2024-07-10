"python config
let pythonthreedll='c:\blp\bqnt\environments\bqnt-3\python\python39.dll'
let pythonthreehome='c:\blp\bqnt\environments\bqnt-3\python\python39'
let g:python3_host_prog='c:\blp\bqnt\environments\bqnt-3\python'
" let pythonthreedll='c:\Program Files\Python39\python39.dll'
" let pythonthreehome='c:\Users\echay\AppData\Local\Programs\Python\Python39'
" let g:python3_host_prog='c:\Users\echay\AppData\Local\Programs\Python\Python39\python'
" let g:repl_python_pre_launch_command = 'c:\\blp\\bqnt\\bootstrapper\\condabin\\activate.bat c:\\blp\\bqnt\\environments\\bqnt-2'
" let g:repl_position = 3
" let g:repl_cursor_down = 1
" let g:repl_python_automerge = 1
" let g:repl_ipython_version = '7'
" nnoremap <leader>r :REPLToggle<Cr>
" autocmd Filetype python nnoremap <F12> <Esc>:REPLDebugStopAtCurrentLine<Cr>
" autocmd Filetype python nnoremap <F10> <Esc>:REPLPDBN<Cr>
" autocmd Filetype python nnoremap <F11> <Esc>:REPLPDBS<Cr>
" let g:sendtorepl_invoke_key = "<F8>" 
" let g:repl_code_block_fences = {'python': '###', 'zsh': '# %%', 'markdown': '```'}


let g:CodeFence = "###"

function! IsFence()
    return getline('.') == g:CodeFence
endfunction!

function! OpenCell() abort
    let cmd = 'normal *kV``j'
    execute cmd
endfunction

" function! CloseCell() abort
"     let cmd = 'normal #jV``k'
"     execute cmd
" endfunction
" nnoremap <leader>cc :call CloseCell()<cr>

function! BetweenCell() abort
    call search('^'.g:CodeFence, 'W')
    normal -
    call search('^'.g:CodeFence, 'Wbs')
    normal +
    normal V''
endfunction

function! SelectCell() abort
    if IsFence()
        call OpenCell()
    else
        call BetweenCell()
    endif
endfunction

nnoremap <leader>oc :call OpenCell()<cr>
nnoremap <leader>bc :call BetweenCell()<cr>
nnoremap <S-CR> :call SelectCell()<cr>

