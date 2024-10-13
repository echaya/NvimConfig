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

"function RedrawiPython()
"    let l:current_window = win_getid()
"    "echo current_window
"    let wins = win_findbuf(bufnr('ipython.EXE'))
"    "echo wins
"    call win_gotoid(wins[0])
"    norm i
"    norm <c-l>
"endfunction

augroup PythonRepl
    autocmd!
    " code snippet
    autocmd Filetype python inoremap <buffer> ;f ###<CR><Esc>
    autocmd Filetype python inoremap <buffer> ;cb .to_clipboard()
    autocmd Filetype python inoremap <buffer> ;ct .copy(True)
    autocmd Filetype python inoremap <buffer> ;it inplace=True
    autocmd Filetype python inoremap <buffer> ;fr .iloc[0].T
    autocmd Filetype python inoremap <buffer> ;lr .iloc[-1].T
    autocmd Filetype python inoremap <buffer> ;db __import__("IPython").core.debugger.set_trace()
    " REPL actions
    "autocmd Filetype python nmap <buffer> <localleader><localleader> :call SendCell()<cr><cr>
    " TODO to activate terminal and jump back using
    " local current_window = vim.api.nvim_get_current_win() -- save current window
    " vim.api.nvim_set_current_win(current_window)
    autocmd Filetype python nnoremap <buffer> <localleader>l <c-w><c-l>i<c-l><Cmd>wincmd h<CR>
    autocmd Filetype python nnoremap <buffer> <localleader>v <cmd>call SelectVisual()<cr>
    autocmd Filetype python nnoremap <buffer> <localleader>db <cmd>call DebugCell()<cr>
    autocmd Filetype python nnoremap <buffer> <localleader>dd :<cmd>call DebugDelete()<cr>:'<,'>g/core.debugger.set_trace/d<cr>
augroup END

tnoremap ;cb .to_clipboard()
tnoremap ;fr .iloc[0].T
tnoremap ;lr .iloc[-1].T

" diagnostic box open by cursor
"autocmd CursorHold * lua vim.diagnostic.open_float()
