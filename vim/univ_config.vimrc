"universal settings
"change <leader> to SPACE
nnoremap <SPACE> <Nop>
let mapleader=" "
let maplocalleader="\\"

"seaerch
set incsearch
set hlsearch
set ignorecase
set smartcase
nnoremap <silent><C-c> :noh<CR><Esc>

"copy paste
inoremap <silent> <c-s-v> <Esc>:set paste<Cr>a<c-r>+<Esc>:set nopaste<Cr>a
" change default Y behavior to match with D, C, etc
noremap Y y$
" reselect just pasted block
nnoremap gV `[v`]
" join lines by gj
nnoremap gj J
" <leader>m to set mark
nnoremap <leader>m m
" delete mark X. dma will delete mark a, dmX will delete mark X
nnoremap <leader>d :execute 'delmarks '.nr2char(getchar())<cr>
nnoremap q: <nop>

" " better j/k using gj and gk
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
xnoremap <expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
xnoremap <expr> k v:count == 0 ? 'gk' : 'k'

" insert lines without entering insert mode (allow count)
noremap <silent> go :<C-u>call append(line("."),   repeat([""], v:count1))<CR>
nnoremap <silent> gO :<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>

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
:command! Qa qa
:command! Wqa wqa
:command! Bd bd
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
let g:qs_lazy_highlight = 0
let g:qs_buftype_blacklist = ['nofile']
let g:qs_filetype_blacklist = ['startify','ministarter']
