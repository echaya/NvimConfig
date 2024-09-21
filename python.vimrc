"python config
" g:pythonthreedll, g:pythonthreehome & g:python3_host_prog are set in init.vim
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

function! BuildFence()
    exe "normal Go".g:CodeFence
    if IsLineIndented()
        normal 0dt#
    endif
endfunction

function! OpenCell() abort
    let cmd = 'normal *kV``jo'
    execute cmd
endfunction

function! CloseCell() abort
    let cmd = 'normal #jV``'
    execute cmd
    normal -
endfunction
" nnoremap <leader>cc :call CloseCell()<cr>

function! BetweenCell() abort
    let Start = line(".")
    let End = search('^'.g:CodeFence, 'Wbs')
    normal +
    if Start - End == 1
        normal V
    else
        normal V''
    endif
endfunction

function! SelectVisual() abort
    if search('^'.g:CodeFence, 'W') == 0
        call BuildFence()
        call CloseCell()
    else
        normal -
        call BetweenCell()
    endif
endfunction

function! SendCell() abort
    call SelectVisual()
endfunction

function DebugCell()
    call SelectVisual()
    normal >O
    normal Idef DebugCell():
    normal `>o
    normal IDebugCell()
endfunction

function DebugDelete()
    call SelectVisual()
    normal <
    normal '<dd
    normal `>dd
endfunction

augroup PythonRepl
    autocmd!
    " code snippet
    autocmd Filetype python inoremap <buffer> ;f ###<cr>
    autocmd Filetype python inoremap <buffer> ;cb .to_clipboard()
    autocmd Filetype python inoremap <buffer> ;ct .copy(True)
    autocmd Filetype python inoremap <buffer> ;it inplace=True
    autocmd Filetype python inoremap <buffer> ;fr .iloc[0].T
    autocmd Filetype python inoremap <buffer> ;lr .iloc[-1].T
    autocmd Filetype python inoremap <buffer> ;db __import__("IPython").core.debugger.set_trace()
    " REPL actions
    "autocmd Filetype python nmap <buffer> <localleader><localleader> :call SendCell()<cr><cr>
    autocmd Filetype python nnoremap <buffer> <localleader>v <cmd>call SelectVisual()<cr>
    autocmd Filetype python nnoremap <buffer> <localleader>dc <cmd>call DebugCell()<cr>
    autocmd Filetype python nnoremap <buffer> <localleader>dd :<cmd>call DebugDelete()<cr>:'<,'>g/core.debugger.set_trace/d<cr>
augroup END

"autocmd CursorHold * lua vim.diagnostic.open_float()

tnoremap ;cb .to_clipboard()
tnoremap ;fr .iloc[0].T
tnoremap ;lr .iloc[-1].T
