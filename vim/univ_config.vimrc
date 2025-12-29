"universal settings and keymaps
set noswapfile
let maplocalleader="\\"

" <leader>gc to comment out and copy the line
nmap <leader>gc gccyypgcc
xmap <leader>gc ygvgc`>p
" join lines by gj
nnoremap gj J
" <leader>m to set mark
"nnoremap <leader>m m
" delete mark X. dma will delete mark a, dmX will delete mark X
nnoremap dm :execute 'delmarks '.nr2char(getchar())<cr>
nnoremap dM :delmarks!
nnoremap q: <nop>

" use Alt+j/k to swap lines (allow count)
nnoremap <A-j> :<c-u>execute 'move +'. v:count1<cr>
nnoremap <A-k> :<c-u>execute 'move -1-'. v:count1<cr>
xnoremap <silent> <A-j> :m '>+1<cr>gv=gv
xnoremap <silent> <A-k> :m '<-2<cr>gv=gv

" saner command-line histsory
cnoremap <expr> <c-n> wildmenumode() ? "\<c-n>" : "\<down>"
cnoremap <expr> <c-p> wildmenumode() ? "\<c-p>" : "\<up>"

" swap v and Ctrl-v
nnoremap  v <C-V>
nnoremap <C-V> v

" ex command remap
:command! Wq wq
:command! W w
:command! Q q
:command! E e
:command! Qa qa
:command! Wqa wqa
:command! WQa wqa
:command! Bd bd
" edit as dos, to remove ^m
:command M e ++ff=dos | set ff=unix | w
" duplicate current window in Vertical
:command V vsplit
:command S split
" convert # In[ ]: => ### Cell
:command ReplaceIn %s/#\s*In\[\s*\d*\s*\]\?:/###/g

nnoremap <leader>q <cmd>q<cr>
nnoremap <leader>wq <cmd>wq<cr>

" execute macro at visual range, does not stop when no match
function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
endfunction
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

" toggle UPPER CASE, lower case and Title Case in visual mode
function! TwiddleCase(str)
    if a:str ==# toupper(a:str)
        let result = tolower(a:str)
    elseif a:str ==# tolower(a:str)
        let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
    else
        let result = toupper(a:str)
    endif
    return result
endfunction
vnoremap ~ y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv

" use 'x' as to cut text into register, cutlass prevents C/D go into register
nnoremap x d
xnoremap x d
nnoremap xx dd
nnoremap X D

" quick-scope specs
let g:qs_lazy_highlight = 1
