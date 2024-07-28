"python config
let pythonthreedll='c:\blp\bqnt\environments\bqnt-3\python\python39.dll'
let pythonthreehome='c:\blp\bqnt\environments\bqnt-3\python\python39'
let g:python3_host_prog='c:\blp\bqnt\environments\bqnt-3\python'
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

function! IsLineIndented()
    let lineContent = getline('.')
    if match(lineContent, ' ') == 0
        return 1
    else
        return 0
    endif
endfunction

function! IsFence()
    return getline('.') == g:CodeFence
endfunction!

function! OpenCell() abort
    let cmd = 'normal *kV``jo'
    execute cmd
endfunction

" function! CloseCell() abort
"     let cmd = 'normal #jV``k'
"     execute cmd
" endfunction
" nnoremap <leader>cc :call CloseCell()<cr>

function! BetweenCell() abort
    if search('^'.g:CodeFence, 'W') == 0
        normal Go###
        if IsLineIndented()
            normal 0dt#
        endif
    endif
    normal -
    let Start = line(".")
    let End = search('^'.g:CodeFence, 'Wbs')
    normal +
    if Start - End == 1
        normal V
    else
        normal V''
    endif
endfunction

function! SelectCell() abort
    if IsFence()
        call OpenCell()
    else
        call BetweenCell()
    endif
endfunction

function! SendCell() abort
    call feedkeys("\<CR>")
    call search('^'.g:CodeFence, 'W') 
endfunction

augroup PythonRepl
    autocmd!
    " code snippet
    autocmd Filetype python inoremap <buffer> ;f ###<cr>
    autocmd Filetype python inoremap <buffer> ;cb .to_clipboard()
    autocmd Filetype python inoremap <buffer> ;ct .copy(True)
    autocmd Filetype python inoremap <buffer> ;it ,inplace=True
    autocmd Filetype python nnoremap <buffer> <leader>p yiwoprint(<esc>pa)<esc>
    " REPL actions
    autocmd Filetype python nnoremap <buffer> <BS> :call SelectCell()<cr>
    autocmd Filetype python vmap <buffer> <BS> <CR>/###<CR>
augroup END
