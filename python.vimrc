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

function! JumpCell() abort
    if search('^'.g:CodeFence, 'W') == 0
        norm G
    endif
endfunction

function! JumpCellBack() abort
    if search('^'.g:CodeFence, 'Wb') == 0
        norm gg
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
    if search("def DebugCell", "w") == 0
        echo "Debug Cell is not found!"
    else
        call SelectVisual()
        normal <
        normal '<dd
        normal `>dd
    endif
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
    "autocmd Filetype python inoremap <buffer> ;db __import__("IPython").core.debugger.set_trace()
    " REPL actions
    "autocmd Filetype python nmap <buffer> <localleader><localleader> :call SendCell()<cr><cr>
    " TODO to activate terminal and jump back using
    " local current_window = vim.api.nvim_get_current_win() -- save current window
    " vim.api.nvim_set_current_win(current_window)
    autocmd Filetype python nnoremap <buffer> <localleader>l <c-w><c-l>i<c-l><Cmd>wincmd h<CR>
    autocmd Filetype python nnoremap <buffer> <localleader>v <cmd>call SelectVisual()<cr>
    autocmd Filetype python nnoremap <buffer> <localleader>db <cmd>call DebugCell()<cr>
    autocmd Filetype python nnoremap <buffer> <localleader>dd <cmd>call DebugDelete()<cr>:'<,'>g/core.debugger.set_trace/d<cr>
"    autocmd Filetype python nnoremap <buffer> <localleader><localleader> <cmd>call JumpCell()<cr>
augroup END

tnoremap ;cb .to_clipboard()
tnoremap ;fr .iloc[0].T
tnoremap ;lr .iloc[-1].T

" diagnostic box open by cursor
"autocmd CursorHold * lua vim.diagnostic.open_float()


function! MyTabLine()
    let s = ''
    let t = tabpagenr()
    let i = 1
    while i <= tabpagenr('$')

        let buflist = tabpagebuflist(i)
        let winnr = tabpagewinnr(i)
        let s .= '%' . i . 'T'
        let s .= (i == t ? '%1*' : '%2*')
        let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
        let s .= ' ' . i . ' '

        let bufnr = buflist[winnr - 1]
        let file = bufname(bufnr)
        let buftype = getbufvar(bufnr, '&buftype')
        if buftype == 'help'
            let file = 'help:' . fnamemodify(file, ':t:r')
        elseif buftype == 'quickfix'
            let file = 'quickfix'
        elseif buftype == 'nofile'
            if file =~ '\/.'
                let file = substitute(file, '.*\/\ze.', '', '')
            endif
        else
            let file = pathshorten(fnamemodify(file, ':p:~:.'))
            if getbufvar(bufnr, '&modified')
                let file = '+' . file
            endif
        endif
        if file == ''
            let file = '[No Name]'
        endif
        let s .= ' ' . file

        if i < tabpagenr('$')
            let s .= ' %#TabLine#|'
        else
            let s .= ' '
        endif

        let i = i + 1

    endwhile

    let s .='%#TabLineSel#'
    let s .="%{%v:lua.require'nvim-navic'.get_location()%}"
    let s .= '%T%#TabLineFill#%='
    let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
    return s

endfunction

set tabline=%!MyTabLine()

